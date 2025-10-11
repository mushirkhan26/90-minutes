import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/common/widgets/custom_button.dart';
import 'package:hrtz_hrms/common/widgets/custom_textfield.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/core/utils/validators.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await authProvider.login(employeeId, password);

      if (authProvider.state == AuthState.authenticated) {
        if (context.mounted) {
          AlertHelper.snackBarSuccess(context, 'Logged in successfully!');
          context.go(AppRoutes.homeRoute);
        }
      } else if (authProvider.state == AuthState.error) {
        if (context.mounted) {
          AlertHelper.snackBarWarning(context, authProvider.errorMessage ?? 'Login failed');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AlertHelper.snackBarError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          heightFactor: 1.1,
          child: SizedBox(
            width: Utils().width(context) * 0.85,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/login_image.jpg'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text('Please log in to continue', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 15),

                  // Employee ID
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Employee Id',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _employeeIdController,
                        validator: (value) =>
                            Validators.validateName(value, fieldName: 'Employee Id'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          'Password',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _passwordController,
                        maxLines: 1,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: '********',
                        validator: (value) => Validators.validateName(value, fieldName: 'Password'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        context.go(AppRoutes.forgotPasswordScreen);
                      },
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  authProvider.state == AuthState.loading
                      ? const CircularProgressIndicator()
                      : CustomButton(text: 'Login', onPressed: () => _handleLogin(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
