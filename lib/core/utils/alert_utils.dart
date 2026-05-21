import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AlertHelper {
  // ------------------- SnackBar -------------------
  static void snackBarError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.white,
      iconColor: AppColors.errorRed,
      textColor: Colors.black,
      icon: Icons.error_outline,
      borderColor: AppColors.errorRed.withValues(alpha: 0.3),
    );
  }

  static void snackBarSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.white,
      iconColor: AppColors.primaryDarkGreen,
      textColor: Colors.black,
      icon: Icons.check_circle_outline,
      borderColor: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
    );
  }

  static void snackBarInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.white,
      iconColor: AppColors.blue0056FB,
      textColor: Colors.black,
      icon: Icons.info_outline,
      borderColor: AppColors.blue0056FB.withValues(alpha: 0.3),
    );
  }

  static void snackBarWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.white,
      iconColor: AppColors.primaryAmber,
      textColor: Colors.black,
      icon: Icons.warning_amber_outlined,
      borderColor: AppColors.primaryAmber.withValues(alpha: 0.3),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required Color borderColor,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
