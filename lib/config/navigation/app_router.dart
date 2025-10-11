import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/errors/error_screen.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/auth/screens/change_password_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/login_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/verify_otp_screen.dart';
import 'package:hrtz_hrms/features/home/screens/home_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/forgot_pass_page.dart';
import 'package:hrtz_hrms/splash_screen.dart';
import 'package:provider/provider.dart';

/// 👮 Auth guard: redirect user based on login state
String? authGuard(BuildContext context, GoRouterState state) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  if (authProvider.state == AuthState.authenticated) {
    return null; // ✅ allow access
  } else {
    return AppRoutes.loginRoute; // ❌ redirect to login
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashRoute,
  errorBuilder: (context, state) =>
      ErrorScreen(error: state.error?.toString() ?? 'Unknown error occurred'),

  routes: [
    /// 🌀 Splash Route
    GoRoute(
      path: AppRoutes.splashRoute,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    /// 🔐 Login Route
    GoRoute(
      path: AppRoutes.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordScreen,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    /// 🏠 Home Route (protected)
    GoRoute(
      path: AppRoutes.homeRoute,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      redirect: (context, state) => authGuard(context, state),
    ),

    GoRoute(
      path: AppRoutes.verifyOtpRoute,
      name: 'verify-otp',
      builder: (context, state) {
        final employeeId = state.extra as String;
        return VerifyOtpScreen(employeeId: employeeId);
      },
    ),

    GoRoute(
      path: AppRoutes.changePaswordRoute,
      name: 'change-password',
      builder: (context, state) {
        final employeeId = state.extra as String;
        return ChangePasswordScreen(employeeId: employeeId);
      },
    ),
  ],
);

extension AuthNavigation on BuildContext {
  void goToHome() => go(AppRoutes.homeRoute);
  void goToLogin() => go(AppRoutes.loginRoute);
  void goToSplash() => go(AppRoutes.splashRoute);
}
