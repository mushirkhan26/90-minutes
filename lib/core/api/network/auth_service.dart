import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class AuthService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// 🔐 Login API
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String employeeId,
    required String password,
  }) async {
    final body = {"employeeId": employeeId, "password": password};

    return await _apiHelper.post<Map<String, dynamic>>('employee/login', body);
  }

  /// 📩 Get OTP API
  Future<ApiResponse<Map<String, dynamic>>> getOtp({required String employeeId}) async {
    final endpoint = 'employee/getOTP/$employeeId';
    _logger.logAuth('Requesting OTP for employeeId: $employeeId');
    return await _apiHelper.get<Map<String, dynamic>>(endpoint);
  }

  /// 🔎 Verify OTP API
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String employeeId,
    required int otp,
  }) async {
    final body = {"employeeId": employeeId, "otp": otp};
    _logger.logAuth('Verifying OTP for employeeId: $employeeId');
    return await _apiHelper.post<Map<String, dynamic>>('employee/verifyOtp', body);
  }

  /// 🔑 Change password API
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String employeeId,
    required String password,
  }) async {
    final body = {"employeeId": employeeId, "password": password};
    _logger.logAuth('Changing password for employeeId: $employeeId');
    return await _apiHelper.post<Map<String, dynamic>>('employee/changePassword', body);
  }

  /// 👥 Get employee list API
  Future<ApiResponse<List<EmployeeModel>>> getEmployeeList() async {
    _logger.logAuth('Fetching employee list');
    final response = await _apiHelper.get<Map<String, dynamic>>('employee/employeeList');

    // The ApiHelper already handled status codes and exceptions,
    // so we can safely assume response is successful here
    final List<dynamic> employeesJson = response.data!['message'];
    final employees = employeesJson.map((json) => EmployeeModel.fromJson(json)).toList();
    return ApiResponse.success(employees);
  }
}
