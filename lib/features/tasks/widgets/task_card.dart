import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    // Updated statuses as per documentation: "ToDo", "In Progress", "In-Review", "Review-completed", "Done"
    switch (task.status) {
      case 'ToDo':
        statusColor = Colors.grey;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'In-Review':
        statusColor = Colors.orange;
        break;
      case 'Review-completed':
      case 'Done':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color priorityColor;
    // Updated priorities as per documentation: "Lowest", "Low", "Medium", "High", "Highest"
    switch (task.priority) {
      case 'Highest':
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
      case 'Lowest':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (task.taskKey.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.taskKey,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChip(task.status, statusColor),
                const SizedBox(width: 8),
                _buildChip(task.priority, priorityColor),
                if (task.itemType != null) ...[
                  const SizedBox(width: 8),
                  _buildChip(task.itemType!.toUpperCase(), Colors.purple),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  'By: ${task.assignedBy}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha :0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
