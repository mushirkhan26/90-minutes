
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/complaint_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;

  // manager side
  final bool isManagerView;
  final Future<void> Function(String status)? onUpdateStatus;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.isManagerView = false,
    this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT
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
                Text(
                  complaint.createdAtFormatted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// RIGHT
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  _openComplaintBottomSheet(context);
                },
              ),
              _statusChip(complaint.status),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS CHIP =================
  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color text;

    if (s == 'resolved') {
      bg = const Color(0xFFDFF9E6);
      text = const Color(0xFF22C55E);
    } else if (s == 'pending') {
      bg = const Color(0xFFFFF4D6);
      text = const Color(0xFFF59E0B);
    } else {
      bg = Colors.grey.shade200;
      text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  void _openComplaintBottomSheet(BuildContext context) {
    if (isManagerView) {
      _showManagerBottomSheet(context);
    } else {
      _showComplaintDetails(context);
    }
  }

  // ================= MANAGER CENTERED BOTTOM SHEET =================
  void _showManagerBottomSheet(BuildContext context) {
    String selectedStatus = complaint.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.92,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4FA3A5),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          complaint.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text("Description: ${complaint.description}"),
                      Text("Name: ${complaint.employeeName}"),
                      Text("Status: ${complaint.status}"),
                      Text("Created On: ${complaint.createdAtFormatted}"),
                      Text("Employee ID: ${complaint.employeeId}"),
                      Text("Complaint ID: ${complaint.id}"),

                      const SizedBox(height: 12),

                      /// ATTACHMENT
if (complaint.attachments.isNotEmpty)
  Builder(
    builder: (_) {
      final attachment = complaint.attachments.first;
      final isImage =  _isNetworkUrl(attachment) && _isImage(attachment);

      return GestureDetector(
        onTap: isImage
            ? () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.black,
                    insetPadding: EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: InteractiveViewer(
                        child: Image.network(
                          attachment,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: isImage
                ? DecorationImage(
                    image: NetworkImage(attachment),
                    fit: BoxFit.cover,
                  )
                : null,
            color: isImage ? null : Colors.grey.shade100,
          ),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(8),
          child: isImage
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FA3A5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "View",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
        ),
      );
    },
  ),
                      
                      const SizedBox(height: 16),

                      /// UPDATE STATUS
                      const Text(
                        "Update Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'Investigating',
                              child: Text('Investigating')),
                          DropdownMenuItem(
                              value: 'Resolved',
                              child: Text('Resolved')),
                        ],
                        onChanged: complaint.status == 'Resolved'
                            ? null
                            : (v) =>
                                setState(() => selectedStatus = v!),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed:
                                (onUpdateStatus == null ||
                                        selectedStatus ==
                                            complaint.status)
                                    ? null
                                    : () async {
                                        await onUpdateStatus!(
                                            selectedStatus);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF4FA3A5),
                            ),
                            child: const Text(
                              "Update",
                              style:
                                  TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= USER SIDE DETAILS =================
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

Container(
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.only(top: 8),
  decoration: BoxDecoration(
    color: const Color(0xFFF7F9FA),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Complaint ID",
          style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      Text(complaint.id),

      const SizedBox(height: 12),

      const Text("Category",
          style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      Text(complaint.category),

      const SizedBox(height: 12),

      const Text("Title",
          style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      Text(complaint.title),
    ],
  ),
),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
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
            const Text("Additional Info", style: TextStyle(color: Colors.grey)),
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
              await launchUrl(uri, mode: LaunchMode.externalApplication);
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

  bool _isImage(String url){
    final lower =url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.webp');
  }
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
 
}
