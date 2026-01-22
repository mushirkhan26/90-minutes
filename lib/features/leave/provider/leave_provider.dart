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
  bool _isLoading = false;

  Map<String, dynamic>? get leaveHistory => _leaveHistory;
  Map<String, dynamic>? get availableLeave => _availableLeave;
  bool get isLoading => _isLoading;

  Future<void> fetchLeaveInfo({required String employeeId}) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchLeaveHistory(employeeId: employeeId),
      fetchAvailableLeave(employeeId: employeeId),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLeaveHistory({required String employeeId}) async {
    try {
      final cachedData = await _localStorage.getLeaveHistory();
      if (cachedData != null) {
        _leaveHistory = cachedData;
      }

      final response = await _authService.getLeaveHistory(employeeId: employeeId);
      if (response.success && response.data != null) {
        _leaveHistory = response.data!;
        await _localStorage.saveLeaveHistory(_leaveHistory!);
      } else if (response.message != null && response.message!.contains("No leave records found")) {
        _leaveHistory = {
          'message': {'data': []}
        };
        await _localStorage.saveLeaveHistory(_leaveHistory!);
      }
    } catch (e) {
      _logger.error('LEAVE_PROVIDER', 'Error fetching leave history', error: e);
    }
    notifyListeners();
  }

  Future<void> fetchAvailableLeave({required String employeeId}) async {
    try {
      final cachedData = await _localStorage.getAvailableLeave();
      if (cachedData != null) {
        _availableLeave = cachedData;
      }

      final response = await _authService.getAvailableLeave(employeeId: employeeId);
      if (response.success && response.data != null) {
        _availableLeave = response.data!;
        await _localStorage.saveAvailableLeave(_availableLeave!);
      }
    } catch (e) {
      _logger.error('LEAVE_PROVIDER', 'Error fetching available leave', error: e);
    }
    notifyListeners();
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
      await fetchLeaveInfo(employeeId: employeeId);
      return (true, 'Leave request added successfully');
    } else {
      return (false, response.message ?? 'Failed to add leave request');
    }
  }

  Future<(bool success, String message)> deleteLeaveRequest({
    required String leaveId,
    required String employeeId,
  }) async {
    // 🔍 Find the leave in local history for restoration
    final leaveData = _leaveHistory?['message']?['data'] as List?;
    Map<String, dynamic>? leaveToRestore;
    if (leaveData != null) {
      leaveToRestore = leaveData.firstWhere(
        (l) => (l['leaveId'] ?? l['_id'])?.toString() == leaveId, 
        orElse: () => null
      );
    }

    // ✅ Fix: Pass updatedBy name to the API
    final updatedBy = await _secureStorage.getUserName() ?? "";
    final response = await _authService.deleteLeaveRequest(
      leaveId: leaveId, 
      updatedBy: updatedBy
    );

    if (response.success) {
      // ✅ Step 2: Optimistic Restore of leaves locally
      if (leaveToRestore != null && _availableLeave != null) {
        final type = leaveToRestore['type'];
        final duration = int.tryParse(leaveToRestore['duration']?.toString() ?? '0') ?? 0;
        
        if (_availableLeave!['available'] != null && _availableLeave!['available'][type] != null) {
          _availableLeave!['available'][type] = (_availableLeave!['available'][type] ?? 0) + duration;
          await _localStorage.saveAvailableLeave(_availableLeave!);
          notifyListeners();
        }
      }

      await fetchLeaveInfo(employeeId: employeeId);
      return (true, 'Leave request cancelled successfully');
    } else {
      return (false, response.message ?? 'Failed to cancel leave request');
    }
  }
}
