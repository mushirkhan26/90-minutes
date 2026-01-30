import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/complaint_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complaint.description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),

                /// ✅ CREATED DATE (NULL SAFE)
                  Text(
                    complaint.createdAtFormatted,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),

          /// RIGHT CONTENT
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  _showComplaintDetails(context);
                },
              ),
              _statusChip(complaint.status),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 STATUS CHIP
  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 🔹 BOTTOM SHEET
  void _showComplaintDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Complaint Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  _statusChip(complaint.status),
                  const SizedBox(height: 16),

                  /// ✅ COMPLAINT INFO
                  _sectionTitle("Complaint Information", Colors.green),
                  _infoBox(
                    leftLabel: "Complaint ID",
                    leftValue:
                        complaint.id.isNotEmpty ? complaint.id : "-",
                        
                    rightLabel: "Category",
                    rightValue: complaint.category,
                  ),
                  const SizedBox(height: 8),
                  _singleInfo("Title", complaint.title),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  _sectionTitle("Description", Colors.blue),
                  _descriptionBox(
                    complaint.description,
                    complaint.additionalInfo,
                  ),

                  const SizedBox(height: 16),

                  /// ✅ ATTACHMENT (URL LAUNCHER)
                  _sectionTitle("Attachment", Colors.purple),
                  _attachmentBox(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// INFO BOX
  Widget _infoBox({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _infoColumn(leftLabel, leftValue)),
          const SizedBox(width: 50),
          Expanded(child: _infoColumn(rightLabel, rightValue)),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _singleInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  /// DESCRIPTION BOX
  Widget _descriptionBox(String desc, String addInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc),
          if (addInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text("Additional Info",
                style: TextStyle(color: Colors.grey)),
            Text(addInfo),
          ],
        ],
      ),
    );
  }

  /// ✅ ATTACHMENT BOX WITH URL LAUNCHER
 Widget _attachmentBox() {
  if (complaint.attachments.isEmpty) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text("No attachment"),
    );
  }

  return Column(
    children: complaint.attachments.map((path) {
      final fileName = _getFileName(path);

      return InkWell(
        onTap: () async {
          final uri = Uri.parse(path);

          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}
  String _getFileName(String url) {
    try {
      return Uri.parse(url).pathSegments.last;
    } catch (e) {
      return 'Complaint Attachment';
    }
  }
}
