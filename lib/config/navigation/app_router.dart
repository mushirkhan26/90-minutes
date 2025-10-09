// Router configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/errors/error_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/login_screen.dart';
import 'package:hrtz_hrms/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashRoute,
  errorBuilder: (context, state) =>
      ErrorScreen(error: state.error?.toString() ?? 'Unknown error occurred'),
  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splashRoute,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Welcome Screen
    // GoRoute(
    //   path: AppConstants.welcomeRoute,
    //   name: 'welcome',
    //   builder: (context, state) => const WelcomeScreen(),
    // ),

    // Authentication Routes
    GoRoute(
      path: AppRoutes.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // GoRoute(
    //   path: AppRoutes.otpVerificationRoute,
    //   name: 'otp-verification',
    //   builder: (context, state) {
    //     final extras = state.extra as Map<String, dynamic>?;

    //     return OTPVerificationScreen(
    //       phoneNumber: extras?['phoneNumber'] ?? "",
    //       isRegistered: extras?['isRegistered'] ?? false,
    //     );
    //   },
    // ),

    // GoRoute(
    //   path: AppConstants.registrationRoute,
    //   name: 'registration',
    //   builder: (context, state) {
    //     final phoneNumber = state.extra as String?;
    //     return RegistrationScreen(phoneNumber: phoneNumber ?? "");
    //   },
    // ),

    // Main App Shell with Bottom Navigation
    // ShellRoute(
    //   builder: (context, state, child) {
    //     return MainScaffold(child: child);
    //   },
    //   routes: [
    //     // Home
    //     GoRoute(
    //       path: AppRoutes.homeRoute,
    //       name: 'home',
    //       builder: (context, state) => const HomeScreen(),
    //     ),

    //     // Track Shipment
    //     GoRoute(path: AppConstants.trackRoute,
    //     name: 'track',
    //     builder: (context, state) => TrackScreen()
    //     ),

    //     // History
    //     // GoRoute(
    //     //   path: AppConstants.historyRoute,
    //     //   name: 'history',
    //     //   builder: (context, state) => const HistoryScreen(),
    //     // ),

    //     // Profile
    //     GoRoute(
    //       path: AppConstants.profileRoute,
    //       name: 'profile',
    //       builder: (context, state) => const ProfileScreen(),
    //     ),
    //   ],
    // ),

    // Support (standalone without bottom navigation)
    // GoRoute(
    //   path: AppRoutes.supportRoute,
    //   name: 'support',
    //   builder: (context, state) => const SupportScreen(),
    // ),
  ],
);

// Navigation extension methods
extension AppNavigation on BuildContext {
  // Basic navigation
  void goToSplash() => go(AppRoutes.splashRoute);
  void goToWelcome() => go(AppRoutes.welcomeRoute);
  void goToLogin() => go(AppRoutes.loginRoute);
  void goToHome() => go(AppRoutes.homeRoute);

  // Authentication navigation
  void goToOTPVerification({required String phoneNumber, required bool isRegistered}) {
    push(
      AppRoutes.otpVerificationRoute,
      extra: {'phoneNumber': phoneNumber, 'isRegistered': isRegistered},
    );
  }

  void goToRegistration(String phoneNumber) {
    push(AppRoutes.registrationRoute, extra: phoneNumber);
  }

  // Navigation helpers
  bool canPop() => GoRouter.of(this).canPop();

  void popOrGoHome() {
    if (canPop()) {
      pop();
    } else {
      goToHome();
    }
  }

  // Get current route information
  String get currentRoute {
    final RouteMatch lastMatch = GoRouter.of(this).routerDelegate.currentConfiguration.last;
    return lastMatch.matchedLocation;
  }

  // Check if currently on specific routes
  //   bool get isOnAuthRoute {
  //     final route = currentRoute;
  //     return route == AppConstants.loginRoute ||
  //         route.startsWith(AppConstants.otpVerificationRoute.split(':')[0]) ||
  //         route.startsWith(AppConstants.registrationRoute.split(':')[0]);
  //   }

  //   bool get isOnMainAppRoute {
  //     final route = currentRoute;
  //     return route == AppConstants.homeRoute ||
  //         route == AppConstants.trackRoute ||
  //         route == AppConstants.historyRoute ||
  //         route == AppConstants.profileRoute ||
  //         route == AppConstants.supportRoute;
  //   }

  //   // Bottom navigation helper
  //   int get currentBottomNavIndex {
  //     final route = currentRoute;
  //     switch (route) {
  //       case AppConstants.homeRoute:
  //         return 0;
  //       case AppConstants.trackRoute:
  //         return 1;
  //       case AppConstants.profileRoute:
  //         return 2;
  //       case AppConstants.historyRoute:
  //         return 3;
  //       default:
  //         return 0;
  //     }
  //   }
  // }

  // Route guard mixin for authentication
  // mixin RouteGuard {
  //   bool get requiresAuth => true;

  //   void checkAuthAndNavigate(
  //     BuildContext context,
  //     VoidCallback onAuthenticated,
  //   ) {
  //     // This would typically check authentication state
  //     // For now, we'll assume user is authenticated if not on auth routes
  //     if (context.isOnAuthRoute) {
  //       context.goToLogin();
  //     } else {
  //       onAuthenticated();
  //     }
  //   }
  // }
}
