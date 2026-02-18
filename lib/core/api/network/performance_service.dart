import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class PerformanceService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// 📈 Get my performance ratings
  Future<ApiResponse<List<PerformanceModel>>> getMyPerformance(String employeeId) async {
    _logger.info('PERFORMANCE_SERVICE', 'Fetching my performance ratings for: $employeeId');
    final response = await _apiHelper.post<Map<String, dynamic>>(
      'review/getByData',
      {'employeeId': employeeId},
    );
    
    if (response.success && response.data != null) {
      final List<dynamic> ratingsJson = response.data!['message'] ?? [];
      final ratings = ratingsJson.map((json) => PerformanceModel.fromJson(json)).toList();
      return ApiResponse.success(ratings);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch performance ratings');
  }

  /// 👥 Get team performance ratings (Manager/Admin)
  Future<ApiResponse<List<PerformanceModel>>> getTeamPerformance() async {
    _logger.info('PERFORMANCE_SERVICE', 'Fetching team performance ratings');
    final response = await _apiHelper.get<Map<String, dynamic>>('review/getAll');
    
    if (response.success && response.data != null) {
      final List<dynamic> teamJson = response.data!['message'] ?? [];
      final teamPerformance = teamJson.map((json) => PerformanceModel.fromJson(json)).toList();
      return ApiResponse.success(teamPerformance);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch team performance ratings');
  }

  /// 📝 Add a performance review
  Future<ApiResponse<Map<String, dynamic>>> addReview({
    required String employeeId,
    required String employeeName,
    required String reviewerId,
    required String reviewerName,
    required double rating,
    required String comment,
  }) async {
   final body = {
    "employeeId": employeeId,
    "employeeName": employeeName,
    "rating": rating,
    "reviewPersonId": reviewerId,
    "reviewPersonName": reviewerName,
    "reviewText": comment,
  };
    return await _apiHelper.post<Map<String, dynamic>>('review/add', body);
  }

  /// ✅ Approve a review
  Future<ApiResponse<Map<String, dynamic>>> approveReview(String reviewId) async {
    return await _apiHelper.put<Map<String, dynamic>>('review/approve/$reviewId', {});
  }

  /// 💬 Reply to a review
  Future<ApiResponse<Map<String, dynamic>>> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    final body = {"reply": reply};
    return await _apiHelper.put<Map<String, dynamic>>('review/reply/$reviewId', body);
  }

  /// ❤️ Update Like status
  Future<ApiResponse<Map<String, dynamic>>> updateLikeStatus({
    required String reviewId,
    required bool isLiked,
  }) async {
    final body = {"employeeLiked": isLiked};
    return await _apiHelper.put<Map<String, dynamic>>('review/update/$reviewId', body);
  }

  /// 💬 Update Employee Comment/Response
  Future<ApiResponse<Map<String, dynamic>>> updateEmployeeResponse({
    required String reviewId,
    required String comment,
    required String responseAt,
  }) async {
    final body = {
      "employeeComment": comment,
      "employeeResponseAt": responseAt,
    };
    return await _apiHelper.put<Map<String, dynamic>>('review/update/$reviewId', body);
  }
}
