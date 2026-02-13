import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/learning_studio_service.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';

enum LearningStudioState { idle, loading, loaded, error }

class LearningStudioProvider extends ChangeNotifier {
  final LearningStudioService _service = LearningStudioService();
  final LocalStorageService _local = LocalStorageService();

  // ================== STATE ==================
  LearningStudioState _state = LearningStudioState.idle;
  String? _errorMessage;

  Map<String, dynamic>? _selectedCourse;
  Map<String, dynamic>? get selectedCourse => _selectedCourse;

  LearningStudioState get state => _state;
  String? get errorMessage => _errorMessage;

  // ================== DATA ==================
  List<String> _departments = [];
  final Map<String, List<String>> _subDepartmentsCache = {};
  final Map<String, List<Map<String, dynamic>>> _coursesCache = {};
  final Set<String> _requestedCourses = {};

  Map<String, dynamic>? _courseCount;
  List<Map<String, dynamic>>? _employeeCourses;

  List<Map<String, dynamic>>? _progressHistory;
  List<Map<String, dynamic>>? get progressHistory => _progressHistory;

  List<String> get departments => _departments;
  Map<String, dynamic>? get courseCount => _courseCount;
  List<Map<String, dynamic>>? get employeeCourses => _employeeCourses;

  // ================== CONSTRUCTOR ==================
  LearningStudioProvider() {
   _bootstrap();

  }
  Future<void> _bootstrap() async {
    await loadDepartments();
    await loadCourseCount();
  }

  
  // ================== LOAD DEPARTMENTS ==================
 Future<void> loadDepartments({bool force = false}) async {
  if (force) {
    _departments.clear();
    await _local.removeString(LocalStorageService.keyDepartments);
  }

  if (_departments.isNotEmpty) return;

  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final cached =
        await _local.getJson(LocalStorageService.keyDepartments);
    if (cached != null) {
      _departments = List<String>.from(cached);
      _state = LearningStudioState.loaded;
      notifyListeners();
      return;
    }

    final ApiResponse response = await _service.getDepartments();
    if (response.success && response.data != null) {
      final body = response.data as Map<String, dynamic>;
      _departments =
          List<String>.from(body['departments'] ?? []);

      await _local.saveJson(
          LocalStorageService.keyDepartments, _departments);

      _state = LearningStudioState.loaded;
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
      final cacheKey =
          '${LocalStorageService.keySubDepartmentsPrefix}$department';

      //  local
      final cached = await _local.getJson(cacheKey);
      if (cached != null) {
        _subDepartmentsCache[department] =
            List<String>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        return;
      }

      // 2️⃣ API
      final ApiResponse response =
          await _service.getSubDepartments(department);

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final message = body['message'] ?? {};
        final list =
            List<String>.from(message['subDepartments'] ?? []);

        _subDepartmentsCache[department] = list;

        // save local
        await _local.saveJson(cacheKey, list);

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
  if (_requestedCourses.contains(subDepartment)) return;
  _requestedCourses.add(subDepartment);

  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final cacheKey =
        '${LocalStorageService.keyCoursesPrefix}$subDepartment';

    final cached = await _local.getJson(cacheKey);
    if (cached != null) {
      _coursesCache[subDepartment] =
          List<Map<String, dynamic>>.from(cached);
      _state = LearningStudioState.loaded;
      notifyListeners();
      return;
    }

    final ApiResponse response =
        await _service.getCoursesBySubDepartment(subDepartment);

    if (response.success && response.data != null) {
      final body = response.data as Map<String, dynamic>;
      final list =
          List<Map<String, dynamic>>.from(body['message'] ?? []);

      _coursesCache[subDepartment] = list;
      await _local.saveJson(cacheKey, list);

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
  // ================== GETTERS ==================
  List<String> getSubDepartments(String department) {
    return _subDepartmentsCache[department] ?? [];
  }

  List<Map<String, dynamic>> getCourses(String subDepartment) {
    
    return _coursesCache[subDepartment] ?? [];
  }

  // ================== ADD SUB DEPARTMENT ==================
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
        _subDepartmentsCache.remove(department);
        await _local.removeString(
            '${LocalStorageService.keySubDepartmentsPrefix}$department');

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

  // ================== ADD COURSE ==================
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
      // clear cache
      _coursesCache.remove(subDepartment);
      _requestedCourses.remove(subDepartment);
      await _local.removeString(
          '${LocalStorageService.keyCoursesPrefix}$subDepartment');

      // reload fresh
      await loadCourses(subDepartment);
      await loadDepartments(force: true);

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
      _coursesCache.remove(subDepartment);
      _requestedCourses.remove(subDepartment);
      await _local.removeString(
          '${LocalStorageService.keyCoursesPrefix}$subDepartment');

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
    // ================== COURSE COUNT ==================
  Future<void> loadCourseCount({bool force = false}) async {
  try {
    if (force) {
      await _local.removeString(LocalStorageService.keyCourseCount);
    }

    final response = await _service.getCourseCount();

    if (response.success && response.data != null) {
      final body = response.data as Map<String, dynamic>;
      final message = body['message'] ?? {};
      final List list = message['latestCourses'] ?? [];

      int completed = 0;
      int ongoing = 0;
      int notStarted = 0;

      for (final item in list) {
        final status = item['courseStatus'];
        if (status == 'Completed') {
          completed++;
        } else if (status == 'Ongoing') {
          ongoing++;
        } else {
          notStarted++;
        }
      }

      _courseCount = {
        'completed': completed,
        'ongoing': ongoing,
        'notStarted': notStarted,
        'history': list, 
      };

      _progressHistory = List<Map<String, dynamic>>.from(list);

      notifyListeners();
    }
  } catch (e) {
    debugPrint('CourseCount error: $e');
  }
}
  // ================== EMPLOYEE COURSES ==================
  Future<void> loadEmployeeCourses(String employeeId) async {
    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final cacheKey =
          '${LocalStorageService.keyEmployeeCourses}_$employeeId';

      final cached = await _local.getJson(cacheKey);
      if (cached != null) {
        _employeeCourses =
            List<Map<String, dynamic>>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        return;
      }

      final response =
          await _service.getEmployeeCourses(employeeId);
      if (response.success && response.data != null) {
        _employeeCourses =
            List<Map<String, dynamic>>.from(
                (response.data as Map)['message'] ?? []);

        await _local.saveJson(cacheKey, _employeeCourses!);
        _state = LearningStudioState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== UPDATE COURSE STATUS ==================
// ================== UPDATE COURSE STATUS ==================
Future<bool> updateCourseStatus({
  required String courseDetailId,
  required String status, // Completed | Ongoing | NotStarted
  required String employeeId,
}) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final response = await _service.updateCourseStatus(
      courseDetailId: courseDetailId,
      courseStatus: status,
    );

    if (response.success) {
      //  clear employee courses cache
      final cacheKey =
          '${LocalStorageService.keyEmployeeCourses}_$employeeId';
      await _local.removeString(cacheKey);

      // reload my progress
      await loadEmployeeCourses(employeeId);

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

// ================== LOAD COURSE BY ID ==================
Future<void> loadCourseById(String courseId) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final response = await _service.getCourseById(courseId);

    if (response.success && response.data != null) {
      final body = response.data as Map<String, dynamic>;

      // API response format:
      // { status: 200, message: { course data } }
      _selectedCourse = Map<String, dynamic>.from(body['message']);

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

// ================== ASSIGN COURSE TO EMPLOYEE ==================
Future<bool> assignCourseToEmployee({
  required String name,
  required String courseName,
  required String courseId,
  required String employeeId,
  DateTime? startDate,
}) async {
  _state = LearningStudioState.loading;
  notifyListeners();

  try {
    final response = await _service.assignCourseToEmployee(
      name: name,
      courseName: courseName,
      courseId: courseId,
      employeeId: employeeId,
      courseStatus: 'NotStarted',
      startDate: (startDate ?? DateTime.now()).toIso8601String(),
    );

    if (response.success) {
      final cacheKey =
          '${LocalStorageService.keyEmployeeCourses}_$employeeId';
      await _local.removeString(cacheKey);
      await loadEmployeeCourses(employeeId);

       await loadCourseCount(force: true);
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
  // ================== RESET ==================
  void clearCache() {
    _departments.clear();
    _subDepartmentsCache.clear();
    _coursesCache.clear();
    _requestedCourses.clear();
    _courseCount = null;
    _selectedCourse = null;
    _employeeCourses = null;
    _state = LearningStudioState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}