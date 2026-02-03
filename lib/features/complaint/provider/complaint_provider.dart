import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/complaint_service.dart';
import 'package:hrtz_hrms/core/models/complaint_model.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  final LocalStorageService _localStorage = LocalStorageService();

 
  String loggedInName = "";
  String loggedInEmployeeId = "";

  
  final List<String> categories = ["IT", "HR", "Facilities"];
  final List<String> mentionPeople = ["Team Lead", "Manager", "CEO"];

  
  List<ComplaintModel> complaints = [];
  bool isLoading = false;

 
  Future<void> loadLoginUser() async {
    loggedInName = await _localStorage.getEmployeeName() ?? "";
    loggedInEmployeeId = await _localStorage.getEmployeeId() ?? "";

    debugPrint("✅ Loaded login user");
    debugPrint("NAME => $loggedInName");
    debugPrint("EMPLOYEE ID => $loggedInEmployeeId");

    notifyListeners();
  }

 
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

      complaints = list
          .map((e) => ComplaintModel.fromJson(e))
          .toList();

      debugPrint("✅ Complaints loaded: ${complaints.length}");
    } else {
      complaints = [];
    }
  } catch (e) {
    complaints = [];
    debugPrint("❌ Fetch complaints error: $e");
  }

  isLoading = false;
  notifyListeners();
}

  
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
      // Ensure login data
      if (loggedInEmployeeId.isEmpty || loggedInName.isEmpty) {
        await loadLoginUser();
      }

      if (loggedInEmployeeId.isEmpty || loggedInName.isEmpty) {
        debugPrint("❌ Login user data missing. Cannot add complaint.");
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
        await fetchComplaints(); // refresh list
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("❌ Add complaint error: $e");
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

 
  void clearComplaints() {
    complaints = [];
    loggedInName = "";
    loggedInEmployeeId = "";
    notifyListeners();
  }
}