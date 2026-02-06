import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class LearningStudioService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Fetch all departments
  /// GET: course/departments
  Future<ApiResponse<Map<String, dynamic>>> getDepartments() async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    _logger.logNetwork('Fetching learning studio departments');

    return await _apiHelper.get<Map<String, dynamic>>(
      'course/departments',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetch sub-departments for a department
  /// GET: course/subdepartments?department=software
  Future<ApiResponse<Map<String, dynamic>>> getSubDepartments(
    String department,
  ) async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final endpoint = 'course/subdepartments?department=$department';

    _logger.logNetwork('Fetching sub-departments for $department');

    return await _apiHelper.get<Map<String, dynamic>>(
      endpoint,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetch courses for a sub-department
  /// GET: course/subdepartment/backend
  Future<ApiResponse<Map<String, dynamic>>> getCoursesBySubDepartment(
    String subDepartment,
  ) async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final endpoint = 'course/subdepartment/$subDepartment';

    _logger.logNetwork('Fetching courses for sub-department $subDepartment');

    return await _apiHelper.get<Map<String, dynamic>>(
      endpoint,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
  // ================== ADD SUB-DEPARTMENT ==================
Future<ApiResponse<Map<String, dynamic>>> addSubDepartment({
  required String subDepartmentName,
  required String department,
  required String description,
}) async {
  final body = {
    "subDepartmentName": subDepartmentName,
    "department": department,
    "description": description,
  };

  return await _apiHelper.post<Map<String, dynamic>>(
    'course/subdepartments',
    body,
  );
}

// ================== ADD COURSE ==================
Future<ApiResponse<Map<String, dynamic>>> addCourse({
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
  final body = {
    "content": content,
    "courseName": courseName,
    "createdOn": createdOn,
    "department": department,
    "details": details,
    "duration": duration,
    "subDepartment": subDepartment,
    "tags": tags,
    "videoUrl": videoUrl,
  };

  return await _apiHelper.post<Map<String, dynamic>>(
    'course/add',
    body,
  );
}
// ================== DELETE COURSE ==================
Future<ApiResponse<Map<String, dynamic>>> deleteCourse(
  String courseId,
) async {
  final token = await _secureStorage.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final endpoint = 'course/delete/$courseId';

  _logger.logNetwork('Deleting course $courseId');

  return await _apiHelper.delete<Map<String, dynamic>>(
    endpoint,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}

// ================== COURSE DETAIL COUNT ==================
/// GET: courseDetail/getCount
Future<ApiResponse<Map<String, dynamic>>> getCourseCount() async {
  final token = await _secureStorage.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  _logger.logNetwork('Fetching course count');

  return await _apiHelper.get<Map<String, dynamic>>(
    'courseDetail/getCount',
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}

// ================== EMPLOYEE COURSE DETAILS ==================
/// GET: courseDetail/employee/:employeeId
Future<ApiResponse<Map<String, dynamic>>> getEmployeeCourses(
  String employeeId,
) async {
  final token = await _secureStorage.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final endpoint = 'courseDetail/employee/$employeeId';

  _logger.logNetwork(
      'Fetching courses for employee $employeeId');

  return await _apiHelper.get<Map<String, dynamic>>(
    endpoint,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}

// ================== UPDATE COURSE STATUS ==================
/// PUT: courseDetail/update/:id
/// body: { courseStatus: "Completed" | "Ongoing" | "NotStarted" }
Future<ApiResponse<Map<String, dynamic>>> updateCourseStatus({
  required String courseDetailId,
  required String courseStatus,
}) async {
  final token = await _secureStorage.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final endpoint = 'courseDetail/update/$courseDetailId';

  _logger.logNetwork(
    'Updating course status for courseDetailId: $courseDetailId → $courseStatus',
  );

  return await _apiHelper.put<Map<String, dynamic>>(
    endpoint,
    {
      "courseStatus": courseStatus,
    },
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}

// ================== GET COURSE BY ID ==================
/// GET: course/getone/:id
Future<ApiResponse<Map<String, dynamic>>> getCourseById(
  String courseId,
) async {
  final token = await _secureStorage.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  final endpoint = 'course/getone/$courseId';

  _logger.logNetwork('Fetching course details for courseId: $courseId');

  return await _apiHelper.get<Map<String, dynamic>>(
    endpoint,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}

}