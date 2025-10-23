import 'package:flutter/material.dart';

import '../../../core/models/mail_model.dart';

class MailDetail extends StatelessWidget {
  final Mail mail;
  const MailDetail({required this.mail, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From:'),
              Text(
                '${mail.sender} - ${mail.senderName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Receiver:'),
              Text(
                '${mail.receiver} - ${mail.receiverName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Subject:'),
              Text(mail.subject, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Body:'),
              Text(mail.body, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
