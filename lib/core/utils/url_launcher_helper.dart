import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> launchUrlString(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) {
          // fallback to in-app
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      } else {
        // fallback if no external app found
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      debugPrint("UrlLauncher error: $e");
      rethrow;
    }
  }
}
