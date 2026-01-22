import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class MeetService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: ApiHelper.otherBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  // Add Meeting
  Future<ApiResponse<dynamic>> addMeet({
    required String meetLink,
    required String description,
    required String time,
    required Map<String, String> createdBy,
    required List<Map<String, String>> participants,
  }) async {
    final body = {
      "meetLink": meetLink,
      "createdBy": createdBy,
      "participants": participants,
      "time": time,
      "description": description,
    };
    _logger.logGeneral('Adding new meeting: $description at $time');
    return await _apiHelper.post<dynamic>('meet', body);
  }

  // Get Upcoming Meetings
  Future<ApiResponse<dynamic>> getUpcomingMeetings({
    required String employeeId,
  }) async {
    _logger.logGeneral('Fetching upcoming meetings for employeeId: $employeeId');
    return await _apiHelper.get<dynamic>('meet/upcoming/$employeeId');
  }

  // Get Meetings for Today
  Future<ApiResponse<dynamic>> getMeetingsForToday({
    required String employeeId,
  }) async {
    _logger.logGeneral('Fetching meetings for today for employeeId: $employeeId');
    return await _apiHelper.get<dynamic>('meet/today/$employeeId');
  }

  // Update Meeting
  Future<ApiResponse<dynamic>> updateMeet({
    required String id,
    required String time,
  }) async {
    final body = {"time": time};
    _logger.logGeneral('Updating meeting with ID: $id');
    // Fix: Corrected endpoint path based on server error log
    return await _apiHelper.put<dynamic>('meet/$id', body);
  }

  // Delete Meeting
  Future<ApiResponse<dynamic>> deleteMeet({required String id}) async {
    _logger.logGeneral('Deleting meeting with ID: $id');
    return await _apiHelper.delete<dynamic>('meet/$id');
  }
}
