import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/navigation/navigation_host.dart';
import 'package:hrtz_hrms/core/errors/error_screen.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/auth/screens/change_password_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/login_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/verify_otp_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/chat_list_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/chat_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/group_chat_details_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/group_chat_screens.dart';
import 'package:hrtz_hrms/features/home/screens/home_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/forgot_pass_page.dart';
import 'package:hrtz_hrms/features/mail/screens/mail_detail.dart';
import 'package:hrtz_hrms/features/mail/screens/mail_screen.dart';
import 'package:hrtz_hrms/features/meet/screens/meet_screen.dart';
import 'package:hrtz_hrms/features/settings/screens/permission_screen.dart';
import 'package:hrtz_hrms/splash_screen.dart';

import 'package:provider/provider.dart';

import '../../features/mail/screens/compose_mail_screen.dart';

import '../../features/meet/screens/schedule_meet.dart';
import '../../features/meet/widgets/meet_widget.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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
  navigatorKey: rootNavigatorKey,
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
          pageBuilder: (context, state) => buildTransitionPage(const ChatListScreen()),
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
        GoRoute(
          path: AppRoutes.mailDetail,
          name: '/mail_detail',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) =>
              buildTransitionPage(MailDetailsScreen(mail: state.extra as MailModel)),
        ),
      ],

      // Meet Route
    ),
    // indiviaul chat route
    GoRoute(
      path: '${AppRoutes.chatRoute}/:otherUserId',
      name: 'individual-chat',
      redirect: (context, state) => authGuard(context, state),
      builder: (context, state) {
        final otherUserId = state.pathParameters['otherUserId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final otherUserName = extra?['otherUserName'] ?? 'User';
        final currentUserData = extra?['currentUserData'] as Map<String, dynamic>?;

        return ChatScreen(
          currentUserId: currentUserData?['employeeId'] ?? '',
          currentUserName: currentUserData?['username'] ?? '',
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        );
      },
    ),
    // Group chat route
    GoRoute(
      path: '${AppRoutes.chatRoute}/group/:groupId',
      name: 'group-chat',
      redirect: (context, state) => authGuard(context, state),
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final groupModel = extra?['groupModel'] as GroupChatModel?;

        return GroupChatScreen(
          groupId: groupId,
          groupName: extra?['groupName'] ?? 'Group Chat',
          currentUserId: extra?['currentUserId'] ?? '',
          currentUserName: extra?['currentUserName'] ?? '',
          groupModel: groupModel,
        );
      },
    ),

    GoRoute(
      path: '${AppRoutes.chatRoute}/group/:groupId/details',
      name: 'group-details',
      redirect: (context, state) => authGuard(context, state),
      builder: (context, state) {
        final group = state.extra as GroupChatModel;
        return GroupDetailsScreen(group: group);
      },
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

    // Compose Mail Route
    GoRoute(
      path: AppRoutes.composeMail,
      name: '/compose-mail',
      builder: (context, state) => const ComposeMailScreen(),
    ),

    GoRoute(
      path: AppRoutes.permissionsRoute,
      name: '/permissions',
      redirect: (context, state) => authGuard(context, state),
      pageBuilder: (context, state) => buildTransitionPage(const PermissionsScreen()),
    ),
  ],
);

extension GlobalRouter on GoRouter {
  /// Returns the global app router
  static GoRouter get router => appRouter;

  /// Push by path from anywhere
  void pushByPath(String path, {Object? extra}) {
    router.push(path, extra: extra);
  }
}

extension AuthNavigation on BuildContext {
  void goToHome() => go(AppRoutes.homeRoute);
  void goToLogin() => go(AppRoutes.loginRoute);
  void goToSplash() => go(AppRoutes.splashRoute);
  void goToMeet() => go(AppRoutes.meetRoute);

  /// Navigate to individual chat with pre-fetched user data
  Future<void> goToIndividualChat({
    required String otherUserId,
    required String otherUserName,
  }) async {
    // Pre-fetch user data before navigation
    final currentUserData = await getCurrentUserData();
    LoggingService.instance.info(
      'NAVIGATION',
      '👤 Opening chat with [$otherUserName] - ID: $otherUserId',
    );

    push(
      '${AppRoutes.chatRoute}/$otherUserId',
      extra: {'otherUserName': otherUserName, 'currentUserData': currentUserData},
    );
  }

  Future<void> goToGroupChat({
    required String groupId,
    required String groupName,
    GroupChatModel? groupModel,
  }) async {
    final currentUserData = await getCurrentUserData();
    LoggingService.instance.info(
      'NAVIGATION',
      '💬 Opening group chat: [$groupName] - ID: $groupId',
    );

    push(
      '${AppRoutes.chatRoute}/group/$groupId',
      extra: {
        'groupName': groupName,
        'currentUserId': currentUserData?['employeeId'] ?? '',
        'currentUserName': currentUserData?['username'] ?? '',
        'groupModel': groupModel,
      },
    );
  }

  /// Navigate to group details screen
  Future<void> goToGroupDetails({required GroupChatModel group}) async {
    LoggingService.instance.info(
      'NAVIGATION',
      '📋 Opening group details for: [${group.name}] - ID: ${group.groupId}',
    );
    push('${AppRoutes.chatRoute}/group/${group.groupId}/details', extra: group);
  }

  /// Navigate to chat list
  void goToChatList() => go(AppRoutes.chatRoute);

  /// ⚙️ Go to Permissions Screen (new)
  void goToPermissions() => push(AppRoutes.permissionsRoute);
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
