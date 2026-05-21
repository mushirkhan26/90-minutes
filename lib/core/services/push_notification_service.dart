import 'dart:convert';
import 'dart:io';
import 'package:delivery_90/core/services/secure_storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/navigation/app_router.dart';
import '../../config/navigation/app_routes.dart';
import '../api/network/auth_service.dart';
import 'logger_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static String? pendingPayload; // 🧩 Store payload temporarily

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
    await checkAndRequestPermissions();

    // ⚙️ Configure Firebase message handling
    await _configureFirebase();

    _logger.logNetwork("✅ Push Notification Service initialized");
  }

  /// 🛑 Check permissions and request once if not granted
  Future<void> checkAndRequestPermissions() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _messaging.getNotificationSettings();

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          _logger.logNetwork("✅ Notifications authorized (iOS)");
          // ✅ Proceed to token check once permission is granted
          await checkAndUpdateFCMToken();
          break;

        case AuthorizationStatus.denied:
        case AuthorizationStatus.notDetermined:
          _logger.logNetwork("⚠️ Notifications not granted (iOS) → requesting...");
          final granted = await _messaging.requestPermission(alert: true, badge: true, sound: true);
          if (granted.authorizationStatus == AuthorizationStatus.authorized ||
              granted.authorizationStatus == AuthorizationStatus.provisional) {
            _logger.logNetwork("✅ User granted iOS notification permission after prompt");
            await checkAndUpdateFCMToken();
          } else {
            _logger.logNetwork("❌ User denied iOS notification permission");
          }
          break;
      }
    } else if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        _logger.logNetwork("✅ Notifications granted (Android)");
        await checkAndUpdateFCMToken();
      } else {
        _logger.logNetwork("⚠️ Notifications not granted (Android) → requesting...");
        final result = await Permission.notification.request();
        if (result.isGranted) {
          _logger.logNetwork("✅ User granted Android notification permission after prompt");
          await checkAndUpdateFCMToken();
        } else {
          _logger.logNetwork("❌ User denied Android notification permission");
        }
      }
    }
  }

  /// ☁️ Configure Firebase event listeners
  Future<void> _configureFirebase() async {
    // 🧩 Don't 'await' token update, let it run in background so app doesn't hang
    checkAndUpdateFCMToken();

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

    //  Terminated state (launched by tapping notification)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _logger.logNetwork("🆕 App opened from terminated state → ${initial.data}");
      pendingPayload = jsonEncode(initial.data);
    } else {
      _logger.logNetwork("ℹ️ No initial notification payload (cold launch)");
    }
  }

  // 🕐 Wait for router/context readiness
  Future<void> waitForAppContext() async {
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
        final response = await auth.updateFCMToken(userId: empId, appToken: currentToken);

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

  static Future<void> handleNotificationTap(String payload, {int attempt = 0}) async {
    final logger = LoggingService.instance;
    try {
      logger.logNetwork(
        "🧭 handleNotificationTap called (attempt $attempt) with payload: $payload",
      );

      final context = rootNavigatorKey.currentState?.context;
      if (context == null) {
        if (attempt < 10) {
          logger.logNetwork("⏳ Context not ready → retrying in 300ms (attempt ${attempt + 1})");
          await Future.delayed(const Duration(milliseconds: 300));
          return handleNotificationTap(payload, attempt: attempt + 1);
        }
        logger.logNetwork("❌ Navigation failed → context never became ready after 10 retries");
        return;
      }

      final data = jsonDecode(payload);

      // 🧩 Normalize payload keys for both Message and GroupMessage types
      final type = data['type'];
      Map<String, dynamic> mappedData = {};
      if (type == 'Message') {
        // 💬 Individual Chat Notification
        mappedData = {
          'currentUserId': data['receiver'], // current user
          'currentUserName': data['reciverName'], // current user's name
          'otherUserId': data['sender'], // sender ID
          'otherUserName': data['senderName'], // sender name
          'type': 'Message',
        };
      } else if (type == 'GroupMessage') {
        // 👥 Group Chat Notification
        mappedData = {
          'groupId': data['groupId'],
          'groupName': data['groupName'] ?? 'Group Chat',
          'currentUserId': data['employeeId'] ?? data['receiver'],
          'currentUserName': data['reciverName'] ?? 'You',
          'type': 'GroupMessage',
        };
      } else {
        logger.logNetwork("🚫 Unknown notification type → ${data['type']}");
        return;
      }

      // 🧾 Log normalized result
      logger.logNetwork("📦 Normalized Notification Data → $mappedData");

      // 🧭 Route navigation based on type
      if (mappedData['type'] == 'Message') {
        logger.logNetwork("🚀 Navigating to Individual Chat Screen...");
        context.push(
          '${AppRoutes.chatRoute}/${mappedData['otherUserId']}',
          extra: {
            'otherUserName': mappedData['otherUserName'],
            'currentUserData': {
              'employeeId': mappedData['currentUserId'],
              'username': mappedData['currentUserName'],
            },
          },
        );
      } else if (mappedData['type'] == 'GroupMessage') {
        logger.logNetwork("🚀 Navigating to Group Chat Screen...");
        context.push(
          '${AppRoutes.chatRoute}/group/${mappedData['groupId']}',
          extra: {
            'groupName': mappedData['groupName'],
            'currentUserId': mappedData['currentUserId'],
            'currentUserName': mappedData['currentUserName'],
            'groupModel': null, // can be fetched later if needed
          },
        );
      }
    } catch (e, s) {
      logger.logNetwork("❌ Exception in handleNotificationTap: $e");
      logger.logNetwork("📄 Stack trace: $s");
    }
  }

  /// 📩 Handle background messages
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // final logger = LoggingService.instance;
    // logger.logNetwork("📩 Background FCM received: ${message.data}");
    // final service = PushNotificationService();
    // await service._showLocalNotification(message);
  }
}
