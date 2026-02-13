import 'package:flutter/material.dart';

/// ================= PROGRESS HISTORY CARD =================
class ProgressHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onSeeAll;
  final Function(Map<String, dynamic>)? onItemTap;

  const ProgressHistoryCard({
    super.key,
    required this.items,
    required this.onSeeAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: onSeeAll,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== LIST =====
          if(items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No progress history found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
          else
          ...items.map(
            (item) => _ProgressHistoryItem(
              data: item,
              onTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= SINGLE ITEM =================
class _ProgressHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>)? onTap;

  const _ProgressHistoryItem({
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['courseStatus'] ?? 'NotStarted';

    Color statusColor;
    if (status == 'Completed') {
      statusColor = Colors.green;
    } else if (status == 'Ongoing') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== AVATAR =====
             CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8F5F3),
              child: Text(
                _getInitials(data['name']),
                style: const TextStyle(
                  color: Color(0xFF26A69A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ===== NAME + COURSE =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['courseName'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF26A69A),
                    ),
                  ),
                ],
              ),
            ),

            // ===== STATUS + DATE =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(data['startDate']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= DATE FORMATTER =================
String _formatDate(String? date) {
  if (date == null || date.isEmpty) return '';
  final d = DateTime.tryParse(date);
  if (d == null) return '';
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

String _getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return '';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  } 
  return (parts[0][0] + parts[1][0]).toUpperCase();
}