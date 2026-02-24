
import 'package:flutter/material.dart';

class TaskDetailHeader extends StatelessWidget {
  final String employeeId;
  final bool isReadOnly;
  final VoidCallback onDelete;

  const TaskDetailHeader({
    super.key,
    required this.employeeId,
    required this.isReadOnly,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Task Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (!isReadOnly)
            IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
