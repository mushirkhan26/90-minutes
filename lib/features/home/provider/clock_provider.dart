import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/api/network/clock_service.dart';
import '../../../core/models/clock_in_out_model.dart';

enum ClockState { idle, loading, success, error }

class ClockProvider extends ChangeNotifier {
  final ClockService _clockService = ClockService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  ClockState _state = ClockState.idle;
  String? _errorMessage;
  ClockModel? _attendanceModel;
  String? _startTime;
  String? _endTime;
  String? _workedDuration;
  bool _isClockedIn = false;
  bool _isClockedOut = false;
  String? _capturedImageUrl;

  // Getters
  ClockState get state => _state;
  String? get errorMessage => _errorMessage;
  ClockModel? get attendanceModel => _attendanceModel;
  String? get startTime => _startTime;
  String? get endTime => _endTime;
  String? get workedDuration => _workedDuration;
  bool get isClockedIn => _isClockedIn;
  bool get isClockedOut => _isClockedOut;
  String? get capturedImageUrl => _capturedImageUrl;

  // Setter for capturedImageUrl
  void setCapturedImageUrl(String? url) {
    _capturedImageUrl = url;
    notifyListeners();
  }

  /// Clock In
  Future<void> clockIn({
    required String imageUrl,
    required String department,
  }) async {
    _state = ClockState.loading;
    notifyListeners();

    final employeeId = await _secureStorage.getEmployeeId();
    final data = await _secureStorage.getUserData();

    if (employeeId == null) {
      _state = ClockState.error;
      _errorMessage = 'Employee ID not found';
      _logger.logAuth('❌ Employee ID not found', level: LogLevel.error);
      notifyListeners();
      return;
    }

    // Set start time
    _startTime = DateTime.now()
        .toLocal()
        .toString()
        .split(' ')[1]
        .split('.')[0];

    final response = await _clockService.clockIn(
      employeeId: employeeId,
      name: data!['username'],
      department: department,
      clockIn: DateTime.now().toUtc().toIso8601String(),
      imageUrl: imageUrl,
      date:
          '${DateTime.now().toUtc().toIso8601String().split('T')[0]}T00:00:00Z',
    );

    if (response.success && response.data != null) {
      _attendanceModel = ClockModel.fromJson(response.data!);
      _state = ClockState.success;
      _isClockedIn = true;
      _logger.logAuth('✅ Clocked in successfully');
    } else {
      _state = ClockState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Clock in failed: ${response.message}',
        level: LogLevel.error,
      );
    }
    notifyListeners();
  }

  /// Clock Out
  Future<void> clockOut() async {
    _state = ClockState.loading;
    notifyListeners();

    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) {
      _state = ClockState.error;
      _errorMessage = 'Employee ID not found';
      _logger.logAuth('❌ Employee ID not found', level: LogLevel.error);
      notifyListeners();
      return;
    }

    // Set end time
    _endTime = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0];

    // Calculate worked duration
    if (_startTime != null && _endTime != null) {
      final start = DateTime.parse('1970-01-01 $_startTime');
      final end = DateTime.parse('1970-01-01 $_endTime');
      final duration = end.difference(start);
      _workedDuration = duration.toString().split('.')[0];
    }

    final response = await _clockService.clockOut(employeeId: employeeId);
    if (response.success && response.data != null) {
      _attendanceModel = ClockModel.fromJson(response.data!);
      _state = ClockState.success;
      _isClockedOut = true;
      _logger.logAuth('✅ Clocked out successfully');
    } else {
      _state = ClockState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Clock out failed: ${response.message}',
        level: LogLevel.error,
      );
    }
    notifyListeners();
  }

  /// Update Break Time
  Future<void> updateBreakTime({
    required String attendenceId,
    required String newBreakTime,
  }) async {
    _state = ClockState.loading;
    notifyListeners();
    final response = await _clockService.updateBreakTime(
      attendenceId: attendenceId,
      newBreakTime: newBreakTime,
    );
    if (response.success && response.data != null) {
      _attendanceModel = ClockModel.fromJson(response.data!);
      _state = ClockState.success;
      _logger.logAuth('✅ Break time updated successfully');
    } else {
      _state = ClockState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Break time update failed: ${response.message}',
        level: LogLevel.error,
      );
    }
    notifyListeners();
  }

  /// Update Meeting Time
  Future<void> updateMeetingTime({
    required String attendenceId,
    required String newMeetingTime,
  }) async {
    _state = ClockState.loading;
    notifyListeners();
    final response = await _clockService.updateMeetingTime(
      attendenceId: attendenceId,
      newMeetingTime: newMeetingTime,
    );
    if (response.success && response.data != null) {
      _attendanceModel = ClockModel.fromJson(response.data!);
      _state = ClockState.success;
      _logger.logAuth('✅ Meeting time updated successfully');
    } else {
      _state = ClockState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Meeting time update failed: ${response.message}',
        level: LogLevel.error,
      );
    }
    notifyListeners();
  }

  /// Get Attendance
  Future<void> getAttendance({required String date}) async {
    _state = ClockState.loading;
    notifyListeners();

    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId == null) {
      _state = ClockState.error;
      _errorMessage = 'Employee ID not found';
      _logger.logAuth('❌ Employee ID not found', level: LogLevel.error);
      notifyListeners();
      return;
    }

    final response = await _clockService.getAttendance(
      date: date,
      employeeId: employeeId,
    );

    final records = response.data?['message']['records'] as List<dynamic>?;

    if (response.success && records != null && records.isNotEmpty) {
      _attendanceModel = ClockModel.fromJson(records[0]);
      _isClockedIn = _attendanceModel!.clockIn.isNotEmpty;
      _isClockedOut = _attendanceModel!.clockOut?.isNotEmpty == true;
      _state = ClockState.success;
      _logger.logAuth('✅ Attendance fetched successfully');
    } else {
      _state = ClockState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Attendance fetch failed: ${response.message}',
        level: LogLevel.error,
      );
    }
    if (response.data?['message']['leaveStatus'] == true) {
      _isClockedOut = true;
      _isClockedIn = true;
    }

    notifyListeners();
  }
}
