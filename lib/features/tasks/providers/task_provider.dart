import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/task_service.dart';
import 'package:hrtz_hrms/core/models/task_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';

class TasksProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final LoggingService _logger = LoggingService.instance;
  final LocalStorageService _local = LocalStorageService();

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

  static const String _keyTasks = 'tasks_cache';
  static const String _keyStandaloneTasks = 'standalone_tasks_cache';
  static const String _keySubtasksPrefix = 'subtasks_cache_';
  static const String _keyCommentsPrefix = 'comments_cache_';

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

  TasksProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final employeeId = await _local.getEmployeeId();
    if (employeeId != null) {
      await _loadFromLocal();
      await fetchTasks(employeeId);
      await fetchStandaloneTasks();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final cachedTasks = await _local.getJson(_keyTasks);
      if (cachedTasks != null) {
        final message = cachedTasks['message'];
        _parseTasksFromMessage(message);
      }

      final cachedStandalone = await _local.getJson(_keyStandaloneTasks);
      if (cachedStandalone != null) {
        final List<dynamic> itemsJson = cachedStandalone['message'] ?? [];
        _standaloneTasks = itemsJson.map((json) => Task.fromMap(json)).toList();
      }
      notifyListeners();
    } catch (e) {
      _logger.error('TASKS_PROVIDER', 'Error loading from cache', error: e);
    }
  }

  void _parseTasksFromMessage(Map<String, dynamic> message) {
    final summary = message['summary'] ?? {};
    _totalItems = summary['totalItems'] ?? 0;
    _totalTasks = summary['totalTasks'] ?? 0;
    _totalSubtasks = summary['totalSubtasks'] ?? 0;

    // Handle both combined list and split lists from API
    final List<dynamic> allItemsJson = message['allItems'] ?? [];
    if (allItemsJson.isNotEmpty) {
      _allItems = allItemsJson.map((json) => Task.fromMap(json)).toList();
    } else {
      // Fallback: Combine projectTasks, standaloneTasks and subtasks if allItems is missing
      final List<dynamic> projectTasks = message['projectTasks'] ?? [];
      final List<dynamic> standaloneTasks = message['standaloneTasks'] ?? [];
      final List<dynamic> subtasks = message['subtasks'] ?? [];
      
      _allItems = [
        ...projectTasks.map((json) => Task.fromMap({...json, 'itemType': 'task'})),
        ...standaloneTasks.map((json) => Task.fromMap({...json, 'itemType': 'task'})),
        ...subtasks.map((json) => Task.fromMap({...json, 'itemType': 'subtask'})),
      ];
    }
  }

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

  /// 🚀 Smart logic for Task Details
  Future<void> loadTaskDetails(Task task) async {
    _currentSubtasks = [];
    _currentComments = [];
    _currentActivityLogs = [];
    notifyListeners();

    await Future.wait([
      fetchSubtasks(task.id),
      fetchComments(task.id),
      _handleActivityLogs(task),
    ]);
  }

  Future<void> _handleActivityLogs(Task task) async {
    if (task.sprintId != null && task.sprintId!.isNotEmpty) {
      await fetchActivityLogs(task.sprintId!);
    } else {
      _currentActivityLogs = task.activityLog;
      notifyListeners();
    }
  }

  Future<void> fetchStandaloneTasks() async {
    try {
      if (_standaloneTasks.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }
      final response = await _taskService.getStandaloneTasks();
      if (response.success && response.data != null) {
        await _local.saveJson(_keyStandaloneTasks, response.data);
        final List<dynamic> itemsJson = response.data!['message'] ?? [];
        _standaloneTasks = itemsJson.map((json) => Task.fromMap(json)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTasks(String employeeId) async {
    try {
      if (_allItems.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }
      final response = await _taskService.getAssignedItems(employeeId);
      if (response.success && response.data != null) {
        await _local.saveJson(_keyTasks, response.data);
        final message = response.data!['message'];
        _parseTasksFromMessage(message);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubtasks(String taskId, {bool forceRefresh = false}) async {
    final cacheKey = '$_keySubtasksPrefix$taskId';
    
    if (!forceRefresh) {
      final cached = await _local.getJson(cacheKey);
      if (cached != null) {
        _currentSubtasks = cached;
        notifyListeners();
      }
    }

    try {
      _isSubtaskLoading = true;
      notifyListeners();
      final response = await _taskService.getSubtasks(taskId);
      if (response.success && response.data != null) {
        _currentSubtasks = response.data!['message'] ?? [];
        await _local.saveJson(cacheKey, _currentSubtasks);
      }
    } finally {
      _isSubtaskLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> fetchComments(String taskId, {bool forceRefresh = false}) async {
    final cacheKey = '$_keyCommentsPrefix$taskId';

    if (!forceRefresh) {
      final cached = await _local.getJson(cacheKey);
      if (cached != null) {
        _currentComments = cached;
        notifyListeners();
      }
    }

    try {
      _isCommentLoading = true;
      notifyListeners();
      final response = await _taskService.getComments(taskId, 'task');
      if (response.success && response.data != null) {
        _currentComments = response.data!['message'] ?? [];
        await _local.saveJson(cacheKey, _currentComments);
      }
    } finally {
      _isCommentLoading = false;
      notifyListeners();
    }
  }

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
      final currentTask = _standaloneTasks.followedBy(_allItems).firstWhere((t) => t.id == taskId, orElse: () => _allItems.first);
      await _handleActivityLogs(currentTask);
      notifyListeners();
    }
  }

  Future<void> addComment(Map<String, dynamic> data, String taskId) async {
    final response = await _taskService.createComment(data);
    if (response.success) {
      await fetchComments(taskId, forceRefresh: true);
    }
  }

  Future<void> toggleCommentLike(String commentId, String employeeId, String taskId) async {
    final response = await _taskService.toggleLike(commentId, employeeId);
    if (response.success) {
      await fetchComments(taskId, forceRefresh: true);
    }
  }

  Future<void> createSubtask(Map<String, dynamic> data, String taskId) async {
    final response = await _taskService.createSubtask(data);
    if (response.success) {
      await fetchSubtasks(taskId, forceRefresh: true);
    }
  }

  Future<void> updateSubtaskStatus(String subtaskId, String employeeId, String status, String taskId) async {
    final response = await _taskService.updateSubtaskStatus(subtaskId, employeeId, status);
    if (response.success) {
      await fetchSubtasks(taskId, forceRefresh: true);
    }
  }

  Future<void> deleteSubtask(String subtaskId, String taskId) async {
    final response = await _taskService.deleteSubtask(subtaskId);
    if (response.success) {
      await fetchSubtasks(taskId, forceRefresh: true);
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
