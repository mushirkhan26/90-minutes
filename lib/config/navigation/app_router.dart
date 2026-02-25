import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/navigation/navigation_host.dart';
import 'package:hrtz_hrms/core/errors/error_screen.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/auth/screens/change_password_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/login_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/onboarding_form_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/verify_otp_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/chat_list_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/chat_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/group_chat_details_screen.dart';
import 'package:hrtz_hrms/features/chat/screens/group_chat_screens.dart';
import 'package:hrtz_hrms/features/employee_benefits/screens/benefits_screen.dart';
import 'package:hrtz_hrms/features/holiday/screen/holiday_calendar_screen.dart';
import 'package:hrtz_hrms/features/leaderboard/screens/admin_leaderboard_screen.dart';
import 'package:hrtz_hrms/features/hr_services/screens/new_registrations_screen.dart';
import 'package:hrtz_hrms/features/hr_services/screens/performance_screen.dart';
import 'package:hrtz_hrms/features/hr_services/screens/previous_reviews_screen.dart';
import 'package:hrtz_hrms/features/leave/screens/leave_request_screen.dart'; 
import 'package:hrtz_hrms/features/leave/screens/admin_leave_approval_screen.dart';
import 'package:hrtz_hrms/features/home/widgets/face_verification.dart';
import 'package:hrtz_hrms/features/home/screens/home_screen.dart';
import 'package:hrtz_hrms/features/auth/screens/forgot_pass_page.dart';
import 'package:hrtz_hrms/features/mail/screens/mail_detail.dart';
import 'package:hrtz_hrms/features/mail/screens/mail_screen.dart';
import 'package:hrtz_hrms/features/meet/screens/meet_screen.dart';
import 'package:hrtz_hrms/features/notifications/screens/notification_screen.dart';
import 'package:hrtz_hrms/features/settings/screens/permission_screen.dart';
import 'package:hrtz_hrms/features/social/screens/social_hub_screen.dart';
import 'package:hrtz_hrms/features/tasks/screens/task_screen.dart';
import 'package:hrtz_hrms/features/tasks/screens/general_hr_tasks_screen.dart';
import 'package:hrtz_hrms/features/hr_services/screens/resignation_screen.dart';
import 'package:hrtz_hrms/features/complaint/provider/complaint_provider.dart';
import 'package:hrtz_hrms/features/hr_services/provider/resignation_provider.dart';
import 'package:hrtz_hrms/features/complaint/screens/my_complaints_screen.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/features/learning_studio/screens/learning_studio_screen.dart';
import 'package:hrtz_hrms/features/employee_directory/screens/employee_directory_screen.dart';
import 'package:hrtz_hrms/features/hr_employee_task/screens/compliance_center_screen.dart';
import 'package:hrtz_hrms/features/documents/screens/my_documents_screen.dart';


import 'package:hrtz_hrms/splash_screen.dart';

import 'package:provider/provider.dart';

import '../../features/auth/screens/nda_screen_form.dart';
import '../../features/home/screens/profile_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/mail/screens/compose_mail_screen.dart';

import '../../features/meet/screens/schedule_meet.dart';
import 'package:hrtz_hrms/features/service_request/screens/service_requests_screen.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';
import 'package:hrtz_hrms/features/tasks/screens/manage_tasks_screen.dart';
import 'package:hrtz_hrms/features/tasks/screens/add_project_screen.dart';
import 'package:hrtz_hrms/payroll_documents/screens/payroll_documents_screen.dart';

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
      pageBuilder: (context, state) =>
          buildTransitionPage(const SplashScreen()),
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
      pageBuilder: (context, state) =>
          buildTransitionPage(const ForgotPasswordScreen()),
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

    /// 📄 NDA Screen
    GoRoute(
      path: AppRoutes.ndaRoute,
      name: 'nda',
      pageBuilder: (context, state) => buildTransitionPage(const NdaScreen()),
    ),

    /// 📝 Onboarding Screen
    GoRoute(
      path: AppRoutes.onboardingRoute,
      name: 'onboarding',
      pageBuilder: (context, state) =>
          buildTransitionPage(const OnboardingFormScreen()),
    ),

    /// Navigation Shell for main app after login
    ShellRoute(
      builder: (context, state, child) => NavigationHost(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.homeRoute,
          name: 'home',
          pageBuilder: (context, state) =>
              buildTransitionPage(const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.chatRoute,
          name: 'chat',
          pageBuilder: (context, state) =>
              buildTransitionPage(const ChatListScreen()),
        ),
        GoRoute(
          path: AppRoutes.meetRoute,
          name: 'meet',
          redirect: (context, state) => authGuard(context, state),
          pageBuilder: (context, state) =>
              buildTransitionPage(const MeetScreen()),
        ),
        GoRoute(
          path: AppRoutes.mailRoute,
          name: 'mail',
          pageBuilder: (context, state) =>
              buildTransitionPage(const MailScreen()),
        ),
        GoRoute(
          path: AppRoutes.mailDetail,
          name: '/mail_detail',
          pageBuilder: (context, state) => buildTransitionPage(
            MailDetailsScreen(mail: state.extra as MailModel),
          ),
        ),
      ],
    ),

    // individual chat route
    GoRoute(
      path: '${AppRoutes.chatRoute}/:otherUserId',
      name: 'individual-chat',
      builder: (context, state) {
        final otherUserId = state.pathParameters['otherUserId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final otherUserName = extra?['otherUserName'] ?? 'User';
        final currentUserData =
            extra?['currentUserData'] as Map<String, dynamic>?;

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

    // Compose Mail Route
    GoRoute(
      path: AppRoutes.composeMail,
      name: '/compose-mail',
      builder: (context, state) => const ComposeMailScreen(),
    ),

    GoRoute(
      path: AppRoutes.permissionsRoute,
      name: '/permissions',
      pageBuilder: (context, state) =>
          buildTransitionPage(const PermissionsScreen()),
    ),

    GoRoute(
      path: AppRoutes.faceverification,
      name: '/face-verification',
      builder: (context, state) =>
          FaceVerification(isClockIn: true, onVerified: () {}),
    ),

    GoRoute(
      path: AppRoutes.userProfile,
      name: '/user-profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.leaveRequest,
      name: '/leave-request',
      builder: (context, state) => const LeaveRequestScreen(),
    ),

    GoRoute(
      path: AppRoutes.adminLeaveApproval,
      name: '/admin-leave-approval',
      builder: (context, state) => const AdminLeaveApprovalScreen(),
    ),

    GoRoute(
      path: AppRoutes.holidayCalendar,
      name: '/holiday-calendar',
      builder: (context, state) => const HolidayCalendarScreen(),
    ),

    GoRoute(
      path: AppRoutes.tasksRoute,
      name: '/tasks',
      builder: (context, state) => const TasksScreen(),
    ),

    GoRoute(
      path: AppRoutes.generalHrTasks,
      name: 'general-hr-tasks',
      builder: (context, state) => const GeneralHRTasksScreen(),
    ),

    GoRoute(
      path: AppRoutes.socialHub,
      name: '/social-hub',
      builder: (context, state) => const SocialHubScreen(),
    ),

    GoRoute(
      path: AppRoutes.resignation,
      name: '/resignation',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => ResignationProvider(),
          child: const ResignationScreen(),
        );
      },
    ),
    
    GoRoute(
      path: AppRoutes.complaint,
      name: '/complaint',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => ComplaintProvider()..fetchComplaints(),
          child: MyComplaintsScreen(),
        );
      },
    ),
    GoRoute(
  path: AppRoutes.serviceRequest,
  name: 'service-request',
  builder: (context, state) {
    return ChangeNotifierProvider(
      create: (_) => ServiceRequestProvider(),
      child: const ServiceRequestsScreen(),
    );
  },
),
     GoRoute(
      path: AppRoutes.learningStudio,
      name: 'learning-studio',
      pageBuilder: (context, state) => buildTransitionPage(const LearningStudioScreen()),
    ),
    GoRoute(
      path: AppRoutes.employeeBenefits,
      name: 'employee-benefits',
      pageBuilder: (context, state) => buildTransitionPage(const BenefitsScreen()),
    ),
    GoRoute(
      path: AppRoutes.newRegistrations,
      name: '/new-registrations',
      builder: (context, state) => const NewRegistrationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeDirectory,
      name: '/employee-directory',
      builder: (context, state) => const EmployeeDirectoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.performance,
      name: '/performance',
      builder: (context, state) => const PerformanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.previousReviews,
      name: '/previous-reviews',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PreviousReviewsScreen(
          employeeName: extra['employeeName'],
          employeeId: extra['employeeId'],
        );
      },
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminLeaderboard,
      name: 'admin-leaderboard',
      builder: (context, state) => const AdminLeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.manageTasks,
      name: 'manage-tasks',
      builder: (context, state) => const ManageTasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.addProject,
      name: 'add-project',
      builder: (context, state) => const AddProjectScreen(),
    ),
    GoRoute(
      path: AppRoutes.payrollDocuments,
      name: 'payroll-documents',
      builder: (context, state) => const PayrollDocumentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.complianceCenter,
      name: 'compliance-center',
      builder: (context, state) => const ComplianceCenterScreen(),
    ),
    GoRoute(
      path: AppRoutes.myDocuments,
      name: 'my-documents',
      builder: (context, state) => const MyDocumentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);

extension GlobalRouter on GoRouter {
  static GoRouter get router => appRouter;
  void pushByPath(String path, {Object? extra}) {
    router.push(path, extra: extra);
  }
}

extension AuthNavigation on BuildContext {
  void goToHome() => go(AppRoutes.homeRoute);
  void goToLogin() => go(AppRoutes.loginRoute);
  void goToSplash() => go(AppRoutes.splashRoute);
  void goToMeet() => go(AppRoutes.meetRoute);

  Future<void> goToIndividualChat({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final currentUserData = await getCurrentUserData();
    LoggingService.instance.info(
      'NAVIGATION',
      '👤 Opening chat with [$otherUserName] - ID: $otherUserId',
    );

    push(
      '${AppRoutes.chatRoute}/$otherUserId',
      extra: {
        'otherUserName': otherUserName,
        'currentUserData': currentUserData,
      },
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

  Future<void> goToGroupDetails({required GroupChatModel group}) async {
    LoggingService.instance.info(
      'NAVIGATION',
      '📋 Opening group details for: [${group.name}] - ID: ${group.groupId}',
    );
    push('${AppRoutes.chatRoute}/group/${group.groupId}/details', extra: group);
  }

  void goToChatList() => go(AppRoutes.chatRoute);
  void goToPermissions() => push(AppRoutes.permissionsRoute);
  void userProfile() => push(AppRoutes.userProfile);
  void leaveRequest() => push(AppRoutes.leaveRequest);
  void goToAdminLeaveApproval() => push(AppRoutes.adminLeaveApproval);
  void holidayCalendar() => push(AppRoutes.holidayCalendar);
  void goToTasks() => push(AppRoutes.tasksRoute);
  void goToGeneralHrTasks() => push(AppRoutes.generalHrTasks);
  void goToSocialHub() => push(AppRoutes.socialHub);
  void goToNewRegistrations() => push(AppRoutes.newRegistrations);
  void goToEmployeeDirectory() => push(AppRoutes.employeeDirectory);
  void goToPerformance() => push(AppRoutes.performance);
  void goToPreviousReviews(String name, String id) => push(AppRoutes.previousReviews, extra: {'employeeName': name, 'employeeId': id});
  void goToLeaderboard() => push(AppRoutes.leaderboard);
  void goToAdminLeaderboard() => push(AppRoutes.adminLeaderboard);
  void goToManageTasks() => push(AppRoutes.manageTasks);
  void goToPayrollDocuments() => push(AppRoutes.payrollDocuments);
  void goToComplianceCenter() => push(AppRoutes.complianceCenter);
  void goToMyDocuments() => push(AppRoutes.myDocuments);
  void goToNotifications() => push(AppRoutes.notifications);
}

CustomTransitionPage buildTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
