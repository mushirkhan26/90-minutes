import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'kanban_column.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final tasks = tasksProvider.tasks;

    // Filter tasks based on API status names
    final todoTasks = tasks.where((task) => task.status == 'ToDo').toList();
    final inProgressTasks = tasks.where((task) => task.status == 'In Progress').toList();
    final inReviewTasks = tasks.where((task) => task.status == 'In-Review').toList();
    final reviewCompleteTasks = tasks.where((task) => 
      task.status == 'Review-completed' || 
      task.status == 'Done' || 
      task.status == 'Completed'
    ).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanbanColumn(
            title: 'To Do',
            icon: Icons.assignment_outlined,
            tasks: todoTasks,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          KanbanColumn(
            title: 'In Progress',
            icon: Icons.rotate_right_rounded,
            tasks: inProgressTasks,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          KanbanColumn(
            title: 'In Review',
            icon: Icons.visibility_outlined,
            tasks: inReviewTasks,
            color: Colors.purple,
          ),
          const SizedBox(width: 16),
          KanbanColumn(
            title: 'Completed',
            icon: Icons.check_circle_outline,
            tasks: reviewCompleteTasks,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
