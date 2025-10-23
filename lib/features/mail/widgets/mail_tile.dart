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
    // required Future<Null> Function() onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.mailDetail, extra: mail);
      },
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                mail.senderName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Subject: ',
                                style: TextStyle(
                                  color: AppColors.black2E2E2E,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: mail.subject,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Body: ',
                                style: TextStyle(
                                  color: AppColors.black2E2E2E,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: mail.body,
                                style: TextStyle(
                                  color: AppColors.black2E2E2E,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    );
  }
}
