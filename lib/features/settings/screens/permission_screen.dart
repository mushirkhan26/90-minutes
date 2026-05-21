import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/alert_utils.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final LoggingService _logger = LoggingService.instance;

  bool _notificationGranted = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// 🔍 Checks current permission state without requesting
  Future<void> _checkPermissions() async {
    setState(() => _checking = true);

    bool granted = false;

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      granted = await Permission.notification.isGranted;
    }

    setState(() {
      _notificationGranted = granted;
      _checking = false;
    });

    _logger.logNetwork("🔎 Notification permission granted: $granted");
  }

  /// 🙋 Requests permission via PushNotificationService method
  Future<void> _requestNotificationPermission() async {
    await PushNotificationService().checkAndRequestPermissions();

    // 🔁 Recheck status after requesting
    await _checkPermissions();

    if (_notificationGranted) {
      _logger.logNetwork("✅ User enabled notification permission manually");
      if (mounted) {
        AlertHelper.snackBarSuccess(context, "Notifications enabled successfully.");
      }
    } else {
      _logger.logNetwork("❌ User denied notification permission manually");
      if (mounted) {
        AlertHelper.snackBarWarning(context, "Permission denied. Enable from Settings.");
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("App Permissions"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔔 Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We use notifications to alert you when you receive new messages or updates. "
              "You can choose to enable them below.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _notificationGranted ? "Enabled ✅" : "Disabled ❌",
                  style: TextStyle(
                    fontSize: 16,
                    color: _notificationGranted ? Colors.green : Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(_notificationGranted ? Icons.settings : Icons.notifications_active),
                  label: Text(_notificationGranted ? "Open Settings" : "Enable Notifications"),
                  onPressed: _notificationGranted
                      ? _openAppSettings
                      : _requestNotificationPermission,
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "⚙️ You can manage permissions later in system settings.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
