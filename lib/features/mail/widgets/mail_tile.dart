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
  final String? currentUserId;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onMoveToTrash;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback? onToggleSelect;

  const MailTile({
    super.key,
    required this.mail,
    required this.isTrash,
    required this.currentUserId,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onMoveToTrash,
    required this.onRestore,
    required this.onDelete,
    this.onToggleSelect,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    return now.difference(time).inDays == 0
        ? DateFormat('hh:mm a').format(time)
        : DateFormat('dd MMM').format(time);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Logic: If sent by current user, show recipients. Else show sender name.
    final bool isSentByMe = mail.sender == currentUserId;
    final String displayName = isSentByMe 
        ? "To: ${mail.receiverName.isNotEmpty ? mail.receiverName.join(", ") : mail.receiver.join(", ")}"
        : mail.senderName;

    return InkWell(
      onTap: isSelectionMode 
          ? onToggleSelect 
          : () => context.pushNamed(AppRoutes.mailDetail, extra: mail),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: isSelected ? AppColors.primary.withValues(alpha: .08) : Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected ? BorderSide(color: AppColors.primary, width: 1) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => onToggleSelect?.call(),
                ),
                const SizedBox(width: 4),
              ],
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  displayName.isNotEmpty ? displayName.replaceAll("To: ", "")[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          child: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: Icon(mail.isStarred ? Icons.star : Icons.star_border, color: mail.isStarred ? Colors.amber : Colors.grey, size: 20),
                          onPressed: () => context.read<MailProvider>().toggleStarMail(mail),
                        ),
                        Text(_formatTime(mail.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                    Text(mail.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(mail.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  ],
                ),
              ),
              if (!isSelectionMode)
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'trash') onMoveToTrash();
                    else if (val == 'restore') onRestore();
                    else if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => isTrash
                      ? [const PopupMenuItem(value: 'restore', child: Text('Restore')), const PopupMenuItem(value: 'delete', child: Text('Delete Permanently'))]
                      : [const PopupMenuItem(value: 'trash', child: Text('Move to Trash'))],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
