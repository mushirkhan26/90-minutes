import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/registration_service.dart';
import 'package:hrtz_hrms/core/models/registration_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum RegistrationState { initial, loading, loaded, error }

class RegistrationProvider with ChangeNotifier {
  final RegistrationService _service = RegistrationService();
  final LocalStorageService _local = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;
  
  List<RegistrationModel> _registrations = [];
  List<RegistrationModel> _filteredRegistrations = [];
  RegistrationState _state = RegistrationState.initial;
  String? _errorMessage;

  static const String _storageKey = 'cached_registrations';

  RegistrationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    fetchRegistrations();
  }

  List<RegistrationModel> get registrations => _filteredRegistrations;
  RegistrationState get state => _state;
  String? get errorMessage => _errorMessage;

  int get totalPeople => _registrations.length;
  int get totalDepartments => _registrations.map((e) => e.department).toSet().length;

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedPosition = 'All';
  String _selectedStatus = 'All';

  String get selectedDepartment => _selectedDepartment;
  String get selectedPosition => _selectedPosition;
  String get selectedStatus => _selectedStatus;

  List<String> get uniqueDepartments => ['All', ..._registrations.map((e) => e.department).where((d) => d.isNotEmpty).toSet()];
  List<String> get uniquePositions => ['All', ..._registrations.map((e) => e.position).where((p) => p.isNotEmpty).toSet()];
  List<String> get uniqueStatuses => ['All', ..._registrations.map((e) => e.status).where((s) => s.isNotEmpty).toSet()];

  Future<void> _loadFromLocal() async {
    try {
      final cachedData = await _local.getString(_storageKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _registrations = decoded.map((json) => RegistrationModel.fromJson(json)).toList();
        _applyFilters();
        _state = RegistrationState.loaded;
        notifyListeners();
        _logger.logNetwork('Loaded registrations from cache');
      }
    } catch (e) {
      _logger.error('REG_PROVIDER', 'Error loading from local', error: e);
    }
  }

  Future<void> fetchRegistrations() async {
    if (_registrations.isEmpty) {
      _state = RegistrationState.loading;
      notifyListeners();
    }

    final response = await _service.getRegistrations();

    if (response.success && response.data != null) {
      _registrations = response.data!;
      _applyFilters();
      _state = RegistrationState.loaded;
      
      final encoded = jsonEncode(_registrations.map((e) => e.toJson()).toList());
      await _local.saveString(_storageKey, encoded);
    } else {
      if (_registrations.isEmpty) {
        _state = RegistrationState.error;
        _errorMessage = response.message;
      }
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void updateDepartmentFilter(String dept) {
    _selectedDepartment = dept;
    _applyFilters();
    notifyListeners();
  }

  void updatePositionFilter(String pos) {
    _selectedPosition = pos;
    _applyFilters();
    notifyListeners();
  }

  void updateStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRegistrations = _registrations.where((reg) {
      final matchesSearch = reg.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          reg.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDepartment == 'All' || reg.department == _selectedDepartment;
      final matchesPos = _selectedPosition == 'All' || reg.position == _selectedPosition;
      final matchesStatus = _selectedStatus == 'All' || reg.status == _selectedStatus;

      return matchesSearch && matchesDept && matchesPos && matchesStatus;
    }).toList();
  }

  Future<bool> updateUserDetails(String email, Map<String, dynamic> data) async {
    final response = await _service.updateUser(email: email, data: data);
    if (response.success) {
      await fetchRegistrations(); 
      return true;
    }
    return false;
  }

  Future<bool> approveUser(String email, String teamLeadName, String packageId) async {
    final response = await _service.approveUser(email: email, teamLeadName: teamLeadName, packageId: packageId);
    if (response.success) {
      await fetchRegistrations();
      return true;
    }
    return false;
  }

  Future<bool> rejectUser(String email) async {
    final response = await _service.rejectUser(email: email);
    if (response.success) {
      await fetchRegistrations();
      return true;
    }
    return false;
  }

  Future<bool> updateStatus(String id, String status) async {
    final response = await _service.updateRegistrationStatus(id: id, status: status);
    if (response.success) {
      await fetchRegistrations();
      return true;
    }
    return false;
  }
}
