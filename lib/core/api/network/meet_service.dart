import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';


class MeetService {

  static const String meetingBaseUrl =
      "https://kudr3e0ick.execute-api.us-east-1.amazonaws.com/";

  final ApiHelper _apiHelper =
      ApiHelper(baseUrl: meetingBaseUrl);


  // ================= ADD =================
  Future<ApiResponse<dynamic>> addMeet({
    required String meetLink,
    required String description,
    required String time,
    required Map<String, String> createdBy,
    required List<Map<String, String>> participants,
    String? agenda,
    int? duration,
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

    return await _apiHelper.post<dynamic>(
      "meeting/create",
      body,
    );
  }

  // ================= FETCH =================
  Future<ApiResponse<dynamic>> getUpcomingMeetings({
    required int month,
    required int year,
    String view = "month",
  }) async {

    final endpoint =
        "meeting/employee/me?view=$view&month=$month&year=$year";

    return await _apiHelper.get<dynamic>(endpoint);
  }

  // ================= UPDATE =================
  Future<ApiResponse<dynamic>> updateMeet({
    required String id,
    required String time,
  }) async {

    return await _apiHelper.put<dynamic>(
      "meeting/$id",
      {"time": time},
    );
  }

  // ================= DELETE =================
  Future<ApiResponse<dynamic>> deleteMeet({
    required String id,
  }) async {

    return await _apiHelper.delete<dynamic>(
      "meeting/$id",
    );
  }
}