import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hrtz_hrms/auth/auth_provider.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/services/local_notifications_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/config/theme/app_theme.dart';
import 'package:hrtz_hrms/core/socket/socket_provider.dart';
import 'package:hrtz_hrms/core/socket/socket_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/mail/provider/mail_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "keys.env");

  // Initialize logging service
  await LoggingService.instance.initialize();
  // Initialize local storage before runApp
  await LocalStorageService.init();

  // Initialize socket connection (will connect but not join)
  SocketService.instance.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MainApp());
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🛎 Initialize local notification service after first build
      LocalNotificationService().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider<MailProvider>(create: (_) => MailProvider()..fetchInbox()),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
