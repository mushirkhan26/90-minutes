import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/leaderboard_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class LeaderboardService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  // New Base URL provided for Leaderboard/Registrations
  static const String leaderboardBaseUrl = "https://3qhglx2bhd.execute-api.us-east-1.amazonaws.com/";

  /// 🏆 Get Leaderboard
  /// recognition/getLeaderboard?filterType=all
  Future<ApiResponse<List<LeaderboardModel>>> getLeaderboard({String filterType = 'all'}) async {
    _logger.info('LEADERBOARD', 'Fetching leaderboard with filter: $filterType using new Base URL');
    
    // Set the new base URL before request
    _apiHelper.setBaseUrl(leaderboardBaseUrl);

    final response = await _apiHelper.get<dynamic>('recognition/getLeaderboard?filterType=$filterType');

    if (response.success && response.data != null) {
      try {
        final List<dynamic> dataList = response.data['message']['leaderboard'] ?? [];
        final leaderboard = dataList.map((json) => LeaderboardModel.fromJson(json)).toList();
        return ApiResponse.success(leaderboard);
      } catch (e) {
        _logger.error('LEADERBOARD', 'Error parsing leaderboard data', error: e);
        return ApiResponse.error('Failed to parse leaderboard data');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch leaderboard');
  }

  /// 📊 Get User Stats
  /// recognition/getUserStats?employeeId=26010001&filterType=all
  Future<ApiResponse<UserStatsModel>> getUserStats({required String employeeId, String filterType = 'all'}) async {
    _logger.info('LEADERBOARD', 'Fetching user stats for: $employeeId, filter: $filterType using new Base URL');
    
    // Set the new base URL before request
    _apiHelper.setBaseUrl(leaderboardBaseUrl);

    final response = await _apiHelper.get<dynamic>('recognition/getUserStats?employeeId=$employeeId&filterType=$filterType');

    if (response.success && response.data != null) {
      try {
        final data = response.data['message'];
        if (data != null) {
          return ApiResponse.success(UserStatsModel.fromJson(data));
        }
      } catch (e) {
        _logger.error('LEADERBOARD', 'Error parsing user stats', error: e);
        return ApiResponse.error('Failed to parse user stats data');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch user stats');
  }
}
