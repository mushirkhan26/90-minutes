// import 'package:flutter/foundation.dart';
// import '../../../core/models/meet_model.dart';
// import '../../../repositories/meet_repository.dart';

// class MeetProvider with ChangeNotifier {
//   final MeetRepository _repository = MeetRepository();
//   List<Meet> _meets = [];
//   bool _isLoading = false;

//   List<Meet> get meets => _meets;
//   bool get isLoading => _isLoading;

//   Future<void> loadMeets() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _meets = await _repository.fetchAllMeets();
//     } catch (e) {
//       debugPrint('Error fetching meets: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> addMeet(Meet meet) async {
//     try {
//       final newMeet = await _repository.createMeet(meet);
//       _meets.add(newMeet);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error adding meet: $e');
//     }
//   }

//   Future<void> updateMeet(String id, DateTime startTime) async {
//     try {
//       await _repository.updateMeet(id, startTime);
//       final index = _meets.indexWhere((m) => m.id == id);
//       if (index != -1) {
//         _meets[index] = Meet(
//           id: _meets[index].id,
//           title: _meets[index].title,
//           location: _meets[index].location,
//           link: _meets[index].link,
//           startTime: startTime,
//         );
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error updating meet: $e');
//     }
//   }

//   Future<void> deleteMeet(String id) async {
//     try {
//       await _repository.deleteMeet(id);
//       _meets.removeWhere((m) => m.id == id);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error deleting meet: $e');
//     }
//   }
// }

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
      _logger.logGeneral(
        '❌ Failed to add meeting: ${response.message}',
        level: LogLevel.error,
      );
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
      _logger.logGeneral(
        '❌ Error fetching meetings: $_errorMessage',
        level: LogLevel.error,
      );
      _state = MeetState.error;
    }

    notifyListeners();
  }

  // Update meeting start time
  Future<bool> updateMeeting({
    required String id,
    required String startTime,
  }) async {
    _state = MeetState.loading;
    notifyListeners();

    _logger.logGeneral('Updating meeting with ID: $id');

    final response = await _meetService.updateMeet(
      id: id,
      startTime: startTime,
    );

    if (response.success) {
      _logger.logGeneral('✅ Meeting updated successfully');
      await fetchAllMeetings();
      _state = MeetState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _logger.logGeneral(
        '❌ Failed to update meeting: ${response.message}',
        level: LogLevel.error,
      );
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
      _logger.logGeneral(
        '❌ Failed to delete meeting: ${response.message}',
        level: LogLevel.error,
      );
      _state = MeetState.error;
      notifyListeners();
      return false;
    }
  }
}
