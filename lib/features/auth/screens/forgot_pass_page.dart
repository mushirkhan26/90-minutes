import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:hrtz_hrms/auth/auth_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
                      _isLoading
                          ? CircularProgressIndicator()
                          : CustomButton(
                              text: 'Submit',
                              onPressed: () async {
                                final employeeId = _employeeIdController.text
                                    .trim();
                                if (employeeId.isEmpty) {
                                  AlertHelper.snackBarWarning(
                                    context,
                                    'Please enter your Employee ID',
                                  );
                                  return;
                                }

                                final (success, message) = await authProvider
                                    .getOtp(employeeId);

                                if (success) {
                                  AlertHelper.snackBarSuccess(context, message);
                                  if (context.mounted) {
                                    context.goNamed(
                                      'verify-otp',
                                      extra: employeeId,
                                    );
                                  }
                                } else {
                                  AlertHelper.snackBarError(context, message);
                                }
                              },
                            ),
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
