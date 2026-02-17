import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/performance_service.dart';
import 'package:hrtz_hrms/core/api/network/employee_service.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum PerformanceState { idle, loading, success, error }

class PerformanceProvider extends ChangeNotifier {
  final PerformanceService _performanceService = PerformanceService();
  final EmployeeService _employeeService = EmployeeService();
  final LoggingService _logger = LoggingService.instance;
  final LocalStorageService _local = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();

  PerformanceState _myState = PerformanceState.idle;
  PerformanceState _teamState = PerformanceState.idle;
  PerformanceState _reviewsState = PerformanceState.idle;
  
  String? _errorMessage;
  List<PerformanceModel> _myRatings = [];
  List<PerformanceModel> _allRatings = [];
  List<PerformanceModel> _selectedEmployeeReviews = [];

  String _myFilterType = "Default (Recent)";
  String _teamFilterType = "All Ratings";
  String _searchQuery = "";
  String? _currentUserId;

  PerformanceProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await _refreshData();
  }

  Future<void> _loadFromLocal() async {
    _myState = PerformanceState.loading;
    _teamState = PerformanceState.loading;
    notifyListeners();

    try {
      final cachedMy = await _local.getPerformanceRatings(LocalStorageService.keyMyRatings);
      if (cachedMy != null) {
        _myRatings = cachedMy;
        _myState = PerformanceState.success;
      }

      final cachedTeam = await _local.getPerformanceRatings(LocalStorageService.keyTeamRatings);
      if (cachedTeam != null) {
        _allRatings = cachedTeam;
        _teamState = PerformanceState.success;
      }
    } catch (e) {
      _logger.error('PERFORMANCE_PROVIDER', 'Error loading from local storage', error: e);
    }
    notifyListeners();
  }

  Future<void> _refreshData() async {
    _currentUserId = await _secureStorage.getEmployeeId();
    if (_currentUserId != null) {
      await fetchMyPerformance(_currentUserId!);
    }
    await fetchTeamPerformance();
  }

  PerformanceState get state => _reviewsState;
  PerformanceState get myState => _myState;
  PerformanceState get teamState => _teamState;
  PerformanceState get reviewsState => _reviewsState;
  
  String? get errorMessage => _errorMessage;
  List<PerformanceModel> get selectedEmployeeReviews => _selectedEmployeeReviews;

  List<PerformanceModel> get myRatings {
    List<PerformanceModel> list = List.from(_myRatings);
    if (_myFilterType == "Highest to Lowest") {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_myFilterType == "Lowest to Highest") {
      list.sort((a, b) => a.rating.compareTo(b.rating));
    } else if (_myFilterType.contains("Stars") || _myFilterType.contains("Star")) {
      int stars = int.parse(_myFilterType.split(" ")[0]);
      list = list.where((r) => r.rating.floor() == stars).toList();
    }
    return list;
  }
  
  List<PerformanceModel> get allRatings {
    List<PerformanceModel> list = List.from(_allRatings);
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) => 
        r.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.employeeId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_teamFilterType != "All Ratings") {
      int stars = int.parse(_teamFilterType.split(" ")[0]);
      list = list.where((r) => r.rating.floor() == stars).toList();
    }
    return list;
  }

  String get myFilterType => _myFilterType;
  String get teamFilterType => _teamFilterType;

  void setMyFilter(String value) {
    _myFilterType = value;
    notifyListeners();
  }

  void setTeamFilter(String value) {
    _teamFilterType = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> fetchMyPerformance(String employeeId) async {
    _myState = PerformanceState.loading;
    notifyListeners();
    try {
      final response = await _performanceService.getMyPerformance(employeeId);
      if (response.success && response.data != null) {
        // preserve liked state if not returned by backend
        final newRatings = response.data!;
        for (var i = 0; i < newRatings.length; i++) {
          final existing = _myRatings.firstWhere((r) => r.reviewId == newRatings[i].reviewId, orElse: () => newRatings[i]);
          if (newRatings[i].employeeLiked == false && existing.employeeLiked == true) {
             newRatings[i] = newRatings[i].copyWith(employeeLiked: true);
          }
        }
        _myRatings = newRatings;
        await _local.savePerformanceRatings(LocalStorageService.keyMyRatings, _myRatings);
        _myState = PerformanceState.success;
      } else {
        _myState = _myRatings.isNotEmpty ? PerformanceState.success : PerformanceState.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _myState = _myRatings.isNotEmpty ? PerformanceState.success : PerformanceState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchTeamPerformance() async {
    _teamState = PerformanceState.loading;
    notifyListeners();
    try {
      // 1. Fetch all employees first to ensure we have everyone
      final employeeResponse = await _employeeService.getEmployeeList();
      final List<PerformanceModel> mergedRatings = [];
      
      // 2. Fetch existing reviews
      final reviewResponse = await _performanceService.getTeamPerformance();
      
      if (employeeResponse.success && employeeResponse.data != null) {
        final allEmployees = employeeResponse.data!;
        final allReviews = reviewResponse.success ? (reviewResponse.data ?? []) : <PerformanceModel>[];

        for (var emp in allEmployees) {
          // Find if this employee has any reviews
          final empReviews = allReviews.where((r) => r.employeeId == emp.employeeID).toList();
          
          if (empReviews.isNotEmpty) {
            // Add all existing reviews for this employee
            mergedRatings.addAll(empReviews);
          } else {
            // Create a dummy/empty rating for employees with no reviews so they show up in UI
            mergedRatings.add(PerformanceModel(
              reviewId: 'none_${emp.employeeID}',
              employeeName: emp.name,
              employeeId: emp.employeeID,
              rating: 0.0,
              status: 'N/A',
              reviewPersonName: 'N/A',
              reviewPersonId: 'N/A',
              reviewText: 'No reviews yet.',
              createdAt: DateTime.now().toIso8601String(),
            ));
          }
        }
        
        _allRatings = mergedRatings;
        // Sort by employee name or recent
        _allRatings.sort((a, b) => a.employeeName.compareTo(b.employeeName));
        
        await _local.savePerformanceRatings(LocalStorageService.keyTeamRatings, _allRatings);
        _teamState = PerformanceState.success;
      } else {
        // Fallback to just reviews if employee list fails
        if (reviewResponse.success && reviewResponse.data != null) {
          _allRatings = reviewResponse.data!;
          _teamState = PerformanceState.success;
        } else {
          _teamState = _allRatings.isNotEmpty ? PerformanceState.success : PerformanceState.error;
          _errorMessage = reviewResponse.message;
        }
      }
    } catch (e) {
      _logger.error('PERFORMANCE_PROVIDER', 'Error fetching team performance', error: e);
      _teamState = _allRatings.isNotEmpty ? PerformanceState.success : PerformanceState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchReviewsForEmployee(String employeeId) async {
    _reviewsState = PerformanceState.loading;
    _selectedEmployeeReviews = [];
    notifyListeners();

    try {
      _logger.info('PERFORMANCE_PROVIDER', 'Fetching reviews for employee: $employeeId');
      
      // Get all from team ratings if available (History)
      if (_allRatings.isNotEmpty) {
        _selectedEmployeeReviews = _allRatings.where((r) => r.employeeId == employeeId && !r.reviewId.startsWith('none_')).toList();
      }

      final response = await _performanceService.getMyPerformance(employeeId);
      if (response.success && response.data != null) {
        // Merge lists to avoid duplicates and ensure we have full history + latest
        final Map<String, PerformanceModel> merged = {};
        for (var r in _selectedEmployeeReviews) { merged[r.reviewId] = r; }
        for (var r in response.data!) { merged[r.reviewId] = r; }
        
        _selectedEmployeeReviews = merged.values.toList();
        _selectedEmployeeReviews.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        
        _reviewsState = PerformanceState.success;
        _logger.info('PERFORMANCE_PROVIDER', 'Total reviews after merge: ${_selectedEmployeeReviews.length}');
      } else {
        _reviewsState = PerformanceState.success; // Still success if we have local data
      }
    } catch (e) {
      _reviewsState = PerformanceState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addReview({
    required String employeeId,
    required String reviewerId,
    required String reviewerName,
    required double rating,
    required String comment,
  }) async {
    final response = await _performanceService.addReview(
      employeeId: employeeId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      rating: rating,
      comment: comment,
    );
    if (response.success) {
      await fetchTeamPerformance();
      return true;
    }
    return false;
  }

  Future<bool> approveReview(String reviewId, String employeeId) async {
    try {
      final response = await _performanceService.approveReview(reviewId);
      if (response.success) {
        await fetchMyPerformance(employeeId);
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('PERFORMANCE_PROVIDER', 'Approve failed: $e');
      return false;
    }
  }

  Future<bool> replyToReview({
    required String reviewId,
    required String reply,
  }) async {
    final response = await _performanceService.replyToReview(
      reviewId: reviewId,
      reply: reply,
    );
    if (response.success) {
      await fetchTeamPerformance();
      return true;
    }
    return false;
  }

  Future<bool> toggleLike(String reviewId, bool currentStatus) async {
    // 1. Optimistic Update
    final newStatus = !currentStatus;
    
    // Update local state immediately
    final index = _myRatings.indexWhere((r) => r.reviewId == reviewId);
    if (index != -1) {
      _myRatings[index] = _myRatings[index].copyWith(employeeLiked: newStatus);
      notifyListeners();
    }

    try {
      final response = await _performanceService.updateLikeStatus(
        reviewId: reviewId,
        isLiked: newStatus,
      );
      
      if (response.success) {
        // Save to local storage to persist the optimistic change
        await _local.savePerformanceRatings(LocalStorageService.keyMyRatings, _myRatings);
        return true;
      } else {
        // Rollback on failure
        if (index != -1) {
          _myRatings[index] = _myRatings[index].copyWith(employeeLiked: currentStatus);
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      _logger.error('PERFORMANCE_PROVIDER', 'Toggle like failed: $e');
      // Rollback on error
      if (index != -1) {
        _myRatings[index] = _myRatings[index].copyWith(employeeLiked: currentStatus);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> updateEmployeeResponse({
    required String reviewId,
    required String comment,
  }) async {
    final responseAt = DateTime.now().toIso8601String();
    
    // 1. Optimistic Update
    final index = _myRatings.indexWhere((r) => r.reviewId == reviewId);
    String? oldComment;
    String? oldResponseAt;
    
    if (index != -1) {
      oldComment = _myRatings[index].employeeComment;
      oldResponseAt = _myRatings[index].employeeResponseAt;
      
      _myRatings[index] = _myRatings[index].copyWith(
        employeeComment: comment,
        employeeResponseAt: responseAt,
      );
      notifyListeners();
    }

    try {
      final response = await _performanceService.updateEmployeeResponse(
        reviewId: reviewId,
        comment: comment,
        responseAt: responseAt,
      );
      
      if (response.success) {
        await _local.savePerformanceRatings(LocalStorageService.keyMyRatings, _myRatings);
        return true;
      } else {
        // Rollback on failure
        if (index != -1) {
          _myRatings[index] = _myRatings[index].copyWith(
            employeeComment: oldComment,
            employeeResponseAt: oldResponseAt,
          );
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      _logger.error('PERFORMANCE_PROVIDER', 'Update response failed: $e');
      if (index != -1) {
        _myRatings[index] = _myRatings[index].copyWith(
          employeeComment: oldComment,
          employeeResponseAt: oldResponseAt,
        );
        notifyListeners();
      }
      return false;
    }
  }
}
