import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/navigation/app_state_provider.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/services/local_notifications_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/config/theme/app_theme.dart';
import 'package:hrtz_hrms/core/services/push_notification_service.dart';
import 'package:hrtz_hrms/core/socket/group_socket_provider.dart';
import 'package:hrtz_hrms/core/socket/socket_provider.dart';
import 'package:hrtz_hrms/core/socket/socket_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/home/provider/clock_provider.dart';
import 'package:hrtz_hrms/features/leave/provider/leave_provider.dart';
import 'package:hrtz_hrms/features/mail/provider/mail_provider.dart';
import 'package:hrtz_hrms/features/meet/providers/meet_provider.dart';
import 'package:hrtz_hrms/features/holiday/provider/holiday_provider.dart';
import 'package:hrtz_hrms/features/social/provider/social_provider.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/firebase_options.dart';
import 'package:hrtz_hrms/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "keys.env");

  // Initialize logging service
  await LoggingService.instance.initialize();
  // Initialize local storage before runApp
  await LocalStorageService.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //  Initialize Push Notification Service early (for terminated-state handling)
  await PushNotificationService().init();

  // Initialize socket connection (will connect but not join)
  SocketService.instance.init();

  // 🧩 Register background FCM handler (important for background/terminated messages)
  FirebaseMessaging.onBackgroundMessage(
    PushNotificationService.firebaseMessagingBackgroundHandler,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider(create: (_) => GroupSocketProvider()),
        ChangeNotifierProvider(create: (_) => MeetProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => HolidayProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider<MailProvider>(
          create: (_) => MailProvider()..fetchInbox(),
        ),

        ChangeNotifierProvider(
          create: (_) => ClockProvider()
            ..getAttendance(
              date:
                  '${DateTime.now().toUtc().toIso8601String().split('T')[0]}T00:00:00Z',
            ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    SplashScreen.onSplashComplete = () {
      // Update app readiness via provider
      Provider.of<AppStateProvider>(
        rootNavigatorKey.currentContext!,
        listen: false,
      ).setAppReady(true);
    };
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocalNotificationService().init();
      if (PushNotificationService.pendingPayload != null) {
        final payload = PushNotificationService.pendingPayload!;
        LoggingService.instance.logNetwork(
          "🕹️ App launched via terminated notification payload → $payload",
        );
        // Wait for splash to complete
        while (!Provider.of<AppStateProvider>(
          rootNavigatorKey.currentContext!,
          listen: false,
        ).isAppReady) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        LoggingService.instance.logNetwork(
          "🚦 Router ready check done, processing notification tap...",
        );
        PushNotificationService.handleNotificationTap(payload);
        PushNotificationService.pendingPayload = null;
      } else {
        LoggingService.instance.logNetwork(
          "ℹ️ No pending payload on app start",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Router Configuration
      routerConfig: appRouter,

      // Localization (if needed in future)
      // locale: const Locale('en', 'US'),
      // supportedLocales: const [
      //   Locale('en', 'US'),
      // ],

      // Builder for global configurations
      builder: (context, child) {
        return MediaQuery(
          // Prevent font scaling beyond reasonable limits
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
