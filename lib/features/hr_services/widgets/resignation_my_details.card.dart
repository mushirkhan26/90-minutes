import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResignationMyDetailsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResignationMyDetailsCard({
    super.key,
    required this.data,
  });

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    return DateFormat('dd MMMM yyyy').format(DateTime.parse(date));
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFFDFF9E6);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFFF4D6); // pending
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// STATUS BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  status.toLowerCase() == 'accepted'
                      ? Icons.check_circle
                      : status.toLowerCase() == 'rejected'
                          ? Icons.cancel
                          : Icons.info,
                  color: _statusText(status),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status: ${status[0].toUpperCase()}${status.substring(1)}\n'
                    'Your resignation has been ${status.toLowerCase()}.',
                    style: TextStyle(
                      color: _statusText(status),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// MAIN CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Resignation Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _item('Employee ID', data['employeeId']),
                _item('Name', data['name']),
                _item(
                    'Resignation Date',
                    _formatDate(data['resignationDate'])),
                _item(
                    'Last Working Date',
                    _formatDate(data['lastWorkingDay'])),
                _item('Reporting Manager', data['managerName'] ?? '-'),
                _item('Manager ID', data['managerId'] ?? '-'),

                const SizedBox(height: 8),

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

                const SizedBox(height: 14),

                _item(
                  'Submitted On',
                  _formatDate(data['createdOn']),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                /// DOCUMENT MESSAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.close, color: Color(0xFFDC2626)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Download period has expired.\n'
                          'Please contact HR department if you need access to these documents.',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                          ),
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
    );
  }

  Widget _item(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}