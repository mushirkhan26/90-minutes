import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/meet_service.dart';
import 'package:hrtz_hrms/core/models/meet_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum MeetState { idle, loading, success, error }

class MeetProvider extends ChangeNotifier {
  final MeetService _meetService = MeetService();
  final LoggingService _logger = LoggingService.instance;
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalStorageService _localStorage = LocalStorageService();

  MeetState _state = MeetState.idle;
  String? _errorMessage;
  List<Meet> _meetList = [];
  List<Meet> _filteredMeetList = [];

  MeetState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Meet> get meetList => _filteredMeetList.isNotEmpty ? _filteredMeetList : _meetList;

  static const cacheValidity = Duration(minutes: 10);

  Future<void> fetchUpcomingMeetings({bool forceRefresh = false}) async {
    _state = MeetState.loading;
    notifyListeners();

    try {
      // Load cached data if available
      final cachedMeets = await _localStorage.getMeetList();
      final lastCacheTime = await _localStorage.getMeetListTimestamp();
      final now = DateTime.now();

      if (cachedMeets != null && cachedMeets.isNotEmpty) {
        _meetList = cachedMeets;
        _state = MeetState.success;
        notifyListeners();
      }

      final shouldRefresh =
          forceRefresh || lastCacheTime == null || now.difference(lastCacheTime) > cacheValidity;

      if (!shouldRefresh && cachedMeets != null && cachedMeets.isNotEmpty) {
        _logger.logStorage('🟢 Meet cache still valid, skipping API call');
        return;
      }

      // Fetch from API
      final employeeId = await _secureStorage.getEmployeeId();
      if (employeeId == null) throw Exception('Employee ID not found');

      // Changed from getMeetingsForToday to getUpcomingMeetings to show future meetings
      final response = await _meetService.getUpcomingMeetings(employeeId: employeeId);

      if (response.success && response.data != null) {
        final List<dynamic> meetsJson = response.data!['data'] as List<dynamic>;
        _meetList = meetsJson.map((json) => Meet.fromJson(json)).toList();
        await _localStorage.saveMeetList(_meetList);
        _state = MeetState.success;
        _logger.logNetwork('✅ Meets refreshed (${_meetList.length} meets)');
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _errorMessage = 'Failed to fetch meets: $e';
      _logger.error('MEET_PROVIDER', 'fetchUpcomingMeetings failed', error: e, stackTrace: s);
      if (_meetList.isEmpty) _state = MeetState.error;
    }
    notifyListeners();
  }

  void searchMeets(String query) {
    if (query.isEmpty) {
      _filteredMeetList = [];
    } else {
      _filteredMeetList = _meetList.where((meet) {
        return meet.description.toLowerCase().contains(query.toLowerCase()) ||
            meet.createdBy['name']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> addMeeting({
    required String meetLink,
    required String description,
    required String time,
    required List<Map<String, String>> participants,
  }) async {
    _state = MeetState.loading;
    notifyListeners();

    final employeeId = await _secureStorage.getEmployeeId();
    final employeeName = await _secureStorage.getUserName();

    _logger.logGeneral('Attempting to add new meeting: $description');
    final response = await _meetService.addMeet(
      meetLink: meetLink,
      description: description,
      time: time,
      createdBy: {"employeeId": employeeId ?? "", "name": employeeName ?? ""},
      participants: participants,
    );

    if (response.success) {
      _logger.logGeneral('✅ Meeting added successfully');
      await fetchUpcomingMeetings(); // Refresh list
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _logger.logGeneral('❌ Failed to add meeting: ${response.message}', level: LogLevel.error);
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeeting({required String id, required String time}) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Updating meeting with ID: $id');
    final response = await _meetService.updateMeet(id: id, time: time);

    if (response.success) {
      _logger.logGeneral('✅ Meeting updated successfully');
      await fetchUpcomingMeetings(); // Refresh list
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

  Future<bool> deleteMeeting(String id) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Deleting meeting with ID: $id');
    final response = await _meetService.deleteMeet(id: id);

    if (response.success) {
      _logger.logGeneral('✅ Meeting deleted successfully');
      _meetList.removeWhere((meet) => meet.id == id);
      await _localStorage.saveMeetList(_meetList);
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
