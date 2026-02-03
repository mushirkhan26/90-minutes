import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/auth_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class LeaveProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _localStorage = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  Map<String, dynamic>? _leaveHistory;
  Map<String, dynamic>? _availableLeave;
  List<dynamic> _allLeaveRequests = [];
  bool _isLoading = false;

  Map<String, dynamic>? get leaveHistory => _leaveHistory;
  Map<String, dynamic>? get availableLeave => _availableLeave;
  List<dynamic> get allLeaveRequests => _allLeaveRequests;
  bool get isLoading => _isLoading;

  Future<void> fetchLeaveInfo({required String employeeId, bool clearCache = false}) async {
    _isLoading = true;
    if (clearCache) {
      _leaveHistory = null;
    }
    notifyListeners();

    await Future.wait([
      fetchLeaveHistory(employeeId: employeeId, useCache: !clearCache),
      fetchAvailableLeave(employeeId: employeeId),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLeaveHistory({required String employeeId, bool useCache = true}) async {
    try {
      if (useCache) {
        final cachedData = await _localStorage.getLeaveHistory();
        if (cachedData != null && _leaveHistory == null) {
          _leaveHistory = cachedData;
          notifyListeners();
        }
      }

      final response = await _authService.getLeaveHistory(employeeId: employeeId);
      if (response.success && response.data != null) {
        _leaveHistory = response.data!;
        
        // 🚀 Fix: Sort history by createdOn descending to ensure newest is always at the top
        if (_leaveHistory?['message']?['data'] != null) {
          final List<dynamic> data = List.from(_leaveHistory!['message']['data']);
          data.sort((a, b) {
            final dateA = DateTime.tryParse(a['createdOn'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['createdOn'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA); // Newest first
          });
          _leaveHistory!['message']['data'] = data;
        }
        
        await _localStorage.saveLeaveHistory(_leaveHistory!);
        notifyListeners(); // Ensure UI updates with fresh API data
      } else if (response.message != null && response.message!.contains("No leave records found")) {
        _leaveHistory = {
          'message': {'data': []}
        };
        await _localStorage.saveLeaveHistory(_leaveHistory!);
        notifyListeners();
      }
    } catch (e) {
      _logger.error('LEAVE_PROVIDER', 'Error fetching leave history', error: e);
    }
  }

  Future<void> fetchAvailableLeave({required String employeeId}) async {
    try {
      final cachedData = await _localStorage.getAvailableLeave();
      if (cachedData != null && _availableLeave == null) {
        _availableLeave = cachedData;
        notifyListeners();
      }

      final response = await _authService.getAvailableLeave(employeeId: employeeId);
      if (response.success && response.data != null) {
        _availableLeave = response.data!;
        await _localStorage.saveAvailableLeave(_availableLeave!);
        notifyListeners();
      }
    } catch (e) {
      _logger.error('LEAVE_PROVIDER', 'Error fetching available leave', error: e);
    }
  }

  /// Admin: Fetch all leave requests
  Future<void> fetchAllLeaveRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.getAllLeaveRequests();
      if (response.success && response.data != null) {
        final rawData = response.data!;
        
        if (rawData['message'] is List) {
          _allLeaveRequests = rawData['message'];
        } else if (rawData['data'] is List) {
          _allLeaveRequests = rawData['data'];
        } else if (rawData['message'] is Map && rawData['message']['data'] is List) {
          _allLeaveRequests = rawData['message']['data'];
        } else {
          _allLeaveRequests = [];
        }
        
        // 🚀 Sort admin requests by createdOn descending
        _allLeaveRequests.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdOn'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['createdOn'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
      }
    } catch (e) {
      _logger.error('LEAVE_PROVIDER', 'Error fetching all leave requests', error: e);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Admin: Update leave status (Approve/Reject)
  Future<(bool success, String message)> updateLeaveStatus({
    required String leaveId,
    required String status,
  }) async {
    try {
      final updatedBy = await _secureStorage.getUserName() ?? "Admin";
      final response = await _authService.updateLeaveStatus(
        leaveId: leaveId,
        status: status,
        updatedBy: updatedBy,
      );

      if (response.success) {
        await fetchAllLeaveRequests();
        return (true, 'Leave status updated to $status');
      } else {
        return (false, response.message ?? 'Failed to update leave status');
      }
    } catch (e) {
      return (false, 'An unexpected error occurred');
    }
  }

  Future<(bool success, String message)> addLeaveRequest({
    required String name,
    required String employeeId,
    required String startDate,
    required String endDate,
    required String reason,
    required int duration,
    required String type,
    String? medicalCertificate,
  }) async {
    final response = await _authService.addLeaveRequest(
      name: name,
      employeeId: employeeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      duration: duration,
      type: type,
      medicalCertificate: medicalCertificate,
    );

    if (response.success) {
      // 🚀 Ensure immediate refresh of locally sorted data
      final Map<String, dynamic> newLeave = {
        'employeeId': employeeId,
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
        'duration': duration,
        'type': type,
        'leaveStatus': 'Waiting',
        'createdOn': DateTime.now().toIso8601String(),
        'leaveId': response.data?['leaveId'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      };

      if (_leaveHistory != null && _leaveHistory!['message'] != null && _leaveHistory!['message']['data'] != null) {
        final List<dynamic> data = List.from(_leaveHistory!['message']['data']);
        data.insert(0, newLeave); // Add to the top immediately
        _leaveHistory!['message']['data'] = data;
        notifyListeners();
      }

      // Then trigger background refresh to sync with server
      await Future.delayed(const Duration(seconds: 1));
      await fetchLeaveInfo(employeeId: employeeId, clearCache: true);
      
      return (true, 'Leave request added successfully');
    } else {
      return (false, response.message ?? 'Failed to add leave request');
    }
  }

  Future<(bool success, String message)> deleteLeaveRequest({
    required String leaveId,
    required String employeeId,
  }) async {
    final updatedBy = await _secureStorage.getUserName() ?? "";
    final response = await _authService.deleteLeaveRequest(
      leaveId: leaveId, 
      updatedBy: updatedBy
    );

    if (response.success) {
      await fetchLeaveInfo(employeeId: employeeId, clearCache: true);
      return (true, 'Leave request cancelled successfully');
    } else {
      return (false, response.message ?? 'Failed to cancel leave request');
    }
  }
}
