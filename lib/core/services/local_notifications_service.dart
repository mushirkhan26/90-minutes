import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

class LocalNotificationService {
  // Singleton pattern
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final LoggingService _logger = LoggingService.instance;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Initialize notification plugin
  Future<void> init() async {
    // Android Initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We handle iOS permission separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          _logger.logNetwork("[NotificationService] Notification tapped: ${response.payload}");
          try {
            final data = jsonDecode(response.payload!);
            final path = '${AppRoutes.chatRoute}/${data['otherUserId']}';

            // ✅ Navigate using root navigator key
            rootNavigatorKey.currentState!.context.push(
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
            _logger.logNetwork("[NotificationService] ❌ Failed to navigate on tap: $e");
          }
        }
      },
    );

    _logger.logNetwork("[NotificationService] ✅ Local Notification Service initialized");

    await _requestPermissions();
  }

  /// Requests notification permissions for iOS and Android 13+
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ runtime permission using permission_handler
      try {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          final result = await Permission.notification.request();
          _logger.logNetwork(
            "[NotificationService] Android notification permission granted: $result",
          );
        }
      } catch (e) {
        _logger.logNetwork("[NotificationService] ❌ Error requesting Android permission: $e");
      }
    } else if (Platform.isIOS) {
      await requestIOSPermissions();
    }
  }

  /// Explicit iOS permission request
  Future<void> requestIOSPermissions() async {
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      _logger.logNetwork("[NotificationService] iOS notification permission requested");
    }
  }

  /// Show or update consolidated notification
  Future<void> showConsolidatedNotification({
    required int totalUnreadCount,
    required int totalUsers,
    Map<String, dynamic>? currentUserData,
    String? singleUserId,
    String? singleUserName,
  }) async {
    try {
      String title;
      String body;
      String? payload;

      if (totalUsers == 1 && singleUserName != null) {
        // Single user → show sender name
        title = "📩 New message";
        body = "New message from $singleUserName";
        // Payload includes full chat info
        payload = jsonEncode({
          'currentUserId': currentUserData?['employeeId'] ?? '',
          'currentUserName': currentUserData?['username'] ?? '',
          'otherUserId': singleUserId,
          'otherUserName': singleUserName,
        });
      } else {
        // Multiple users → show aggregated info
        title = "💬 New messages";
        body = "$totalUnreadCount new messages from $totalUsers users";
      }

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        'chat_channel',
        'Chat Notifications',
        channelDescription: 'Shows incoming chat notifications',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        styleInformation: BigTextStyleInformation(''),
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      final iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Show notification with **fixed ID** to update instead of stacking
      await _plugin.show(1001, title, body, notificationDetails, payload: payload);

      _logger.logNetwork(
        "[NotificationService] Showed notification → $title | $body | payload: $payload",
      );
    } catch (e) {
      _logger.logNetwork("[NotificationService] ❌ Failed to show notification: $e");
    }
  }

  /// Clear consolidated notification
  Future<void> clearNotifications() async {
    await _plugin.cancel(1001);
    _logger.logNetwork("[NotificationService] Cleared notifications");
  }
}
