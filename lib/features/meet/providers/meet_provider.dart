import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/meet_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum MeetState { idle, loading, success, error }

class MeetProvider extends ChangeNotifier {
  final MeetService _meetService = MeetService();
  final LoggingService _logger = LoggingService.instance;

  MeetState _state = MeetState.idle;
  String? _errorMessage;
  List<dynamic> _meetList = [];

  MeetState get state => _state;
  String? get errorMessage => _errorMessage;
  List<dynamic> get meetList => _meetList;

  // Add a new meeting
  Future<bool> addMeeting({
    required String title,
    required String location,
    required String link,
    required String startTime,
  }) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Attempting to add new meeting: $title');

    final response = await _meetService.addMeet(
      title: title,
      location: location,
      link: link,
      startTime: startTime,
    );

    if (response.success) {
      _logger.logGeneral('✅ Meeting added successfully');
      await fetchAllMeetings(); // Refresh list
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _logger.logGeneral('❌ Failed to add meeting: ${response.message}', level: LogLevel.error);
      _errorMessage = response.message;
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }

  // Fetch all meetings
  Future<void> fetchAllMeetings() async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Fetching all meetings');

    final response = await _meetService.getAllMeets();

    if (response.success && response.data != null) {
      _meetList = response.data!;
      _logger.logGeneral('✅ Meetings fetched successfully');
      _state = MeetState.success;
    } else {
      _errorMessage = response.message ?? 'Failed to fetch meetings';
      _logger.logGeneral('❌ Error fetching meetings: $_errorMessage', level: LogLevel.error);
      _state = MeetState.error;
    }

    notifyListeners();
  }

  // Update meeting start time
  Future<bool> updateMeeting({required String id, required String startTime}) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Updating meeting with ID: $id');

    final response = await _meetService.updateMeet(id: id, startTime: startTime);

    if (response.success) {
      _logger.logGeneral('✅ Meeting updated successfully');
      await fetchAllMeetings();
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _logger.logGeneral('❌ Failed to update meeting: ${response.message}', level: LogLevel.error);
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }

  // Delete meeting by ID
  Future<bool> deleteMeeting(String id) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Deleting meeting with ID: $id');

    final response = await _meetService.deleteMeet(id: id);

    if (response.success) {
      _logger.logGeneral('✅ Meeting deleted successfully');
      _meetList.removeWhere((meet) => meet['id'] == id);
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _logger.logGeneral('❌ Failed to delete meeting: ${response.message}', level: LogLevel.error);
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }
}
