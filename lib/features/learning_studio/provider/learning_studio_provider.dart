import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/learning_studio_service.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';

enum LearningStudioState {
  idle,
  loading,
  loaded,
  error,
}

class LearningStudioProvider extends ChangeNotifier {
  final LearningStudioService _service = LearningStudioService();

  // ================== STATE ==================
  LearningStudioState _state = LearningStudioState.idle;
  String? _errorMessage;

  LearningStudioState get state => _state;
  String? get errorMessage => _errorMessage;

  // ================== CACHED DATA ==================

  /// Departments (cached once)
  List<String> _departments = [];

  /// department -> subDepartments
  final Map<String, List<String>> _subDepartmentsCache = {};

  /// subDepartment -> courses
  final Map<String, List<Map<String, dynamic>>> _coursesCache = {};

  List<String> get departments => _departments;

  // ================== CONSTRUCTOR ==================
  LearningStudioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDepartments();
  }

  // ================== LOAD DEPARTMENTS ==================
  Future<void> _loadDepartments() async {
    if (_departments.isNotEmpty) return;

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final ApiResponse response = await _service.getDepartments();

      if (response.success && response.data != null) {
        final Map<String, dynamic> body =
            response.data as Map<String, dynamic>;

        _departments = List<String>.from(body['departments'] ?? []);
        _state = LearningStudioState.loaded;
      } else {
        _errorMessage = response.message;
        _state = LearningStudioState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== LOAD SUB DEPARTMENTS ==================
  Future<void> loadSubDepartments(String department) async {
    if (_subDepartmentsCache.containsKey(department)) return;

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final ApiResponse response =
          await _service.getSubDepartments(department);

      if (response.success && response.data != null) {
        final Map<String, dynamic> body =
            response.data as Map<String, dynamic>;

        final Map<String, dynamic> message =
            body['message'] ?? {};

        _subDepartmentsCache[department] =
            List<String>.from(message['subDepartments'] ?? []);

        _state = LearningStudioState.loaded;
      } else {
        _errorMessage = response.message;
        _state = LearningStudioState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== LOAD COURSES ==================
  Future<void> loadCourses(String subDepartment) async {
    if (_coursesCache.containsKey(subDepartment)) return;

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final ApiResponse response =
          await _service.getCoursesBySubDepartment(subDepartment);

      if (response.success && response.data != null) {
        final Map<String, dynamic> body =
            response.data as Map<String, dynamic>;

        _coursesCache[subDepartment] =
            List<Map<String, dynamic>>.from(body['message'] ?? []);

        _state = LearningStudioState.loaded;
      } else {
        _errorMessage = response.message;
        _state = LearningStudioState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== GETTERS FOR UI ==================
  List<String> getSubDepartments(String department) {
    return _subDepartmentsCache[department] ?? [];
  }

  List<Map<String, dynamic>> getCourses(String subDepartment) {
    return _coursesCache[subDepartment] ?? [];
  }

  // ================== RESET (OPTIONAL) ==================
  void clearCache() {
    _departments.clear();
    _subDepartmentsCache.clear();
    _coursesCache.clear();
    _state = LearningStudioState.idle;
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> addSubDepartment({
  required String subDepartmentName,
  required String department,
  required String description,
}) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final response = await _service.addSubDepartment(
      subDepartmentName: subDepartmentName,
      department: department,
      description: description,
    );

    if (response.success) {
      // 🔥 cache refresh (important)
      _subDepartmentsCache.remove(department);
      await loadSubDepartments(department);

      _state = LearningStudioState.loaded;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _state = LearningStudioState.error;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString();
    _state = LearningStudioState.error;
    notifyListeners();
    return false;
  }
}

Future<bool> addCourse({
  required String content,
  required String courseName,
  required String createdOn,
  required String department,
  required String details,
  required String duration,
  required String subDepartment,
  required List<String> tags,
  required String videoUrl,
}) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final response = await _service.addCourse(
      content: content,
      courseName: courseName,
      createdOn: createdOn,
      department: department,
      details: details,
      duration: duration,
      subDepartment: subDepartment,
      tags: tags,
      videoUrl: videoUrl,
    );

    if (response.success) {
      // 🔥 cache refresh
      _coursesCache.remove(subDepartment);
      await loadCourses(subDepartment);

      _state = LearningStudioState.loaded;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _state = LearningStudioState.error;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString();
    _state = LearningStudioState.error;
    notifyListeners();
    return false;
  }
}

// ================== DELETE COURSE ==================
Future<bool> deleteCourse({
  required String courseId,
  required String subDepartment,
}) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final ApiResponse response =
        await _service.deleteCourse(courseId);

    if (response.success) {
      // 🔥 cache refresh (important)
      _coursesCache.remove(subDepartment);
      await loadCourses(subDepartment);

      _state = LearningStudioState.loaded;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _state = LearningStudioState.error;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = e.toString();
    _state = LearningStudioState.error;
    notifyListeners();
    return false;
  }
}
}