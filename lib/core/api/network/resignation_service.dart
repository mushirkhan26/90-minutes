import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class ResignationService {
  final ApiHelper _apiHelper = ApiHelper();
  final SecureStorageService _storage = SecureStorageService();

  Future<ApiResponse<Map<String, dynamic>>> submitResignation({
    required String resignationDate,
    required String reason,
  }) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      return ApiResponse.error('Token missing');
    }

    return await _apiHelper.post<Map<String, dynamic>>(
      'resignation',
      {
        "resignationDate": resignationDate,
        "reason": reason,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}