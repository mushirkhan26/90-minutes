import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class ClockService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// Clock In
  Future<ApiResponse<Map<String, dynamic>>> clockIn({
    required String employeeId,
    required String name,
    required String department,
    required String clockIn,
    required String imageUrl,
    required String date,
  }) async {
    final body = {
      "employeeId": employeeId,
      "name": name,
      "department": department,
      "clockIn": clockIn,
      "imageUrl": imageUrl,
      "date": date,
    };
    _logger.logAuth('Clocking in for employeeId: $employeeId');
    return await _apiHelper.post<Map<String, dynamic>>('attendence/add', body);
  }

  /// Clock Out
  Future<ApiResponse<Map<String, dynamic>>> clockOut({
    required String employeeId,
  }) async {
    final body = {"employeeId": employeeId};
    _logger.logAuth('Clocking out for employeeId: $employeeId');
    return await _apiHelper.post<Map<String, dynamic>>(
      'attendence/clockOut',
      body,
    );
  }

  /// Update Break Time
  Future<ApiResponse<Map<String, dynamic>>> updateBreakTime({
    required String attendenceId,
    required String newBreakTime,
  }) async {
    final body = {"attendenceId": attendenceId, "newBreakTime": newBreakTime};
    _logger.logAuth('Updating break time for attendenceId: $attendenceId');
    return await _apiHelper.put<Map<String, dynamic>>(
      'attendence/addTime',
      body,
    );
  }

  /// Update Meeting Time
  Future<ApiResponse<Map<String, dynamic>>> updateMeetingTime({
    required String attendenceId,
    required String newMeetingTime,
  }) async {
    final body = {
      "attendenceId": attendenceId,
      "newMeetingTime": newMeetingTime,
    };
    _logger.logAuth('Updating meeting time for attendenceId: $attendenceId');
    return await _apiHelper.put<Map<String, dynamic>>(
      'attendence/addTime',
      body,
    );
  }

  /// Get Attendance
  Future<ApiResponse<Map<String, dynamic>>> getAttendance({
    required String date,
    required String employeeId,
  }) async {
    final body = {"date": date, "employeeId": employeeId};
    _logger.logAuth(
      'Fetching attendance for employeeId: $employeeId on date: $date',
    );
    return await _apiHelper.post<Map<String, dynamic>>(
      'attendence/getAttentence',
      body,
    );
  }
}
