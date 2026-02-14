import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/resignation_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum ResignationState { initial, loading, loaded, error }

class ResignationProvider extends ChangeNotifier {
  final ResignationService _service = ResignationService();
  final SecureStorageService _storage = SecureStorageService();
  final LocalStorageService _local = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  // State Management
  ResignationState _state = ResignationState.initial;
  ResignationState get state => _state;

  bool isSubmitting = false;
  String? errorMessage;
  String? adminError;

  // Data
  List<dynamic> allResignations = [];
  Map<String, dynamic>? myResignation;

  // Loading flags
  bool isLoadingResignations = false;
  bool isLoadingMyResignation = false;
  bool isManager = false;

  // Cache Keys
  static const String _myResignationKey = 'cached_my_resignation';
  static const String _allResignationsKey = 'cached_all_resignations';

  ResignationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkUserRole();
    await _loadFromLocal();
    fetchMyResignation();
    if (isManager) {
      fetchAllResignations();
    }
  }

  Future<void> _checkUserRole() async {
    final userData = await _storage.getUserData();
    isManager = userData?['role']?.toString().toLowerCase() == 'manager';
    notifyListeners();
  }

  Future<void> _loadFromLocal() async {
    try {
      // Load My Resignation
      final myCached = await _local.getString(_myResignationKey);
      if (myCached != null) {
        myResignation = jsonDecode(myCached);
      }

      // Load All Resignations (Manager)
      final allCached = await _local.getString(_allResignationsKey);
      if (allCached != null) {
        allResignations = jsonDecode(allCached);
      }
      
      if (myResignation != null || (isManager && allResignations.isNotEmpty)) {
        _state = ResignationState.loaded;
      }
      notifyListeners();
    } catch (e) {
      _logger.error('RESIGNATION_PROVIDER', 'Error loading cache', error: e);
    }
  }

  Future<void> fetchMyResignation() async {
    if (myResignation == null) {
      isLoadingMyResignation = true;
      notifyListeners();
    }

    try {
      final response = await _service.getMyResignation();
      if (response.success && response.data != null) {
        final dynamic data = response.data;
        if (data is List && data.isNotEmpty) {
          myResignation = Map<String, dynamic>.from(data.first);
        } else if (data is Map<String, dynamic>) {
          myResignation = Map<String, dynamic>.from(data);
        }
        
        await _local.saveString(_myResignationKey, jsonEncode(myResignation));
      } else {
        myResignation = null;
        await _local.removeString(_myResignationKey);
      }
    } catch (e) {
      _logger.error('RESIGNATION_PROVIDER', 'FetchMyResignation error', error: e);
    } finally {
      isLoadingMyResignation = false;
      _state = ResignationState.loaded;
      notifyListeners();
    }
  }

  Future<void> fetchAllResignations() async {
    if (allResignations.isEmpty) {
      isLoadingResignations = true;
      notifyListeners();
    }

    try {
      final response = await _service.getAllResignations();
      if (response.success) {
        allResignations = response.data ?? [];
        await _local.saveString(_allResignationsKey, jsonEncode(allResignations));
      } else {
        adminError = response.message;
      }
    } catch (e) {
      _logger.error('RESIGNATION_PROVIDER', 'FetchAllResignations error', error: e);
    } finally {
      isLoadingResignations = false;
      notifyListeners();
    }
  }

  Future<bool> submitResignation({
    required String resignationDate,
    required String reason,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.submitResignation(
        resignationDate: resignationDate,
        reason: reason,
      );

      if (response.success) {
        await fetchMyResignation();
        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = 'Submission failed';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateResignationStatus({
    required String resignationId,
    required String status,
    String? comments,
  }) async {
    try {
      final response = await _service.updateResignationStatus(
        resignationId: resignationId,
        status: status,
        comments: comments,
      );

      if (response.success) {
        await fetchAllResignations();
        return true;
      } else {
        adminError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
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
}
