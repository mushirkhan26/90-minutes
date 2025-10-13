import 'package:flutter/material.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String employeeId;
  const ChangePasswordScreen({super.key, required this.employeeId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter new password',
                  maxLines: 1,
                  isPassword: true,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                        text: 'Change Password',
                        onPressed: () async {
                          final newPassword = _passwordController.text.trim();
                          if (newPassword.isEmpty) return;

                          setState(() => _isLoading = true);
                          final success = await authProvider.changePassword(
                            widget.employeeId,
                            newPassword,
                          );
                          setState(() => _isLoading = false);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Password changed successfully')),
                            );
                            context.goToLogin();
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Failed to change password')));
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
