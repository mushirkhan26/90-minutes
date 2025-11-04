import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class MeetService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: ApiHelper.otherBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  // Add Meeting
  Future<ApiResponse<Map<String, dynamic>>> addMeet({
    required String title,
    required String location,
    required String link,
    required String startTime,
  }) async {
    final body = {"title": title, "location": location, "link": link, "startTime": startTime};

    _logger.logGeneral('Adding new meeting: $title at $location');
    return await _apiHelper.post<Map<String, dynamic>>('meet/add', body);
  }

  // Get All Meetings
  Future<ApiResponse<List<dynamic>>> getAllMeets() async {
    _logger.logGeneral('Fetching all meetings');
    return await _apiHelper.get<List<dynamic>>('meet/getAll');
  }

  // Update Meeting
  Future<ApiResponse<Map<String, dynamic>>> updateMeet({
    required String id,
    required String startTime,
  }) async {
    final body = {"startTime": startTime};

    _logger.logGeneral('Updating meeting with ID: $id');
    return await _apiHelper.put<Map<String, dynamic>>('meet/update/$id', body);
  }

  // Delete Meeting
  Future<ApiResponse<Map<String, dynamic>>> deleteMeet({required String id}) async {
    _logger.logGeneral('Deleting meeting with ID: $id');
    return await _apiHelper.delete<Map<String, dynamic>>('meet/delete/$id');
  }
}
