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
  Future<ApiResponse<Map<String, dynamic>>> getOtp({
    required String employeeId,
  }) async {
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
    return await _apiHelper.post<Map<String, dynamic>>(
      'employee/verifyOtp',
      body,
    );
  }

  /// 🔑 Change password API
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String employeeId,
    required String password,
  }) async {
    final body = {"employeeId": employeeId, "password": password};
    _logger.logAuth('Changing password for employeeId: $employeeId');
    return await _apiHelper.post<Map<String, dynamic>>(
      'employee/changePassword',
      body,
    );
  }

  /// 👥 Get employee list API
  Future<ApiResponse<List<EmployeeModel>>> getEmployeeList() async {
    _logger.logAuth('Fetching employee list');
    final response = await _apiHelper.get<Map<String, dynamic>>(
      'employee/employeeList',
    );
    final List<dynamic> employeesJson = response.data!['message'];
    final employees = employeesJson
        .map((json) => EmployeeModel.fromJson(json))
        .toList();
    return ApiResponse.success(employees);
  }

  /// 📄 Get Employee Info API
  Future<ApiResponse<EmployeeModel>> getEmployeeInfo({
    required String employeeId,
  }) async {
    _logger.logAuth('Fetching info for employeeId: $employeeId');
    final endpoint = 'employee/getInfo/$employeeId';
    final response = await _apiHelper.get<Map<String, dynamic>>(endpoint);

    if (response.success && response.data != null) {
      // Ensure response.data is not null and contains the required fields
      final employee = EmployeeModel.fromJson(response.data!);
      return ApiResponse.success(employee);
    } else {
      // Handle the case where response.data is null or the request failed
      return ApiResponse.error(
        response.message ?? 'Failed to fetch employee info',
      );
    }
  }

  /// ✏️ Update Employee Profile API
  Future<ApiResponse<Map<String, dynamic>>> updateEmployeeProfile({
    required String employeeId,
    required String name,
    required String email,
    required String mobile,
    required String alterMobile,
    required String gender,
    required String address,
  }) async {
    _logger.logAuth('Updating profile for employeeId: $employeeId');
    final endpoint = 'employee/profile/$employeeId';
    final body = {
      "name": name,
      "email": email,
      "mobile": mobile,
      "alterMobile": alterMobile,
      "gender": gender,
      "address": address,
    };
    return await _apiHelper.put<Map<String, dynamic>>(endpoint, body);
  }

  ///  Update FCM Token (appToken)
  Future<ApiResponse<Map<String, dynamic>>> updateFCMToken({
    required String employeeId,
    required String appToken,
  }) async {
    _logger.logNetwork("🔁 Updating FCM token for employeeId: $employeeId");
    final body = {"appToken": appToken};
    final response = await _apiHelper.put<Map<String, dynamic>>(
      'employee/profile/$employeeId',
      body,
    );
    return response;
  }
}
