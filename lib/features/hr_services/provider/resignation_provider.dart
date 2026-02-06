import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/resignation_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class ResignationProvider extends ChangeNotifier {
  final ResignationService _service = ResignationService();
  final SecureStorageService _storage = SecureStorageService();

  bool isSubmitting = false;

  String? errorMessage;

  bool isLoadingResignations = false;
  List<dynamic> allResignations = [];
  String? adminError;

  Map<String, dynamic>? myResignation;
  bool isLoadingMyResignation = false;

  Future<bool> submitResignation({
    required String resignationDate,
    required String reason,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      errorMessage = 'Token missing';
      isSubmitting = false;
      notifyListeners();
      return false;
    }

    final response = await _service.submitResignation(
      resignationDate: resignationDate,
      reason: reason,
    );

    isSubmitting = false;

    if (response.success) {
      await fetchMyResignation(); //  fetch my resignation
      return true;
    } else {
      errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAllResignations() async {
    isLoadingResignations = true;
    adminError = null;
    notifyListeners();

    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      adminError = 'Token missing';
      isLoadingResignations = false;
      notifyListeners();
      return;
    }

    final response = await _service.getAllResignations();

    if (response.success) {
      allResignations = response.data ?? [];
    } else {
      adminError = response.message;
    }

    isLoadingResignations = false;
    notifyListeners();
  }

  Future<bool> updateResignationStatus({
    required String resignationId,
    required String status,
    String? comments,
  }) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      adminError = 'Token missing';
      notifyListeners();
      return false;
    }

    final response = await _service.updateResignationStatus(
      resignationId: resignationId,
      status: status,
      comments: comments,
    );

    if (response.success) {
      await fetchAllResignations(); // ✅ refresh list
      return true;
    } else {
      adminError = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadDocument({
    required String resignationId,
    required String documentUrl,
  }) async {
    final response = await _service.uploadDocument(
      resignationId: resignationId,
      documentUrl: documentUrl,
    );

    return response.success;
  }

  Future<void> fetchMyResignation() async {
    isLoadingMyResignation = true;
    notifyListeners();

    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      myResignation = null;
      isLoadingMyResignation = false;
      notifyListeners();
      return;
    }

    final response = await _service.getMyResignation();

    if (response.success && response.data != null) {
      final dynamic data = response.data;

      if (data is List && data.isNotEmpty == true) {
        myResignation = Map<String, dynamic>.from(data.first);
      } else if (data is Map<String, dynamic>) {
        myResignation = Map<String, dynamic>.from(data);
      } else {
        myResignation = null;
      }
    } else {
      myResignation = null; // No resignation exists
    }

    isLoadingMyResignation = false;
    notifyListeners();
  }
}
