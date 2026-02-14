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
    // 1. Initial essential data
    await loadDepartments();
    
    // 2. Load user-specific data from storage if available
    final employeeId = await _local.getEmployeeId();
    if (employeeId != null) {
      // In Millgate pattern, we can fetch these in background
      loadCourseCount(); 
      loadEmployeeCourses(employeeId);
    }
  }

  // ================== LOAD DEPARTMENTS ==================
  Future<void> loadDepartments({bool force = false}) async {
    if (force) {
      _departments.clear();
      await _local.removeString(LocalStorageService.keyDepartments);
    }

    if (_departments.isNotEmpty && !force) return;

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      // 1. Try Local Storage
      final cached = await _local.getJson(LocalStorageService.keyDepartments);
      if (cached != null) {
        _departments = List<String>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        // Optionally fetch fresh in background
      }

      // 2. Fetch from API if cache empty or forced
      if (_departments.isEmpty || force) {
        final ApiResponse response = await _service.getDepartments();
        if (response.success && response.data != null) {
          final body = response.data as Map<String, dynamic>;
          _departments = List<String>.from(body['departments'] ?? []);

          // 3. Save to Local Storage
          await _local.saveJson(LocalStorageService.keyDepartments, _departments);
          _state = LearningStudioState.loaded;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== LOAD SUB DEPARTMENTS ==================
  Future<void> loadSubDepartments(String department, {bool force = false}) async {
    if (_subDepartmentsCache.containsKey(department) && !force) return;

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final cacheKey = '${LocalStorageService.keySubDepartmentsPrefix}$department';

      // 1. Local
      final cached = await _local.getJson(cacheKey);
      if (cached != null && !force) {
        _subDepartmentsCache[department] = List<String>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        return;
      }

      // 2. API
      final ApiResponse response = await _service.getSubDepartments(department);

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final message = body['message'] ?? {};
        final list = List<String>.from(message['subDepartments'] ?? []);

        _subDepartmentsCache[department] = list;

        // 3. Save local
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
  Future<void> loadCourses(String subDepartment, {bool force = false}) async {
    if (_requestedCourses.contains(subDepartment) && !force) return;
    _requestedCourses.add(subDepartment);

    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final cacheKey = '${LocalStorageService.keyCoursesPrefix}$subDepartment';

      // 1. Local
      final cached = await _local.getJson(cacheKey);
      if (cached != null && !force) {
        _coursesCache[subDepartment] = List<Map<String, dynamic>>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        return;
      }

      // 2. API
      final ApiResponse response = await _service.getCoursesBySubDepartment(subDepartment);

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(body['message'] ?? []);

        _coursesCache[subDepartment] = list;
        // 3. Save Local
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

  // ================== COURSE COUNT ==================
  Future<void> loadCourseCount({bool force = false}) async {
    try {
      if (!force) {
        final cached = await _local.getJson(LocalStorageService.keyCourseCount);
        if (cached != null) {
          _courseCount = Map<String, dynamic>.from(cached);
          if (_courseCount!['history'] != null) {
            _progressHistory = List<Map<String, dynamic>>.from(_courseCount!['history']);
          }
          notifyListeners();
        }
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
        
        // Save to local
        await _local.saveJson(LocalStorageService.keyCourseCount, _courseCount);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('CourseCount error: $e');
    }
  }

  // ================== EMPLOYEE COURSES ==================
  Future<void> loadEmployeeCourses(String employeeId, {bool force = false}) async {
    _state = LearningStudioState.loading;
    notifyListeners();

    try {
      final cacheKey = '${LocalStorageService.keyEmployeeCourses}_$employeeId';

      // 1. Try local
      final cached = await _local.getJson(cacheKey);
      if (cached != null && !force) {
        _employeeCourses = List<Map<String, dynamic>>.from(cached);
        _state = LearningStudioState.loaded;
        notifyListeners();
        return;
      }

      // 2. Fetch API
      final response = await _service.getEmployeeCourses(employeeId);
      if (response.success && response.data != null) {
        _employeeCourses = List<Map<String, dynamic>>.from((response.data as Map)['message'] ?? []);
        // 3. Save Local
        await _local.saveJson(cacheKey, _employeeCourses!);
        _state = LearningStudioState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }

    notifyListeners();
  }

  // ================== MUTATIONS (POST/DELETE) ==================

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
        await _local.removeString('${LocalStorageService.keySubDepartmentsPrefix}$department');
        await loadSubDepartments(department, force: true);
        return true;
      }
      _errorMessage = response.message;
      _state = LearningStudioState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }
    notifyListeners();
    return false;
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
        await _local.removeString('${LocalStorageService.keyCoursesPrefix}$subDepartment');
        await loadCourses(subDepartment, force: true);
        await loadDepartments(force: true);
        return true;
      }
      _errorMessage = response.message;
      _state = LearningStudioState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteCourse({
    required String courseId,
    required String subDepartment,
  }) async {
    _state = LearningStudioState.loading;
    notifyListeners();
    try {
      final ApiResponse response = await _service.deleteCourse(courseId);
      if (response.success) {
        await _local.removeString('${LocalStorageService.keyCoursesPrefix}$subDepartment');
        await loadCourses(subDepartment, force: true);
        return true;
      }
      _errorMessage = response.message;
      _state = LearningStudioState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateCourseStatus({
    required String courseDetailId,
    required String status,
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
        final cacheKey = '${LocalStorageService.keyEmployeeCourses}_$employeeId';
        await _local.removeString(cacheKey);
        await loadEmployeeCourses(employeeId, force: true);
        return true;
      }
      _errorMessage = response.message;
      _state = LearningStudioState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }
    notifyListeners();
    return false;
  }

  Future<void> loadCourseById(String courseId) async {
    _state = LearningStudioState.loading;
    notifyListeners();
    try {
      final response = await _service.getCourseById(courseId);
      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
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
        final cacheKey = '${LocalStorageService.keyEmployeeCourses}_$employeeId';
        await _local.removeString(cacheKey);
        await loadEmployeeCourses(employeeId, force: true);
        await loadCourseCount(force: true);
        return true;
      }
      _errorMessage = response.message;
      _state = LearningStudioState.error;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningStudioState.error;
    }
    notifyListeners();
    return false;
  }

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
