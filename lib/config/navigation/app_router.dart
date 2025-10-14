import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/navigation/navigation_host.dart';
import 'package:hrtz_hrms/core/errors/error_screen.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/auth/screens/change_password_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/login_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/verify_otp_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/chat_screen.dart';
import 'package:hrtz_hrms/features/home/screens/home_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/forgot_pass_page.dart';
import 'package:hrtz_hrms/features/mail/screens/mail_screen.dart';
import 'package:hrtz_hrms/features/meet/screens/meet_screen.dart';
import 'package:hrtz_hrms/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../features/meet/screens/schedule_meet.dart';
import '../../features/meet/widgets/meet_widget.dart';

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
    /// 🌀 Splash
    GoRoute(
      path: AppRoutes.splashRoute,
      name: 'splash',
      pageBuilder: (context, state) => buildTransitionPage(const SplashScreen()),
      builder: (context, state) => const MeetScreen(),
      // MeetWidget(),
    ),

    /// 🔐 Login
    GoRoute(
      path: AppRoutes.loginRoute,
      name: 'login',
      pageBuilder: (context, state) => buildTransitionPage(const LoginScreen()),
    ),

    /// 🔑 Forgot Password
    GoRoute(
      path: AppRoutes.forgotPasswordScreen,
      name: 'forgot-password',
      pageBuilder: (context, state) => buildTransitionPage(const ForgotPasswordScreen()),
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

    /// Navigation Shell for main app after login
    /// This wraps Home, Chat, Meet, Mail in a persistent bottom nav
    /// 🏠 Shell route for Main Navigation
    ShellRoute(
      builder: (context, state, child) => NavigationHost(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.homeRoute,
          name: 'home',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) => buildTransitionPage(const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.chatRoute,
          name: 'chat',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) => buildTransitionPage(const ChatScreen()),
        ),
        GoRoute(
          path: AppRoutes.meetRoute,
          name: 'meet',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) => buildTransitionPage(const MeetScreen()),
        ),
        GoRoute(
          path: AppRoutes.mailRoute,
          name: 'mail',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) => buildTransitionPage(const MailScreen()),
        ),
      ],

      // Meet Route
    ),

    // Schedule Meet Route
    GoRoute(
      path: AppRoutes.scheduleMeetScreen,
      name: '/scedule-meet',
      builder: (context, state) => const ScheduleMeet(),
    ),

    // Meet Tail Route
    GoRoute(
      path: AppRoutes.meetWidget,
      name: '/meet-tail',
      builder: (context, state) => const MeetWidget(),
    ),
  ],
);

extension AuthNavigation on BuildContext {
  void goToHome() => go(AppRoutes.homeRoute);
  void goToLogin() => go(AppRoutes.loginRoute);
  void goToSplash() => go(AppRoutes.splashRoute);
  void goToMeet() => go(AppRoutes.meetRoute);
}

/// ✨ Custom transition page helper
CustomTransitionPage buildTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 🪄 Fade + Slide from right
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0), // slight slide from right
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
