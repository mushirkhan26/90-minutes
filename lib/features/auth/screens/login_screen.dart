import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/alert_utils.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/auth_header.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/mobile_number_input.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // ✅ Track recognizers for disposal to prevent memory leaks
  final List<TapGestureRecognizer> _gestureRecognizers = [];
  String? _mobileError;

  @override
  void dispose() {
    _mobileController.dispose();
    for (final r in _gestureRecognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _handleLogin() {
    final mobile = _mobileController.text.trim();
    final error = Validators.validatePhone(mobile);

    setState(() {
      _mobileError = error;
    });

    if (error == null) {
      context.read<AuthBloc>().add(LoginRequested(mobile));
    }
  }

  void _launchUrl(String url) async {
    try {
      await UrlLauncherHelper.launchUrlString(url);
    } catch (e) {
      if (mounted) {
        AlertHelper.snackBarError(context, 'Could not open link');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            AlertHelper.snackBarSuccess(context, 'OTP sent successfully!');
            context.push(AppRoutes.verifyOtpRoute, extra: state.mobile);
          } else if (state is AuthError) {
            AlertHelper.snackBarError(context, state.message);
          }
        },
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const AuthHeader(
                                    title: 'LuxeDrop',
                                    subtitle:
                                        'Your Wardrobe, Delivered in\n90 Mins',
                                  ),
                                  MobileNumberInput(
                                    controller: _mobileController,
                                    errorText: _mobileError,
                                    onChanged: (value) {
                                      if (_mobileError != null) {
                                        setState(() {
                                          _mobileError = null;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  _buildGetOtpButton(),
                                ],
                              ),
                            ),
                            _buildFooter(),
                          ],
                        ),
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

  Widget _buildGetOtpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading && state.action == 'login';
        return CustomButton(
          text: 'Get OTP',
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
          backgroundColor: AppColors.primaryAmber,
          textColor: Colors.black,
          height: 50,
          borderRadius: 8,
          borderColor: AppColors.primaryAmber,
          image: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
          imagePosition: ImagePosition.trailing,
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our\n'),
            _linkText('Terms & Conditions', 'https://luxedrop.in/terms'),
            const TextSpan(text: ' and '),
            _linkText('Privacy Policy', 'https://luxedrop.in/privacy'),
          ],
        ),
      ),
    );
  }

  TextSpan _linkText(String text, String url) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(url);
    _gestureRecognizers.add(recognizer);

    return TextSpan(
      text: text,
      style: const TextStyle(
        decoration: TextDecoration.underline,
        color: AppColors.primaryDarkGreen,
        fontWeight: FontWeight.w500,
      ),
      recognizer: recognizer,
    );
  }
}



