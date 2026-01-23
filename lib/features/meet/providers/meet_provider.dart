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

      // ✅ Now using the new user-centric endpoint
      final response = await _meetService.getUpcomingMeetings();

      if (response.success) {
        if (response.data is Map<String, dynamic> && response.data['data'] is List) {
          final List<dynamic> meetsJson = response.data['data'] as List<dynamic>;
          _meetList = meetsJson.map((json) => Meet.fromJson(json)).toList();
          await _localStorage.saveMeetList(_meetList);
          _state = MeetState.success;
          _logger.logNetwork('✅ Meets refreshed (${_meetList.length} meets)');
        } else if (response.data is String && response.data == "Api is working") {
          _state = MeetState.success;
        } else {
          _meetList = [];
          await _localStorage.saveMeetList(_meetList);
          _state = MeetState.success;
        }
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
        return (meet.description.toLowerCase().contains(query.toLowerCase())) ||
            (meet.createdBy['name']?.toLowerCase().contains(query.toLowerCase()) ?? false);
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

    final response = await _meetService.addMeet(
      meetLink: meetLink,
      description: description,
      time: time,
      createdBy: {"employeeId": employeeId ?? "", "name": employeeName ?? ""},
      participants: participants,
    );

    if (response.success) {
      _logger.logGeneral('✅ Meeting added successfully');
      
      if (response.data is Map<String, dynamic> && response.data['data'] != null) {
        final newMeet = Meet.fromJson(response.data['data']);
        _meetList.insert(0, newMeet);
        await _localStorage.saveMeetList(_meetList);
      }
      
      await fetchUpcomingMeetings(forceRefresh: true); 
      return true;
    } else {
      _errorMessage = response.message;
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeeting({required String id, required String time}) async {
    _state = MeetState.loading;
    notifyListeners();

    try {
      final response = await _meetService.updateMeet(id: id, time: time);

      if (response.success) {
        final index = _meetList.indexWhere((m) => m.id == id);
        if (index != -1) {
          final updatedMeet = Meet(
            id: _meetList[index].id,
            meetLink: _meetList[index].meetLink,
            createdBy: _meetList[index].createdBy,
            participants: _meetList[index].participants,
            time: time,
            description: _meetList[index].description,
            createdAt: _meetList[index].createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
          _meetList[index] = updatedMeet;
          await _localStorage.saveMeetList(_meetList);
        }
        
        _state = MeetState.success;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _state = MeetState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeeting(String id) async {
    _state = MeetState.loading;
    notifyListeners();

    final response = await _meetService.deleteMeet(id: id);

    if (response.success) {
      _meetList.removeWhere((meet) => meet.id == id);
      await _localStorage.saveMeetList(_meetList);
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }
}
