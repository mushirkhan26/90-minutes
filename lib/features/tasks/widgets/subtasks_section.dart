import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';

class SubtasksSection extends StatelessWidget {
  final TasksProvider provider;
  final String employeeId;
  final Task task;
  final bool isReadOnly;
  final VoidCallback onAddSubtask;

  const SubtasksSection({
    super.key,
    required this.provider,
    required this.employeeId,
    required this.task,
    required this.isReadOnly,
    required this.onAddSubtask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              Icons.checklist_rtl_outlined,
              "Subtasks ${provider.currentSubtasks.length}",
            ),
            if (!isReadOnly)
              TextButton.icon(
                onPressed: onAddSubtask,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add subtask"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(provider),
        const SizedBox(height: 16),
        _buildSubtasksTable(provider, employeeId, task.id),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF263238)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF263238),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(TasksProvider provider) {
    final int total = provider.currentSubtasks.length;
    if (total == 0) return const SizedBox.shrink();
    final int done = provider.currentSubtasks
        .where((s) => s['status'] == 'Done')
        .length;
    final double progress = done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${(progress * 100).toInt()}% Complete",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              "$done/$total",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildSubtasksTable(TasksProvider provider, String employeeId, String taskId) {
    if (provider.isSubtaskLoading && provider.currentSubtasks.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (provider.currentSubtasks.isEmpty){
      return const Text(
        "No subtasks created.",
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontSize: 13,
        ),
      );}
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FixedColumnWidth(110),
          2: FixedColumnWidth(50),
        },
        children: provider.currentSubtasks.map<TableRow>((s) {
          return TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  s['title'] ?? "",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildSubtaskStatusDropdown(s, provider, employeeId, taskId),
              ),
              if (!isReadOnly)
                IconButton(
                  onPressed: () => provider.deleteSubtask(
                    s['subtaskId'] ?? s['_id'],
                    taskId,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtaskStatusDropdown(
    dynamic subtask,
    TasksProvider provider,
    String employeeId,
    String taskId,
  ) {
    final List<String> subtaskStatuses = [
      'To Do',
      'In Progress',
      'In Review',
      'Review Completed',
      'Done',
    ];

    return PopupMenuButton<String>(
      onSelected: (val) => provider.updateSubtaskStatus(
        subtask['subtaskId'] ?? subtask['_id'],
        employeeId,
        val,
        taskId,
      ),
      itemBuilder: (ctx) => subtaskStatuses
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(subtask['status']).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtask['status'] ?? "ToDo",
              style: TextStyle(
                fontSize: 11,
                color: _getStatusColor(subtask['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ToDo':
      case 'To Do':
        return Colors.grey;
      case 'In Progress':
        return Colors.blue;
      case 'In Review':
        return Colors.orange;
      case 'Review Completed':
        return Colors.purple;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
