import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/resignation_service.dart';

class ResignationProvider extends ChangeNotifier {
  final ResignationService _service = ResignationService();

  /// UI state
  bool isSubmitting = false;
  String? errorMessage;

  /// 🚀 Submit resignation
  Future<bool> submitResignation({
    required String resignationDate,
    required String reason,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final response = await _service.submitResignation(
      resignationDate: resignationDate,
      reason: reason,
    );

    isSubmitting = false;

    if (response.success) {
      notifyListeners();
      return true;
    } else {
      errorMessage = response.message ?? 'Failed to submit resignation';
      notifyListeners();
      return false;
    }
  }
}