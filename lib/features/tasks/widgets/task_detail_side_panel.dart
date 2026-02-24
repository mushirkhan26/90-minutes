import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskDetailSidePanel extends StatefulWidget {
  final String employeeId;
  final Task task;
  final bool isReadOnly;

  const TaskDetailSidePanel({
    super.key,
    required this.employeeId,
    required this.task,
    this.isReadOnly = false,
  });

  @override
  State<TaskDetailSidePanel> createState() => _TaskDetailSidePanelState();
}

class _TaskDetailSidePanelState extends State<TaskDetailSidePanel> {
  bool _isEditingPriority = false;

  final List<String> _taskStatuses = [
    'ToDo',
    'In Progress',
    'In-Review',
    'Review-completed',
    'Done',
  ];

  final List<String> _priorities = [
    'Lowest',
    'Low',
    'Medium',
    'High',
    'Highest',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        final currentTask = provider.allTasksList
            .followedBy(provider.standaloneTasks)
            .firstWhere(
              (t) => t.id == widget.task.id,
              orElse: () => widget.task,
            );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSideSection(
                "STATUS",
                _buildDynamicStatusDropdown(currentTask, widget.employeeId, provider),
              ),
              const SizedBox(height: 24),
              _buildSideSection(
                "PRIORITY",
                _buildPriorityEditor(currentTask, widget.employeeId, provider),
              ),
              const SizedBox(height: 24),
              _buildSideSection(
                "DUE DATE",
                _buildDueDateEditor(currentTask, widget.employeeId, provider),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "ACTIVITY LOG",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildActivityTimeline(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideSection(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDynamicStatusDropdown(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    return PopupMenuButton<String>(
      onSelected: (String status) =>
          provider.updateTaskStatus(task.id, employeeId, status),
      itemBuilder: (BuildContext context) => _taskStatuses
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

    Widget _buildPriorityEditor(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    if (widget.isReadOnly) {
      return Text(
        task.priority,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      );
    }
    if (_isEditingPriority) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: task.priority,
            isExpanded: true,
            items: _priorities
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                provider.updateTask(task.id, {"priority": val}, employeeId);
                setState(() => _isEditingPriority = false);
              }
            },
          ),
        ),
      );
    }
    return InkWell(
      onTap: () => setState(() => _isEditingPriority = true),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.priority,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDueDateEditor(
    Task task,
    String employeeId,
    TasksProvider provider,
  ) {
    final bool canEdit = !widget.isReadOnly;
    return InkWell(
      onTap: canEdit
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: task.deadline,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) {
                await provider.updateTask(task.id, {
                  "deadline": date.toUtc().toIso8601String(),
                }, employeeId);
              }
            }
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(task.deadline),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (canEdit)
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(TasksProvider provider) {
    final logs = provider.currentActivityLogs;
    if (provider.isLogLoading && logs.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (logs.isEmpty) {
      return const Text(
        "No logs available",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final bool isLast = index == logs.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF26A69A),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: Colors.grey[200]),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['logMessage'] ?? "Status updated",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log['updatedOn'] != null
                        ? DateFormat(
                            'MMM dd, hh:mm a',
                          ).format(DateTime.parse(log['updatedOn']))
                        : "Unknown",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
