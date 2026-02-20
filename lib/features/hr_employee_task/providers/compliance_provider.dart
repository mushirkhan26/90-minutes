import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/compliance_service.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import '../../../core/models/compliance_model.dart';

class ComplianceProvider with ChangeNotifier {
  final ComplianceService _complianceService = ComplianceService();
  List<Compliance> _compliances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Compliance> get compliances => _compliances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _compliances.length;
  
  // Mapping API statuses: 'Assigned', 'Submitted', 'Pending', 'Completed'
  int get actionRequiredCount => _compliances.where((c) {
    final s = c.status.toLowerCase();
    return s == 'assigned' || s == 'pending' || s == 'action required';
  }).length;

  int get completedCount => _compliances.where((c) {
    final s = c.status.toLowerCase();
    return s == 'submitted' || s == 'completed';
  }).length;

  int get overdueCount => _compliances.where((c) {
    final s = c.status.toLowerCase();
    final isDone = s == 'submitted' || s == 'completed';
    return !isDone && c.dueDate.isBefore(DateTime.now());
  }).length;

  Future<void> fetchCompliances(String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _complianceService.getEmployeeCompliance(employeeId);
      if (response.success && response.data != null) {
        _compliances = response.data!;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<void>> submitCompliance(String complianceId, List<String> submittedDocuments) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _complianceService.submitCompliance(complianceId, submittedDocuments);
      return response;
    } catch (e) {
      return ApiResponse.error(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
