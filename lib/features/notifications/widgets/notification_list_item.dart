import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationIcon(notification.type),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'leave': iconData = Icons.event_note; color = Colors.blue; break;
      case 'task': iconData = Icons.assignment; color = Colors.orange; break;
      case 'attendance': iconData = Icons.access_time; color = Colors.green; break;
      case 'announcement': iconData = Icons.campaign; color = Colors.red; break;
      default: iconData = Icons.notifications; color = const Color(0xFF14B8A6);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    if (difference.inDays < 7) return "${difference.inDays}d ago";
    return DateFormat('MMM dd').format(date);
  }
}
