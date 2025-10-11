import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:hrtz_hrms/auth/auth_provider.dart';
import 'package:hrtz_hrms/common/widgets/custom_button.dart';
import 'package:hrtz_hrms/common/widgets/custom_textfield.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_employeeIdController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Employee ID and Password')),
      );
      return;
    }

    // final response = await authProvider.login(
    //   _employeeIdController.text.trim(),
    //   _passwordController.text.trim(),
    // );

    // if (response != null && response.success) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(response.message)));
    //   // TODO: Navigate to home/dashboard
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: Utils().width(context) * 0.8,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/login_image.jpg'),
                  ),
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Please log in to continue',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'Employee Id',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(controller: _employeeIdController),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      CustomTextField(
                        controller: _passwordController,
                        maxLines: 1,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: '********',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        context.go(AppRoutes.forgotPasswordScreen);
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // authProvider.isLoading
                  //     ? const CircularProgressIndicator()
                  //     :
                  CustomButton(
                    text: 'Login',
                    onPressed: () async => _login(context),
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
