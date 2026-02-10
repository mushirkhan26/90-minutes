import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/api/network/leaderboard_service.dart';
import 'package:hrtz_hrms/core/models/leaderboard_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum LeaderboardState { idle, loading, success, error }

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();

  LeaderboardState _state = LeaderboardState.idle;
  String? _errorMessage;
  List<LeaderboardModel> _leaderboard = [];
  UserStatsModel? _userStats;
  String _filterType = 'all';

  LeaderboardProvider() {
    _init();
  }

  Future<void> _init() async {
    await refreshData();
  }

  LeaderboardState get state => _state;
  String? get errorMessage => _errorMessage;
  List<LeaderboardModel> get leaderboard => _leaderboard;
  UserStatsModel? get userStats => _userStats;
  String get filterType => _filterType;

  void setFilter(String filter) {
    if (_filterType == filter) return;
    _filterType = filter;
    refreshData();
  }

  Future<void> refreshData() async {
    _state = LeaderboardState.loading;
    notifyListeners();

    try {
      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception("User not logged in");

      // Fetch in parallel
      final results = await Future.wait([
        _service.getLeaderboard(filterType: _filterType),
        _service.getUserStats(employeeId: employeeId, filterType: _filterType),
      ]);

      final leaderboardRes = results[0] as ApiResponse<List<LeaderboardModel>>;
      final userStatsRes = results[1] as ApiResponse<UserStatsModel>;

      if (leaderboardRes.success) {
        _leaderboard = leaderboardRes.data ?? [];
      }

      if (userStatsRes.success) {
        _userStats = userStatsRes.data;
      }

      _state = LeaderboardState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LeaderboardState.error;
      _logger.error('LEADERBOARD_PROVIDER', 'Refresh failed', error: e);
    }
    notifyListeners();
  }
}
