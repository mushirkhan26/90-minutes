import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';

import '../../../core/models/mail_model.dart';

class MailDetail extends StatelessWidget {
  final Mail mail;

  const MailDetail({required this.mail, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mail',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mail.senderName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mail.sender,
                        style: TextStyle(
                          // color: AppColors.black2E2E2E,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subject
                      Text(
                        mail.subject,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Receiver
                      Row(
                        children: [
                          const Text('To : ', style: TextStyle(fontSize: 16)),
                          Text(
                            // '${mail.receiver} - ${mail.receiverName}',
                            "Me",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email Body
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.messageBox,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mail.body,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
