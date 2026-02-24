import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/features/tasks/widgets/comments_section.dart';
import 'package:hrtz_hrms/features/tasks/widgets/subtasks_section.dart';
import 'package:hrtz_hrms/features/tasks/widgets/task_attachments_section.dart';
import 'package:hrtz_hrms/features/tasks/widgets/task_description_section.dart';
import 'package:provider/provider.dart';

class TaskDetailMainContent extends StatelessWidget {
  final Task task;
  final String employeeId;
  final String employeeName;
  final bool isReadOnly;
  final Function(String) onOpenAttachment;
  final VoidCallback onAddSubtask;
  final TextEditingController commentController;

  const TaskDetailMainContent({
    super.key,
    required this.task,
    required this.employeeId,
    required this.employeeName,
    required this.isReadOnly,
    required this.onOpenAttachment,
    required this.onAddSubtask,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList
            .followedBy(provider.standaloneTasks)
            .firstWhere(
              (t) => t.id == task.id,
              orElse: () => task,
            );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeaderInfo(currentTask, employeeId, provider),
              const SizedBox(height: 16),
              Text(
                currentTask.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 32),
              TaskDescriptionSection(task: currentTask),
              const SizedBox(height: 32),
              SubtasksSection(
                provider: provider,
                employeeId: employeeId,
                task: currentTask,
                isReadOnly: isReadOnly,
                onAddSubtask: onAddSubtask,
              ),
              const SizedBox(height: 32),
              TaskAttachmentsSection(
                task: currentTask,
                onOpenAttachment: onOpenAttachment,
              ),
              const SizedBox(height: 32),
              CommentsSection(
                provider: provider,
                employeeId: employeeId,
                employeeName: employeeName,
                taskId: currentTask.id,
                commentController: commentController,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskHeaderInfo(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bug_report, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              task.taskKey,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _buildPriorityChip(task.priority),
        _buildDynamicStatusDropdown(task, employeeId, provider),
      ],
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'highest':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicStatusDropdown(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    final List<String> taskStatuses = [
      'ToDo',
      'In Progress',
      'In-Review',
      'Review-completed',
      'Done',
    ];

    return PopupMenuButton<String>(
      onSelected: (String status) =>
          provider.updateTaskStatus(task.id, employeeId, status),
      itemBuilder: (BuildContext context) => taskStatuses
          .map(
            (s) => PopupMenuItem<String>(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: task.status == s
                      ? const Color(0xFF673AB7)
                      : Colors.black87,
                  fontWeight: task.status == s
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
