import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';

  List<Task> get tasks {
    List<Task> filteredTasks = _tasks;

    // Apply filter
    if (_selectedFilter != 'all') {
      filteredTasks = filteredTasks
          .where((task) =>
              task.status.toLowerCase().replaceAll(' ', '_') == _selectedFilter)
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredTasks;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

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
