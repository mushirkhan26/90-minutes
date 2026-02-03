import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/complaint_service.dart';
import 'package:hrtz_hrms/core/models/complaint_model.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  final LocalStorageService _localStorage = LocalStorageService();

  // ================== LOGIN USER ==================
  String loggedInName = "";
  String loggedInEmployeeId = "";

  // ================== MASTER DATA ==================
  final List<String> categories = ["IT", "HR", "Facilities"];
  final List<String> mentionPeople = ["Team Lead", "Manager", "CEO"];

  // ================== MY COMPLAINTS ==================
  List<ComplaintModel> complaints = [];
  bool isLoading = false;

  // ================== TEAM COMPLAINTS (MANAGER) ==================
  List<ComplaintModel> teamComplaints = [];
  bool isTeamLoading = false;
  bool isUpdatingStatus = false;

  // ================== LOAD LOGIN USER ==================
  Future<void> loadLoginUser() async {
    loggedInName = await _localStorage.getEmployeeName() ?? "";
    loggedInEmployeeId = await _localStorage.getEmployeeId() ?? "";
  }

  // ================== FETCH MY COMPLAINTS ==================
  Future<void> fetchComplaints() async {
    isLoading = true;
    notifyListeners();

    try {
      if (loggedInEmployeeId.isEmpty) {
        await loadLoginUser();
      }

      if (loggedInEmployeeId.isEmpty) {
        complaints = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final ApiResponse response =
          await _complaintService.getComplaints(loggedInEmployeeId);

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final List list = body['message'] ?? [];

        complaints =
            list.map((e) => ComplaintModel.fromJson(e)).toList();
            complaints.sort((a, b){
              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate); 
            });
      } else {
        complaints = [];
      }
    } catch (e) {
      complaints = [];
      debugPrint("❌ fetchComplaints error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ================== ADD COMPLAINT ==================
  Future<bool> addComplaint({
    required String category,
    required String title,
    required String description,
    required String additionalInfo,
    required List<String> attachment,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (loggedInEmployeeId.isEmpty || loggedInName.isEmpty) {
        await loadLoginUser();
      }

      if (loggedInEmployeeId.isEmpty || loggedInName.isEmpty) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      final ApiResponse response =
          await _complaintService.addComplaint(
        name: loggedInName,
        employeeId: loggedInEmployeeId,
        category: category,
        title: title,
        description: description,
        additionalInfo: additionalInfo,
        attachment: attachment,
      );

      if (response.success) {
        await fetchComplaints();
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("❌ addComplaint error: $e");
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // ================== FETCH TEAM COMPLAINTS (MANAGER) ==================
  Future<void> fetchAllComplaints() async {
    isTeamLoading = true;
    notifyListeners();

    try {
      final ApiResponse response =
          await _complaintService.getAllComplaints();

      if (response.success && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        final List list = body['message'] ?? [];

        teamComplaints =
            list.map((e) => ComplaintModel.fromJson(e))
            .where((c) => c.employeeId != loggedInEmployeeId).toList();
            teamComplaints.sort((a, b){
              final aDate = a.createdAt ?? DateTime(2000);
              final bDate = b.createdAt ?? DateTime(2000);
              return bDate.compareTo(aDate); 
            });
      } else {
        teamComplaints = [];
      }
    } catch (e) {
      teamComplaints = [];
      debugPrint("❌ fetchAllComplaints error: $e");
    }

    isTeamLoading = false;
    notifyListeners();
  }

  // ================== UPDATE COMPLAINT STATUS (MANAGER) ==================
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    isUpdatingStatus = true;
    notifyListeners();

    try {
      final ApiResponse response =
          await _complaintService.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
      );

      if (response.success) {
        final index =
            teamComplaints.indexWhere((c) => c.id == complaintId);

        if (index != -1) {
          teamComplaints[index] =
              teamComplaints[index].copyWith(status: status);
        }
        final myIndex =
            complaints.indexWhere((c) => c.id == complaintId);

        if (myIndex != -1) {
          complaints[myIndex] = complaints[myIndex].copyWith(status: status);
        }

        isUpdatingStatus = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("❌ updateComplaintStatus error: $e");
    }

    isUpdatingStatus = false;
    notifyListeners();
    return false;
  }

  // ================== CLEAR ==================
  void clearComplaints() {
    complaints = [];
    teamComplaints = [];
    loggedInName = "";
    loggedInEmployeeId = "";
    notifyListeners();
  }
}