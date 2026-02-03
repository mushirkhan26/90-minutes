import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/task_service.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class TasksProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final LoggingService _logger = LoggingService.instance;

  List<Task> _allItems = [];
  List<Task> _standaloneTasks = [];
  List<dynamic> _currentSubtasks = [];
  List<dynamic> _currentComments = [];
  List<dynamic> _currentActivityLogs = []; 
  
  bool _isLoading = false;
  bool _isSubtaskLoading = false;
  bool _isCommentLoading = false;
  bool _isLogLoading = false;
  String _selectedFilter = 'all';
  
  int _totalTasks = 0;
  int _totalSubtasks = 0;
  int _totalItems = 0;

  List<Task> get allTasksList => _allItems;
  List<Task> get standaloneTasks => _standaloneTasks;
  List<dynamic> get currentSubtasks => _currentSubtasks;
  List<dynamic> get currentComments => _currentComments;
  List<dynamic> get currentActivityLogs => _currentActivityLogs; 
  
  bool get isLoading => _isLoading;
  bool get isSubtaskLoading => _isSubtaskLoading;
  bool get isCommentLoading => _isCommentLoading;
  bool get isLogLoading => _isLogLoading;
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

  /// 📋 Manually set activity logs (e.g. from standalone task object)
  void setActivityLogs(List<dynamic> logs) {
    _currentActivityLogs = logs;
    notifyListeners();
  }

  /// 📋 Fetch All Standalone Tasks (Doc 3.7)
  Future<void> fetchStandaloneTasks() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _taskService.getStandaloneTasks();
      if (response.success && response.data != null) {
        final List<dynamic> itemsJson = response.data!['message'] ?? [];
        _standaloneTasks = itemsJson.map((json) => Task.fromMap(json)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 Fetch dynamic items from API (Doc 8.1)
  Future<void> fetchTasks(String employeeId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _taskService.getAssignedItems(employeeId);
      if (response.success && response.data != null) {
        final message = response.data!['message'];
        final summary = message['summary'];
        _totalItems = summary['totalItems'] ?? 0;
        _totalTasks = summary['totalTasks'] ?? 0;
        _totalSubtasks = summary['totalSubtasks'] ?? 0;
        final List<dynamic> itemsJson = message['allItems'] ?? [];
        _allItems = itemsJson.map((json) => Task.fromMap(json)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📋 Fetch Subtasks
  Future<void> fetchSubtasks(String taskId) async {
    try {
      _isSubtaskLoading = true;
      notifyListeners();
      final response = await _taskService.getSubtasks(taskId);
      if (response.success && response.data != null) {
        _currentSubtasks = response.data!['message'] ?? [];
      }
    } finally {
      _isSubtaskLoading = false;
      notifyListeners();
    }
  }

  /// 📋 Fetch Activity Logs (Using Sprint Tasks API per requirement)
  Future<void> fetchActivityLogs(String sprintId) async {
    if (sprintId.isEmpty) return;
    try {
      _isLogLoading = true;
      notifyListeners();
      final response = await _taskService.getAllTasksBySprint(sprintId);
      if (response.success && response.data != null) {
        _currentActivityLogs = response.data!['message'] ?? []; 
      }
    } finally {
      _isLogLoading = false;
      notifyListeners();
    }
  }

  /// 📋 Fetch Comments
  Future<void> fetchComments(String taskId) async {
    try {
      _isCommentLoading = true;
      notifyListeners();
      final response = await _taskService.getComments(taskId, 'task');
      if (response.success && response.data != null) {
        _currentComments = response.data!['message'] ?? [];
      }
    } finally {
      _isCommentLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Task Operations
  Future<void> addTask(Task task, String employeeId) async {
    final response = await _taskService.addTask(task);
    if (response.success) {
      await fetchStandaloneTasks();
      await fetchTasks(employeeId);
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data, String employeeId) async {
    final response = await _taskService.updateTask(taskId, data);
    if (response.success) {
      await fetchStandaloneTasks();
      await fetchTasks(employeeId);
      // Refresh logs
      final currentTask = _standaloneTasks.followedBy(_allItems).firstWhere((t) => t.id == taskId);
      if (currentTask.sprintId != null && currentTask.sprintId!.isNotEmpty) {
        await fetchActivityLogs(currentTask.sprintId!);
      } else {
        setActivityLogs(currentTask.activityLog);
      }
    }
  }

  Future<void> addComment(Map<String, dynamic> data, String taskId) async {
    final response = await _taskService.createComment(data);
    if (response.success) {
      await fetchComments(taskId);
    }
  }

  /// ❤️ Toggle Like
  Future<void> toggleCommentLike(String commentId, String employeeId, String taskId) async {
    final response = await _taskService.toggleLike(commentId, employeeId);
    if (response.success) {
      await fetchComments(taskId);
    }
  }

  Future<void> createSubtask(Map<String, dynamic> data, String taskId) async {
    final response = await _taskService.createSubtask(data);
    if (response.success) {
      await fetchSubtasks(taskId);
    }
  }

  Future<void> updateSubtaskStatus(String subtaskId, String employeeId, String status, String taskId) async {
    final response = await _taskService.updateSubtaskStatus(subtaskId, employeeId, status);
    if (response.success) {
      await fetchSubtasks(taskId);
    }
  }

  Future<void> deleteSubtask(String subtaskId, String taskId) async {
    final response = await _taskService.deleteSubtask(subtaskId);
    if (response.success) {
      await fetchSubtasks(taskId);
    }
  }

  Future<void> updateTaskStatus(String taskId, String employeeId, String status) async {
    final response = await _taskService.updateTaskStatus(taskId, employeeId, status);
    if (response.success) {
      await fetchStandaloneTasks();
      await fetchTasks(employeeId);
    }
  }

  Future<void> deleteTask(String taskId, String employeeId) async {
    final response = await _taskService.deleteTask(taskId);
    if (response.success) {
      await fetchStandaloneTasks();
      await fetchTasks(employeeId);
    }
  }
}
