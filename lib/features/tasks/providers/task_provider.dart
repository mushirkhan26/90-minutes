import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/task_service.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class TasksProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final LoggingService _logger = LoggingService.instance;

  List<Task> _allItems = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  
  // Counters from API summary
  int _totalTasks = 0;
  int _totalSubtasks = 0;
  int _totalItems = 0;

  List<Task> get allTasksList => _allItems;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  int get totalTasksCount => _totalTasks;
  int get subtasksCount => _totalSubtasks;
  int get totalItemsCount => _totalItems;

  List<Task> get tasks {
    if (_selectedFilter == 'tasks') {
      return _allItems.where((item) => item.itemType == 'task').toList();
    } else if (_selectedFilter == 'subtasks') {
      return _allItems.where((item) => item.itemType == 'subtask').toList();
    }
    return _allItems;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// 🔄 Fetch dynamic items from API (Documentation 8.1)
  Future<void> fetchTasks(String employeeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _taskService.getAssignedItems(employeeId);
      if (response.success && response.data != null) {
        final message = response.data!['message'];
        final summary = message['summary'];
        
        // Update Counters
        _totalItems = summary['totalItems'] ?? 0;
        _totalTasks = summary['totalTasks'] ?? 0;
        _totalSubtasks = summary['totalSubtasks'] ?? 0;

        // Update List
        final List<dynamic> itemsJson = message['allItems'] ?? [];
        _allItems = itemsJson.map((json) => Task.fromMap(json)).toList();
        
        _logger.logNetwork('✅ Items fetched: ${_allItems.length}');
      } else {
        _logger.error('TASKS_PROVIDER', 'Failed to fetch items: ${response.message}');
      }
    } catch (e) {
      _logger.error('TASKS_PROVIDER', 'Error in fetchTasks', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Added missing addTask method
  Future<void> addTask(Task task, String employeeId) async {
    final response = await _taskService.addTask(task);
    if (response.success) {
      await fetchTasks(employeeId);
    }
  }

  /// ✏️ Added missing updateTask method (mapped to updateTaskStatus for now as per doc)
  Future<void> updateTask(Task task, String employeeId) async {
    final response = await _taskService.updateTaskStatus(task.id, employeeId, task.status);
    if (response.success) {
      await fetchTasks(employeeId);
    }
  }

  /// 🗑️ Added missing deleteTask method
  Future<void> deleteTask(String taskId, String employeeId) async {
    final response = await _taskService.deleteTask(taskId);
    if (response.success) {
      await fetchTasks(employeeId);
    }
  }

  Future<void> updateTaskStatus(String taskId, String employeeId, String status) async {
    final response = await _taskService.updateTaskStatus(taskId, employeeId, status);
    if (response.success) {
      await fetchTasks(employeeId);
    }
  }
}
