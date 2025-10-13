import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String employeeId;
  const VerifyOtpScreen({super.key, required this.employeeId});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: Utils().width(context) * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text('Verify OTP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    'Enter the OTP sent to ${widget.employeeId}',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: 'Go Back',
                        onPressed: () => context.go(AppRoutes.loginRoute),
                        width: Utils().width(context) * 0.38,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 12,
                      ),
                      _isLoading
                          ? CircularProgressIndicator()
                          : CustomButton(
                              text: 'Verify',
                              onPressed: () async {
                                final otp = _otpController.text.trim();
                                if (otp.isEmpty) return;

                                setState(() => _isLoading = true);
                                final success = await authProvider.verifyOtp(
                                  widget.employeeId,
                                  int.parse(otp),
                                );
                                setState(() => _isLoading = false);

                                if (success) {
                                  context.goNamed('change-password', extra: widget.employeeId);
                                } else {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('Invalid OTP or expired')));
                                }
                              },
                              width: Utils().width(context) * 0.38,
                              fontSize: 12,
                            ),
                    ],
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      setState(() => _isLoading = true);
                      await authProvider.resendOtp(widget.employeeId);
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('OTP resent')));
                    },
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Image.asset('assets/images/verification.png', height: 300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
