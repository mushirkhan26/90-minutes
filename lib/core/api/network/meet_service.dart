import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class MeetService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: ApiHelper.otherBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  // Add Meeting with all dynamic fields
  Future<ApiResponse<dynamic>> addMeet({
  required String meetLink,
  required String description,
  required String time,
  required Map<String, String> createdBy,
  required List<Map<String, String>> participants,
  String? agenda,
  int? duration,
  String? recurrence,
}) async {

  final dateTime = DateTime.parse(time).toLocal();

  final meetingDate =
      "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

  final meetingTime =
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  final body = {
    "meetingTitle": description.trim(),
    "organizer": createdBy['employeeId'],
    "joiners": participants.map((p) => p['employeeId']).toList(),
    "meetingSummary": agenda ?? "",
    "meetingLink": meetLink,
    "meetingDate": meetingDate,
    "meetingTime": meetingTime,
    "duration": duration ?? 30,
    "attachments": [],
    "isRecurring": false,
    "recurrencePattern": "",
    "startDate": "",
    "endDate": ""
  };

  _logger.logGeneral('Adding new meeting: $description');

  // 🔥 DIRECT FULL URL (No baseUrl confusion)
  return await ApiHelper(
    baseUrl: "https://kudr3e0ick.execute-api.us-east-1.amazonaws.com/",
  ).post<dynamic>(
    "meeting/create",
    body,
  );
}
  Future<ApiResponse<dynamic>> getUpcomingMeetings() async {
    _logger.logGeneral('Fetching dynamic meetings via /me');
    return await _apiHelper.get<dynamic>('meet/employee/me');
  }

  // Update Meeting
  Future<ApiResponse<dynamic>> updateMeet({required String id, required String time}) async {
    return await _apiHelper.put<dynamic>('meet/$id', {"time": time});
  }

  // Delete Meeting
  Future<ApiResponse<dynamic>> deleteMeet({required String id}) async {
    return await _apiHelper.delete<dynamic>('meet/$id');
  }
}
