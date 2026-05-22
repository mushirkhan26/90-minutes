import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/alert_utils.dart';
import '../../../widgets/auth_header.dart';
import '../../../widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobile;
  const VerifyOtpScreen({super.key, required this.mobile});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> with CodeAutoFill {
  final _otpController = TextEditingController();
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void codeUpdated() {
    if (!mounted) return;
    if (code != null && code!.length == AppConstants.otpLength) {
      final currentState = context.read<AuthBloc>().state;
      if (currentState is AuthLoading && currentState.action == 'verify') return;

      setState(() {
        _otpController.text = code!;
      });
      _verifyOtp();
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    listenForCode();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    cancel(); // sms_autofill cancel
    super.dispose();
  }

  void _verifyOtp() {
    if (_otpController.text.length == AppConstants.otpLength) {
      context
          .read<AuthBloc>()
          .add(OtpVerificationRequested(widget.mobile, _otpController.text));
    } else {
      AlertHelper.snackBarError(context, 'Please enter a valid ${AppConstants.otpLength}-digit OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocListener<AuthBloc, AuthState>(
        listener: _authListener,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthHeader(
                            title: 'Verify your number',
                            subtitle: 'OTP sent to +91 ${widget.mobile}',
                            showLogo: false,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          _buildOtpInput(screenWidth),
                          SizedBox(height: screenHeight * 0.04),
                          _buildResendSection(),
                          const Spacer(),
                          _buildVerifyButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state is AuthOtpSent) {
      _startTimer();
      AlertHelper.snackBarSuccess(context, 'OTP resent successfully!');
    } else if (state is AuthAuthenticated) {
      AlertHelper.snackBarSuccess(context, 'Verified successfully!');
      context.go(AppRoutes.homeRoute);
    } else if (state is AuthError) {
      AlertHelper.snackBarError(context, state.message);
    }
  }

  Widget _buildOtpInput(double screenWidth) {
    final pinWidth = (screenWidth - (screenWidth * 0.12) - 48) / AppConstants.otpLength;
    final defaultPinTheme = PinTheme(
      width: pinWidth.clamp(50, 60),
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyOutline),
      ),
    );

    return Center(
      child: Pinput(
        controller: _otpController,
        length: AppConstants.otpLength,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: AppColors.primaryDarkGreen, width: 2),
          ),
        ),
        onCompleted: (pin) => _verifyOtp(),
      ),
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Didn\'t receive the code?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _timerSeconds == 0
                ? () {
                    context.read<AuthBloc>().add(LoginRequested(widget.mobile));
                  }
                : null,
            child: Text(
              _timerSeconds > 0
                  ? 'Resend OTP in 00:${_timerSeconds.toString().padLeft(2, '0')}'
                  : 'Resend OTP',
              style: TextStyle(
                color: _timerSeconds > 0 ? Colors.grey : AppColors.primaryAmber,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading && state.action == 'verify';
        return CustomButton(
          text: 'Verify & Proceed',
          onPressed: isLoading ? null : _verifyOtp,
          isLoading: isLoading,
          backgroundColor: AppColors.primaryDarkGreen,
          textColor: Colors.white,
          height: 50,
          borderRadius: 8,
          borderColor: AppColors.primaryDarkGreen,
        );
      },
    );
  }
}
