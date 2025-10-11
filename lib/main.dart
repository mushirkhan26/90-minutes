import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/theme/app_theme.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Initialize local storage before runApp
  await LocalStorageService.init();

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
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
