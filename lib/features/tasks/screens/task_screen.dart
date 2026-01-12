import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/tasks/providers/task_provider.dart';
import 'package:hrtz_hrms/features/tasks/widgets/add_edit_task_dialog.dart';
import 'package:provider/provider.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddEditTaskDialog(
                  onSave: (task) {
                    tasksProvider.addTask(task);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    // Implement filtering logic
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'all', child: Text('All Tasks')),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    const PopupMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tasksProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = tasksProvider.tasks[index];
                return TaskCard(
                  task: task,
                  onEdit: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddEditTaskDialog(
                        task: task,
                        onSave: (updatedTask) {
                          tasksProvider.updateTask(updatedTask);
                        },
                      ),
                    );
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              tasksProvider.deleteTask(task.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
