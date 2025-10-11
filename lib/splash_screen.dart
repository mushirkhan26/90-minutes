import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAuthCheck();
  }

  Future<void> _initAuthCheck() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.checkAuthState();

    if (authProvider.state == AuthState.authenticated) {
      if (!mounted) return;
      context.go(AppRoutes.homeRoute);
    } else {
      if (!mounted) return;
      context.go(AppRoutes.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
