import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';

class AlertHelper {
  // ------------------- SnackBar -------------------
  static void snackBarError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.errorRed, Icons.error);
  }

  static void snackBarSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.successColor, Icons.check_circle);
  }

  static void snackBarInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.primary2, Icons.info_outline);
  }

  static void snackBarWarning(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.warningColor, Icons.warning_amber_outlined);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
