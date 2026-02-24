import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:intl/intl.dart';

class GeneralHRTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const GeneralHRTaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF26A69A)),
                    const SizedBox(width: 6),
                    Text(
                      task.taskKey,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _buildPriorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple.shade100, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.purple[50],
                    child: Text(
                      task.assignees.isNotEmpty ? task.assignees.first[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMM dd, yyyy').format(task.deadline),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.blue;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
