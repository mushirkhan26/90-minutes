import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:hrtz_hrms/auth/auth_provider.dart';
import 'package:hrtz_hrms/common/widgets/custom_button.dart';
import 'package:hrtz_hrms/common/widgets/custom_textfield.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getOtp(BuildContext context) async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_employeeIdController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your Employee ID')));
      return;
    }

    // final response = await authProvider.getOtp(
    //   _employeeIdController.text.trim(),
    // );

    // if (response != null && response.success) {
    //   setState(() => _otpSent = true);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('OTP sent successfully: ${response.message}')),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
    //     ),
    //   );
    // }
  }

  Future<void> _verifyOtp(BuildContext context) async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    final otp = int.tryParse(_otpController.text.trim());
    if (otp == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP format')));
      return;
    }

    // final response = await authProvider.verifyOtp(
    //   _employeeIdController.text.trim(),
    //   otp,
    // );

    // if (response != null && response.success) {
    //   setState(() => _otpVerified = true);
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(response.message)));
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(authProvider.errorMessage ?? 'OTP verification failed'),
    //     ),
    //   );
    // }
  }

  Future<void> _changePassword(BuildContext context) async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a new password')));
      return;
    }

    // final response = await authProvider.changePassword(
    //   _employeeIdController.text.trim(),
    //   _newPasswordController.text.trim(),
    // );

    // if (response != null && response.success) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Password changed successfully')));
    //   Navigator.pop(context);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(authProvider.errorMessage ?? 'Password change failed'),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          heightFactor: 1,
          child: SizedBox(
            width: Utils().width(context) * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset('assets/images/forpass.png'),
                  SizedBox(height: 20),
                  Text(
                    'Forgot Password',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'Employee ID',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        controller: _employeeIdController,
                        maxLines: 1,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter your Employee ID',
                      ),
                      SizedBox(height: 15),
                      // authProvider.isLoading
                      //     ? CircularProgressIndicator()
                      //     :
                      CustomButton(
                        text: 'Submit',
                        onPressed: () async {
                          // await authProvider.getOtp('employeeId'),
                        },
                      ),
                      const SizedBox(height: 20),
                      if (!_otpSent)
                        // authProvider.isLoading
                        //     ? const CircularProgressIndicator()
                        //     :
                        // ElevatedButton(
                        //   onPressed: () => _getOtp(context),
                        //   style: ElevatedButton.styleFrom(
                        //     minimumSize: const Size(double.infinity, 50),
                        //   ),
                        //   child: const Text('Get OTP'),
                        // ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.loginRoute),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back),
                              const SizedBox(width: 10),
                              Text('Back to login', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      if (_otpSent && !_otpVerified) ...[
                        const SizedBox(height: 20),
                        TextField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            labelText: 'Enter OTP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // authProvider.isLoading
                        //     ? const CircularProgressIndicator()
                        //     :
                        ElevatedButton(
                          onPressed: () => _verifyOtp(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Verify OTP'),
                        ),
                      ],
                      if (_otpVerified) ...[
                        const SizedBox(height: 20),
                        TextField(
                          controller: _newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        // authProvider.isLoading
                        //     ? const CircularProgressIndicator()
                        //     :
                        ElevatedButton(
                          onPressed: () => _changePassword(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Change Password'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
