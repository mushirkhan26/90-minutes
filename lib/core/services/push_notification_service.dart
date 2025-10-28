import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/api/network/auth_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final LoggingService _logger = LoggingService.instance;

  /// 🚀 Initialize Push Notification Service
  Future<void> init() async {
    _logger.logNetwork("🚀 Initializing Push Notification Service...");

    // 🔧 Initialize Local Notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) handleNotificationTap(response.payload!);
      },
    );

    // 🧩 Updated — Only check permissions silently (App Store–safe)
    await _checkPermissionsOnly();

    // ⚙️ Configure Firebase message handling
    await _configureFirebase();

    _logger.logNetwork("✅ Push Notification Service initialized");
  }

  /// 🛑 App Store–compliant permission logic — silent check only
  Future<void> _checkPermissionsOnly() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _messaging.getNotificationSettings();
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          _logger.logNetwork("✅ Notifications authorized (iOS)");
          break;
        case AuthorizationStatus.denied:
        case AuthorizationStatus.notDetermined:
          _logger.logNetwork("⚠️ Notifications not granted (iOS) — no prompt shown");
          break;
      }
    } else if (Platform.isAndroid) {
      if (await Permission.notification.isGranted) {
        _logger.logNetwork("✅ Notifications granted (Android)");
      } else {
        _logger.logNetwork("⚠️ Notifications not granted (Android) — no prompt shown");
      }
    }
  }

  /// ⚙️ Optional explicit request — should be triggered by user action (safe for App Store)
  static Future<bool> requestPermission(BuildContext context) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint('✅ User granted notification permission');
        return true;
      case AuthorizationStatus.provisional:
        debugPrint('⚠️ Provisional permission granted');
        return true;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        debugPrint('❌ User denied or did not determine permission');
        return false;
    }
  }

  /// ☁️ Configure Firebase event listeners
  Future<void> _configureFirebase() async {
    await checkAndUpdateFCMToken();

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.logNetwork("📨 Foreground FCM received: ${message.data}");
      _showLocalNotification(message);
    });

    // Background/tapped notification (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(jsonEncode(message.data));
    });

    // Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      checkAndUpdateFCMToken(newToken: token);
    });

    // 🆕 Handle terminated-state notification tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _logger.logNetwork("🆕 Notification opened from terminated state → ${initial.data}");

      // 🆕 Ensure app initialization before navigation
      Future.delayed(const Duration(seconds: 1), () async {
        if (rootNavigatorKey.currentState == null) {
          _logger.logNetwork("⏳ Waiting for app context...");
          await _waitForAppContext();
        }
        handleNotificationTap(jsonEncode(initial.data));
      });
    }
  }

  // 🆕 Helper to ensure the app is fully loaded before navigation
  Future<void> _waitForAppContext() async {
    int retries = 0;
    while (rootNavigatorKey.currentState == null && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }
  }

  /// 🔁 Token Check & Update
  static Future<void> checkAndUpdateFCMToken({String? newToken}) async {
    final logger = LoggingService.instance;
    final storage = SecureStorageService();
    final auth = AuthService();
    final messaging = FirebaseMessaging.instance;

    try {
      final userData = await storage.getUserData();
      if (userData == null || userData['employeeId'] == null) {
        logger.logNetwork("⚠️ Not logged in → skipping token update");
        return;
      }

      if (Platform.isIOS) {
        final apns = await messaging.getAPNSToken();
        if (apns == null) {
          logger.logNetwork("🍏 Waiting for APNs token...");
          return;
        }
      }

      final currentToken = newToken ?? await messaging.getToken();
      if (currentToken == null) {
        logger.logNetwork("❌ Failed to get FCM token.");
        return;
      }
      // 🔹 Log the token explicitly so you can copy it
      logger.logNetwork("🔑 Current FCM token: $currentToken", level: LogLevel.warning);

      final saved = await storage.getAppToken();
      if (saved != currentToken) {
        final empId = userData['employeeId'];
        logger.logNetwork("🔁 Updating new FCM token → $currentToken");
        final response = await auth.updateFCMToken(employeeId: empId, appToken: currentToken);

        if (response.success) {
          await storage.saveAppToken(currentToken);
          logger.logNetwork("✅ Token updated on server successfully");
        } else {
          logger.logNetwork("❌ Server token update failed → ${response.message}");
        }
      } else {
        logger.logNetwork("✅ Token unchanged");
      }
    } catch (e) {
      logger.logNetwork("❌ Error updating FCM token: $e");
    }
  }

  /// 🎯 Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? "📩 New Notification";
    final body = message.notification?.body ?? "You have a new message";
    final payload = jsonEncode(message.data);

    const android = AndroidNotificationDetails(
      'push_channel',
      'Push Notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 🧭 Handle notification taps — navigates to chat screen
  static void handleNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload);
      final context = rootNavigatorKey.currentState?.context;

      if (context == null) {
        LoggingService.instance.logNetwork("⚠️ Context not ready, skipping navigation");
        return;
      }

      // ✅ Safe navigation to Chat screen
      final path = '${AppRoutes.chatRoute}/${data['otherUserId']}';
      context.push(
        path,
        extra: {
          'currentUserData': {
            'employeeId': data['currentUserId'],
            'username': data['currentUserName'],
          },
          'otherUserName': data['otherUserName'],
        },
      );
    } catch (e) {
      LoggingService.instance.logNetwork("❌ Notification tap error: $e");
    }
  }

  /// 📩 Handle background messages
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    final logger = LoggingService.instance;
    logger.logNetwork("📩 Background FCM received: ${message.data}");
    final service = PushNotificationService();
    await service._showLocalNotification(message);
  }
}
