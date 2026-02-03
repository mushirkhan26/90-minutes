import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hrtz_hrms/features/hr_services/provider/resignation_provider.dart';
import 'package:provider/provider.dart';

class ResignationDetailsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onApprove;

  const ResignationDetailsCard({
    super.key,
    required this.data,
    this.onApprove,
  });

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
  }

  String _formatDateTime(String? date) {
    if (date == null || date.isEmpty) return '-';
    final dt = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
  }

  int _remainingDays(String? lastDate) {
    if (lastDate == null) return 0;
    return DateTime.parse(lastDate)
        .difference(DateTime.now())
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingDays(data['lastWorkingDay']);
    final status = data['status'] ?? '-';
    final isAccepted = status.toString().toLowerCase() == 'accepted';
    final isPending = status.toString().toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAME + ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF9F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: ${data['employeeId'] ?? '-'}',
                    style: const TextStyle(
                      color: Color(0xFF2F9E9E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _detailRow(
              'Resignation:',
              _formatDate(data['resignationDate']),
            ),
            _detailRow(
              'Last Day:',
              _formatDate(data['lastWorkingDay']),
            ),
            _detailRow(
              'Remaining:',
              remaining <= 0 ? 'Completed' : '$remaining days',
            ),

            /// STATUS
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 160,
                    child: Text(
                      'Status:',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// REASON
            const Text(
              'Reason:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['reason'] ?? '-',
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
            ),

            const SizedBox(height: 14),

            /// DOCUMENTS
            const Text(
              'Documents:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),

            if ((data['documents'] as List?)?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  data['documents'].length,
                  (index) {
                    final doc =
                        data['documents'][index] as Map<String, dynamic>;
                    final String fileName = doc['name'] ?? 'Document';
                    final String fileUrl = doc['url'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(fileUrl)),
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Text('-'),

            const SizedBox(height: 4),

            /// ACTIONS
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

                _squareActionButton(
                  icon: Icons.remove_red_eye_outlined,
                  bgColor: const Color(0xFFF2F3F5),
                  iconColor: Colors.black87,
                  onTap: () {
                    _showResignationDetailsSheet(context, data);
                  },
                ),

                if (isAccepted)
                  _squareActionButton(
                    icon: Icons.file_upload_outlined,
                    bgColor: const Color(0xFFDFF9F3),
                    iconColor: const Color(0xFF2F9E9E),
                    onTap: () {
                      _showUploadDocumentDialog(parentContext: context, data: data);
                    },
                  )
                else if (isPending)
                  _squareActionButton(
                    icon: Icons.edit_outlined,
                    bgColor: const Color(0xFFDFF9F3),
                    iconColor: const Color(0xFF2F9E9E),
                    onTap: () {
                      _showUpdateStatusDialog(parentContext: context, data: data);
                    },
                  ),
              ],
            ),

            const SizedBox(height: 6),

            if (onApprove != null && isPending) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F9E9E),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ACTION BUTTON
  Widget _squareActionButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String status) {
  final s = status.toLowerCase();

  Color bgColor;
  Color textColor;

  if (s == 'accepted') {
    bgColor = const Color(0xFFDFF9E6); // green
    textColor = const Color(0xFF22C55E);
  } else if (s == 'rejected') {
    bgColor = const Color(0xFFFEE2E2); // red
    textColor = const Color(0xFFEF4444);
  } else {
    bgColor = const Color(0xFFFFF4D6); // pending orange
    textColor = const Color(0xFFF59E0B);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    ),
  );
}
  

  /// BOTTOM SHEET
  void _showResignationDetailsSheet(
      BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Resignation Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                _verticalItem('Employee Name', data['name']),
                _verticalItem('Employee ID', data['employeeId']),
                _verticalItem('Resignation ID', data['resignationId']),
                _verticalItem('Resignation Date', data['resignationDate']),
                _verticalItem('Last Working Day', data['lastWorkingDay']),

                const Text(
                  'Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                _statusChip(data['status'] ?? '-'),
                const SizedBox(height: 12),

                _verticalItem(
                    'Created On', _formatDateTime(data['createdOn'])),
                _verticalItem(
                    'Updated On', _formatDateTime(data['updatedOn'])),

                const SizedBox(height: 12),

                const Text(
                  'Reason',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(data['reason'] ?? '-'),
                ),

                const SizedBox(height: 20),

                Align(
  alignment: Alignment.centerRight,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade200, // 👈 grey background
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      child: const Text(
        'Close',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
  ),
),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _verticalItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? '-',
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
  void _showUpdateStatusDialog({
    required BuildContext parentContext,
    required Map<String, dynamic> data,
  }) {
  String selectedStatus = data['status'] ?? 'Pending';

  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Update Status for ${data['name']}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
                DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
              ],
              onChanged: (v) => setState(() => selectedStatus = v!),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F9E9E),
            ),
            onPressed: () async{
             final provider =
                  parentContext.read<ResignationProvider>();
                  final success =
                      await provider.updateResignationStatus(
                    resignationId: data['resignationId'],
                    status: selectedStatus,
                    comments: data['comments'] ?? '',
                  );
                  if(!context.mounted) return;
                  if(success) {
                    Navigator.of(context).pop();
                    await provider.fetchAllResignations();
                    
                  }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
 void _showUploadDocumentDialog({
  required BuildContext parentContext,
  required Map<String, dynamic> data,
}) {
  final TextEditingController urlController = TextEditingController();
  bool isUploading = false;

  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Upload Document',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document URL',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://file_upload.com/document.pdf',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              /// ❌ CANCEL
              TextButton(
                onPressed:
                    isUploading ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),

              /// ✅ UPLOAD
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E), // green
                ),
                onPressed: (urlController.text.isNotEmpty && !isUploading)
                    ? () async {
                        final documentUrl =
                            urlController.text.trim();

                        debugPrint("🚀 UPLOAD CLICKED");
                        debugPrint("resignationId: ${data['resignationId']}");
                        debugPrint("documentUrl: $documentUrl");

                        setState(() => isUploading = true);

                        final provider =
                            parentContext.read<ResignationProvider>();

                        final success =
                            await provider.uploadDocument(
                          resignationId: data['resignationId'],
                          documentUrl: documentUrl,
                        );
                        if(!dialogContext.mounted) return;


                        setState(() => isUploading = false);

                        if (success) {
                          Navigator.pop(dialogContext);
                          provider.fetchAllResignations();
                          provider.fetchMyResignation();
                        }
                      }
                    : null,
                child: isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Upload'),
              ),
            ],
          );
        },
      );
    },
  );
}
}