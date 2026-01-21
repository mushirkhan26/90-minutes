import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../provider/mail_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';

import '../../../core/models/mail_model.dart';

class MailTile extends StatelessWidget {
  final MailModel mail;
  final bool isTrash;
  final bool isSent; // ✅ Added to distinguish between Inbox and Sent

  /// ✅ Whether this tile is currently selected (for multi-selection mode)
  final bool isSelected;

  /// ✅ Whether the whole screen is currently in selection mode
  final bool isSelectionMode;

  /// 🧩 Callbacks
  final VoidCallback onMoveToTrash;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback? onToggleSelect; // For checkbox toggle

  const MailTile({
    super.key,
    required this.mail,
    required this.isTrash,
    this.isSent = false, // ✅ Default to false
    required this.isSelected,
    required this.isSelectionMode,
    required this.onMoveToTrash,
    required this.onRestore,
    required this.onDelete,
    this.onToggleSelect,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat('hh:mm a').format(time);
    } else {
      return DateFormat('dd MMM').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Logic to show recipient name in Sent folder
    final String displayName = isSent 
        ? (mail.receiverName.isNotEmpty ? mail.receiverName.join(", ") : mail.receiver.join(", "))
        : mail.senderName;

    return InkWell(
      onTap: isSelectionMode 
          ? onToggleSelect 
          : () => context.pushNamed(AppRoutes.mailDetail, extra: mail),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: isSelected ? AppColors.primary.withValues(alpha: .08) : Colors.white,
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: AppColors.primary.withValues(alpha: .5), width: 1.2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) => onToggleSelect?.call(),
                ),
                const SizedBox(width: 6),
              ],

              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            mail.isStarred ? Icons.star : Icons.star_border,
                            color: mail.isStarred ? Colors.amber : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => context.read<MailProvider>().toggleStarMail(mail),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(mail.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),

                    Text(
                      mail.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),

                    Text(
                      mail.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),

              if (!isSelectionMode)
                PopupMenuButton<String>(
                  tooltip: "More",
                  onSelected: (value) {
                    if (value == 'moveToTrash') {
                      onMoveToTrash();
                    } else if (value == 'restore') {
                      onRestore();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (isTrash) {
                      return [
                        const PopupMenuItem(value: 'restore', child: Text('Restore')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete Permanently')),
                      ];
                    } else {
                      return [
                        const PopupMenuItem(value: 'moveToTrash', child: Text('Move to Trash')),
                      ];
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
