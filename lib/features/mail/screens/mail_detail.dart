import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/features/mail/widgets/attachment_tile.dart';
import 'package:intl/intl.dart';
class MailDetailsScreen extends StatefulWidget {
  final MailModel mail;

  const MailDetailsScreen({super.key, required this.mail});

  @override
  State<MailDetailsScreen> createState() => _MailDetailsScreenState();
}

class _MailDetailsScreenState extends State<MailDetailsScreen> {
  bool _showDetails = false;

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} min ago';
    }return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final mail = widget.mail;
    final formattedDate = DateFormat(
      'EEE, MMM d • h:mm a',
    ).format(mail.createdAt);
    final timeAgo = _getTimeAgo(mail.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Inbox', style: AppTextStyles.black18_600),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Subject
            Text(mail.subject, style: AppTextStyles.black24_700),
            const SizedBox(height: 18),

            // 🧍 Sender details row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Initicon(text: mail.senderName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mail.senderName,
                                    style: AppTextStyles.black16_600,
                                  ),
                                ),
                                Text(
                                  timeAgo,
                                  style: AppTextStyles.black60alpha_12_500,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showDetails
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 22,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _showDetails = !_showDetails;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 📬 Expandable sender details like Gmail
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _showDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('From', mail.sender),
                    _buildDetailRow('To', mail.receiver.join(', ')),
                    if (mail.cc.isNotEmpty)
                      _buildDetailRow('Cc', mail.cc.join(', ')),
                    if (mail.perUserStatus['bcc'] != null)
                      _buildDetailRow(
                        'Bcc',
                        (mail.perUserStatus['bcc'] as List).join(', '),
                      ),
                    _buildDetailRow('Date', formattedDate),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),

            const Divider(height: 32, thickness: 0.6),

            // ✉️ Mail Body Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                mail.body,
                style: AppTextStyles.black14_400.copyWith(height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            // 📎 Attachments
            if (mail.attachmentUrls.isNotEmpty) ...[
              const Divider(thickness: 0.5),
              const SizedBox(height: 8),
              Text('Attachments', style: AppTextStyles.black16_600),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: mail.attachmentUrls
                    .map((url) => AttachmentTile(url: url))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: AppTextStyles.grey12_600),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.black12_400.copyWith(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
