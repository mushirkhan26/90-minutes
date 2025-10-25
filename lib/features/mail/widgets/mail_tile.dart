import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/models/mail_model.dart';

class MailTile extends StatelessWidget {
  final Mail mail;
  final bool isTrash;
  final VoidCallback onMoveToTrash;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const MailTile({
    super.key,
    required this.mail,
    required this.isTrash,
    required this.onMoveToTrash,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: GestureDetector(
        onTap: () {
          context.pushNamed(AppRoutes.mailDetail, extra: mail);
        },
        child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  mail.senderName.isNotEmpty ? mail.senderName[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mail.senderName,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mail.subject,
                        style: TextStyle(
                          color: AppColors.black2E2E2E,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
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
                      const PopupMenuItem(
                        value: 'restore',
                        child: Text('Restore'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Permanently'),
                      ),
                    ];
                  } else {
                    return [
                      const PopupMenuItem(
                        value: 'moveToTrash',
                        child: Text('Move to Trash'),
                      ),
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
