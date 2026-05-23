import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_90/config/navigation/app_router.dart';
import 'package:delivery_90/config/theme/app_theme.dart';
import 'package:delivery_90/core/services/local_storage_service.dart';
import 'package:delivery_90/core/services/logger_service.dart';
import 'package:delivery_90/core/services/push_notification_service.dart';
import 'package:delivery_90/core/socket/socket_service.dart';
import 'package:delivery_90/features/auth/bloc/auth_bloc.dart';
import 'package:delivery_90/features/auth/bloc/auth_event.dart';
import 'package:delivery_90/core/services/secure_storage_service.dart';
import 'package:delivery_90/core/api/network/auth_service.dart';
import 'package:delivery_90/features/cart/bloc/cart_bloc.dart';
import 'package:delivery_90/features/cart/bloc/cart_event.dart';
import 'package:delivery_90/features/home/bloc/product_bloc.dart';
import 'package:delivery_90/features/search/bloc/search_bloc.dart';
import 'package:delivery_90/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:delivery_90/features/tracking/bloc/tracking_bloc.dart';
import 'package:delivery_90/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "keys.env");
  await LoggingService.instance.initialize();
  await LocalStorageService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService().init();
  SocketService.instance.init();

  FirebaseMessaging.onBackgroundMessage(
    PushNotificationService.firebaseMessagingBackgroundHandler,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            secureStorage: SecureStorageService(),
            localStorage: LocalStorageService(),
            authService: AuthService(),
          )..add(AppStarted()),
        ),
        BlocProvider(create: (_) => CartBloc()..add(LoadCart())),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => WishlistBloc()),
        BlocProvider(create: (_) => TrackingBloc()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '90-min Fashion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
