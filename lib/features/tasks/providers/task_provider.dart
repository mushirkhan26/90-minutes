import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void fetchTasks() {
    // Replace with actual API call
    _tasks = [
      Task(
        id: '1',
        title: 'Complete HRMS Module',
        description: 'Finish the tasks management module for the HRMS app.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: 'In Progress',
        priority: 'High',
        assignedTo: 'Kashish Sharma',
        assignedBy: 'Manager',
      ),
      Task(
        id: '2',
        title: 'Review Leave Requests',
        description: 'Review and approve pending leave requests.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'Pending',
        priority: 'Medium',
        assignedTo: 'Kashish Sharma',
        assignedBy: 'HR',
      ),
    ];
    notifyListeners();
  }
}
