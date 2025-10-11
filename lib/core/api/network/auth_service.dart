import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';

class AuthService {
  final ApiHelper _apiHelper = ApiHelper();

  /// 🔐 Login API
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String employeeId,
    required String password,
  }) async {
    final body = {"employeeId": employeeId, "password": password};

    return await _apiHelper.post<Map<String, dynamic>>('employee/login', body);
  }

  // 📝 (Later we can add)
  // Future<ApiResponse> register(...)
  // Future<ApiResponse> verifyOtp(...)
  // Future<ApiResponse> resetPassword(...)
}
