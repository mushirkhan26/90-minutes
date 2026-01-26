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
    final body = {
      "meetLink": meetLink,
      "createdBy": createdBy,
      "participants": participants,
      "time": time,
      "description": description,
      "agenda": agenda ?? "",
      "duration": duration ?? 30,
      "recurrence": recurrence ?? "One-time meeting",
    };
    _logger.logGeneral('Adding dynamic meeting: $description');
    return await _apiHelper.post<dynamic>('meet', body);
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
