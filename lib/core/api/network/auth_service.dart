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
    if (response.success && response.data != null) {
      final List<dynamic> employeesJson = response.data!['message'] ?? [];
      final employees = employeesJson
          .map((json) => EmployeeModel.fromJson(json))
          .toList();
      return ApiResponse.success(employees);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch employee list');
  }

  /// 📄 Get Employee Info API
  Future<ApiResponse<EmployeeModel>> getEmployeeInfo({
    required String employeeId,
  }) async {
    _logger.logAuth('Fetching info for employeeId: $employeeId');
    final endpoint = 'employee/getInfo/$employeeId';
    final response = await _apiHelper.get<Map<String, dynamic>>(endpoint);

    if (response.success && response.data != null) {
      final Map<String, dynamic> message = response.data!['message'];
      final employee = EmployeeModel.fromJson(message);
      return ApiResponse.success(employee);
    } else {
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
    String? profileImage,
  }) async {
    _logger.logAuth('Updating profile for employeeId: $employeeId');
    final endpoint = 'employee/profile/$employeeId';
    final body = {
      "name": name,
      "email": email,
      "mobile": int.tryParse(mobile) ?? mobile,
      "alterMobile": int.tryParse(alterMobile) ?? alterMobile,
      "gender": gender,
      "address": address,
      if (profileImage != null) "profileImage": profileImage,
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

  /// 📅 Add Leave Request API
  Future<ApiResponse<Map<String, dynamic>>> addLeaveRequest({
    required String name,
    required String employeeId,
    required String startDate,
    required String endDate,
    required String reason,
    required int duration,
    required String type,
    String? medicalCertificate,
  }) async {
    final body = {
      "name": name,
      "employeeId": employeeId,
      "startDate": startDate,
      "endDate": endDate,
      "reason": reason,
      "duration": duration,
      "type": type,
      if (medicalCertificate != null) "medicalCertificate": [medicalCertificate],
    };
    
    _logger.logAuth('Adding leave request to leave/add');
    return await _apiHelper.post<Map<String, dynamic>>('leave/add', body);
  }

  /// 📜 Get Leave History API
  Future<ApiResponse<Map<String, dynamic>>> getLeaveHistory({
    required String employeeId,
  }) async {
    _logger.logAuth('Fetching leave history for employeeId: $employeeId');
    final endpoint = 'leave/history/$employeeId';
    return await _apiHelper.get<Map<String, dynamic>>(endpoint);
  }

  /// 📜 Get All Leave Requests API (Admin)
  Future<ApiResponse<Map<String, dynamic>>> getAllLeaveRequests() async {
    _logger.logAuth('Fetching all leave requests for admin');
    // Changed endpoint to
    return await _apiHelper.get<Map<String, dynamic>>('leave/getAll');
  }

  /// ✅ Update Leave Status API (Admin Approval/Rejection)
  Future<ApiResponse<Map<String, dynamic>>> updateLeaveStatus({
    required String leaveId,
    required String status,
    required String updatedBy,
  }) async {
    _logger.logAuth('Updating leave status for $leaveId to $status by $updatedBy');
    final endpoint = 'leave/update/$leaveId';
    final body = {
      "status": status,
      "updatedBy": updatedBy,
    };
    return await _apiHelper.put<Map<String, dynamic>>(endpoint, body);
  }

  /// 📊 Get Available Leave API
  Future<ApiResponse<Map<String, dynamic>>> getAvailableLeave({
    required String employeeId,
  }) async {
    _logger.logAuth('Fetching available leave for employeeId: $employeeId');
    final endpoint = 'leave/availableLeave/$employeeId';
    return await _apiHelper.get<Map<String, dynamic>>(endpoint);
  }

  /// 🗑️ Cancel/Delete Leave Request API
  Future<ApiResponse<Map<String, dynamic>>> deleteLeaveRequest({
    required String leaveId,
    required String updatedBy,
  }) async {
    _logger.logAuth('Cancelling leave request: $leaveId');
    final endpoint = 'leave/update/$leaveId';
    final body = {
      "status": "Cancelled",
      "updatedBy": updatedBy
    };
    return await _apiHelper.put<Map<String, dynamic>>(endpoint, body);
  }

  /// 📅 Get Attendance API
  Future<ApiResponse<Map<String, dynamic>>> getAttendance({
    required String employeeId,
    required String date,
  }) async {
    _logger.logAuth(
      'Fetching attendance for employeeId: $employeeId on date: $date',
    );
    final endpoint = 'attendence/getAttentence';
    final body = {"date": date, "employeeId": employeeId};
    return await _apiHelper.post<Map<String, dynamic>>(endpoint, body);
  }
}
