import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/notifications/provider/notification_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';

class NotificationActionBar extends StatelessWidget {
  final NotificationProvider provider;
  final VoidCallback onRefresh;
  final VoidCallback onClear;

  const NotificationActionBar({
    super.key,
    required this.provider,
    required this.onRefresh,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF14B8A6),
              shape: BoxShape.circle,
            ),
            child: Text(
              "${provider.unreadCount}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Unread notifications",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ),
          
          /// Refresh Button using CustomButton (or keeping style if it looks better)
          SizedBox(
            width: 90,
            height: 35,
            child: CustomButton(
              text: "Refresh",
              onPressed: onRefresh,
              backgroundColor: const Color(0xFFF1F5F9),
              textColor: const Color(0xFF14B8A6),
              borderColor: Colors.transparent,
              fontSize: 12,
              icon: Icons.refresh,
            ),
          ),
          const SizedBox(width: 8),

          /// Clear Button using CustomButton
          SizedBox(
            width: 80,
            height: 35,
            child: CustomButton(
              text: "Clear",
              onPressed: onClear,
              backgroundColor: const Color(0xFF14B8A6),
              textColor: Colors.white,
              fontSize: 12,
              icon: Icons.delete_outline,
            ),
          ),
        ],
      ),
    );
  }
}
