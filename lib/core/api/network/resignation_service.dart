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
      {'resignationDate': resignationDate, 'reason': reason},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResponse<List<dynamic>>> getAllResignations() async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      return ApiResponse.error('Token missing');
    }

    return await _apiHelper.get<List<dynamic>>(
      'resignation/all',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateResignationStatus({
    required String resignationId,
    required String status,
    String? comments,
  }) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      return ApiResponse.error('Token missing');
    }

    return await _apiHelper.put<Map<String, dynamic>>(
      'resignation/$resignationId/status',
      {'status': status, 'comments': comments ?? ''},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // Future<ApiResponse<Map<String, dynamic>>> uploadDocument({
  //   required String resignationId,
  //   required String documentUrl,
  // }) async {
  //   final token = await _storage.getToken();

  //   if (token == null || token.isEmpty) {
  //     return ApiResponse.error('Token missing');
  //   }

  //   return await _apiHelper.put<Map<String, dynamic>>(
  //     'resignation/uploadDocument/$resignationId',
  //     {'newDocument': documentUrl},
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  // }

  Future<ApiResponse<Map<String, dynamic>>> uploadDocument({
    required String resignationId,
    required String documentUrl,
  }) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      return ApiResponse.error('Token missing');
    }

    return await _apiHelper.put<Map<String, dynamic>>(
      'resignation/uploadDocument/$resignationId',
      {
        'newDocument': {'name': 'Resignation Document', 'url': documentUrl},
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResponse<dynamic>> getMyResignation() async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      return ApiResponse.error('Token missing');
    }

    return await _apiHelper.get<dynamic>(
      'resignation/my',
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
