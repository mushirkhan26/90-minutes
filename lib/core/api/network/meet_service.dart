// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../models/meet_model.dart';

// class MeetService {
//   static const String baseUrl = 'https://hrms-socket.onrender.com';

//   Future<List<Meet>> getAllMeets() async {
//     final response = await http.get(Uri.parse('$baseUrl/meet/getAll'));
//     if (response.statusCode == 200) {
//       final List data = jsonDecode(response.body);
//       return data.map((item) => Meet.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load meetings');
//     }
//   }

//   Future<Meet> addMeet(Meet meet) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/meet/add'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(meet.toJson()),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return Meet.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to add meeting');
//     }
//   }

//   Future<void> updateMeet(String id, DateTime startTime) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/meet/update/$id'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'startTime': startTime.toIso8601String()}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to update meeting');
//     }
//   }

//   Future<void> deleteMeet(String id) async {
//     final response = await http.delete(Uri.parse('$baseUrl/meet/delete/$id'));
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete meeting');
//     }
//   }
// }

import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class MeetService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  // Add Meeting
  Future<ApiResponse<Map<String, dynamic>>> addMeet({
    required String title,
    required String location,
    required String link,
    required String startTime,
  }) async {
    final body = {
      "title": title,
      "location": location,
      "link": link,
      "startTime": startTime,
    };

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
  Future<ApiResponse<Map<String, dynamic>>> deleteMeet({
    required String id,
  }) async {
    _logger.logGeneral('Deleting meeting with ID: $id');
    return await _apiHelper.delete<Map<String, dynamic>>('meet/delete/$id');
  }
}
