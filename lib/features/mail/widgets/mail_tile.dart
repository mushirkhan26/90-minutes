import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/models/mail_model.dart';

class MailTile extends StatelessWidget {
  final Mail mail;
  const MailTile({required this.mail, super.key});

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
                style: TextStyle(
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
                        SizedBox(height: 5),
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
          ],
        ),
      ),
    );
  }
}
