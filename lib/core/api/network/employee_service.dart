import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class EmployeeService {
  static const String employeeBaseUrl =
      "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";

  final ApiHelper _apiHelper =
      ApiHelper(baseUrl: employeeBaseUrl);

  final LoggingService _logger = LoggingService.instance;

  /// 👥 Get all employees list
  Future<ApiResponse<List<EmployeeModel>>> getEmployeeList() async {
    _logger.info('NETWORK', 'Fetching employee directory list from: employee/getAll');
    final response = await _apiHelper.get<Map<String, dynamic>>(
      'employee/getAll',
    );
    
    if (response.success && response.data != null) {
      final List<dynamic> employeesJson = response.data!['message'] ?? [];
      final employees = employeesJson
          .map((json) => EmployeeModel.fromJson(json))
          .toList();
      return ApiResponse.success(employees);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch employee list');
  }

  /// 🎯 Get Tag Options (Team Leads list)
  Future<ApiResponse<List<String>>> getTagOptions() async {
    _logger.info('NETWORK', 'Fetching tag options...');
    // Try plural first
    final response = await _apiHelper.get<Map<String, dynamic>>('employee/getTagOptions');
    
    if (response.success && response.data != null) {
      final List<dynamic> options = response.data!['message'] ?? [];
      return ApiResponse.success(options.map((e) => e.toString()).toList());
    }

    // Fallback to singular if plural fails
    _logger.info('NETWORK', 'Plural endpoint failed, trying singular: employee/getTagOption');
    final responseSingular = await _apiHelper.get<Map<String, dynamic>>('employee/getTagOption');
    if (responseSingular.success && responseSingular.data != null) {
      final List<dynamic> options = responseSingular.data!['message'] ?? [];
      return ApiResponse.success(options.map((e) => e.toString()).toList());
    }

    return ApiResponse.error('Tag options endpoint not found');
  }

  /// 🏷️ Tag/Assign Position
  Future<ApiResponse<Map<String, dynamic>>> tagEmployee({
    required String employeeName,
    required String teamLeadName,
  }) async {
    final body = {
      "employeeName": employeeName,
      "teamLeadName": teamLeadName
    };
    return await _apiHelper.put<Map<String, dynamic>>('employee/tag', body);
  }

  /// 🎭 Change Employee Role
  Future<ApiResponse<Map<String, dynamic>>> changeRole({
    required String employeeId,
    required String newRole,
    required String changedBy,
  }) async {
    final body = {
      "newRole": newRole,
      "changedBy": changedBy
    };
    return await _apiHelper.put<Map<String, dynamic>>('employee/changeRole/$employeeId', body);
  }
}
