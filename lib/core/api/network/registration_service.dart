import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/registration_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class RegistrationService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  // Sir's New Base URL for Registrations
  static const String registrationBaseUrl = "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";

  Future<ApiResponse<List<RegistrationModel>>> getRegistrations() async {
    _logger.logNetwork('Fetching users from user/getUsers using new Base URL');
    
    // Using the new base URL provided by Sir
    _apiHelper.setBaseUrl(registrationBaseUrl); 

    final response = await _apiHelper.get<dynamic>('user/getUsers');
    
    if (response.success && response.data != null) {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        dynamic listData = data['message'] ?? data['data'] ?? data['users'];
        if (listData is List) {
          final registrations = listData.map((json) => RegistrationModel.fromJson(json)).toList();
          return ApiResponse.success(registrations);
        }
      } 
      else if (data is List) {
        final registrations = data.map((json) => RegistrationModel.fromJson(json)).toList();
        return ApiResponse.success(registrations);
      }
      else if (data is String) {
        _logger.logNetwork('API Message: $data');
        return ApiResponse.success([]); 
      }
    }
    
    return ApiResponse.error(response.message ?? 'Failed to fetch users');
  }

  /// ✏️ Update User Details API
  Future<ApiResponse<Map<String, dynamic>>> updateUser({
    required String email,
    required Map<String, dynamic> data,
  }) async {
    _logger.logNetwork('Updating user $email details');
    _apiHelper.setBaseUrl(registrationBaseUrl);
    
    // Endpoint: user/updateDetails/:email, Method: PUT
    return await _apiHelper.put<Map<String, dynamic>>('user/updateDetails/$email', data);
  }

  /// ✅ Approve User API
  Future<ApiResponse<Map<String, dynamic>>> approveUser({
    required String email,
    required String teamLeadName,
    required String packageId,
  }) async {
    _logger.logNetwork('Approving user $email');
    _apiHelper.setBaseUrl(registrationBaseUrl);
    
    // Endpoint: employee/approve/:email/:teamLeadName/:packageId, Method: PUT
    return await _apiHelper.put<Map<String, dynamic>>('employee/approve/$email/$teamLeadName/$packageId', {});
  }

  /// ❌ Reject User API
  Future<ApiResponse<Map<String, dynamic>>> rejectUser({
    required String email,
  }) async {
    _logger.logNetwork('Rejecting user $email');
    _apiHelper.setBaseUrl(registrationBaseUrl);
    
    // Endpoint: user/reject/:email, Method: DELETE
    return await _apiHelper.delete<Map<String, dynamic>>('user/reject/$email');
  }

  /// ⏸️ Update Status (for Hold etc.)
  Future<ApiResponse<Map<String, dynamic>>> updateRegistrationStatus({
    required String id,
    required String status,
  }) async {
    _logger.logNetwork('Updating registration $id to $status');
    _apiHelper.setBaseUrl(registrationBaseUrl);

    final body = {"status": status};
    return await _apiHelper.put<Map<String, dynamic>>('user/updateStatus/$id', body);
  }
}
