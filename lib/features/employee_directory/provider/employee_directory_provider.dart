import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/employee_service.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum EmployeeDirectoryState { initial, loading, loaded, error }

class EmployeeDirectoryProvider with ChangeNotifier {
  final EmployeeService _employeeService = EmployeeService();
  final LocalStorageService _localStorage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  EmployeeDirectoryState _state = EmployeeDirectoryState.initial;
  EmployeeDirectoryState get state => _state;

  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filteredEmployees = [];
  List<EmployeeModel> get employees => _filteredEmployees;
  
  Set<String> _availableRoles = {'All Roles'};
  List<String> get availableRoles => _availableRoles.toList()..sort();

  List<String> _tagOptions = [];
  List<String> get tagOptions => _tagOptions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String _selectedRole = 'All Roles';
  String get selectedRole => _selectedRole;

  final Set<String> _selectedEmployeeIds = {};
  Set<String> get selectedEmployeeIds => _selectedEmployeeIds;

  EmployeeDirectoryProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await fetchAllEmployees(showLoader: _allEmployees.isEmpty);
  }

  Future<void> _loadFromLocal() async {
    try {
      final cachedEmployees = await _localStorage.getEmployeeList();
      if (cachedEmployees != null && cachedEmployees.isNotEmpty) {
        _allEmployees = cachedEmployees;
        _updateMetadataAndFilters();
        _state = EmployeeDirectoryState.loaded;
        notifyListeners();
        _logger.logStorage('Employee directory loaded from cache');
      }
    } catch (e) {
      _logger.error('DIRECTORY', 'Error loading from local storage', error: e);
    }
  }

  void _updateMetadataAndFilters() {
    _availableRoles = {'All Roles'};
    for (var emp in _allEmployees) {
      if (emp.role != null && emp.role!.isNotEmpty) {
        _availableRoles.add(emp.role!);
      }
    }

    final derivedLeads = _allEmployees
        .where((e) {
          final role = e.role?.toLowerCase() ?? '';
          return role.contains('manager') || 
                 role.contains('admin') || 
                 role.contains('ceo') ||
                 role.contains('lead');
        })
        .map((e) => e.name)
        .toSet()
        .toList();
    
    if (derivedLeads.isNotEmpty) {
      _tagOptions = derivedLeads..sort();
    } else if (_tagOptions.isEmpty) {
      _tagOptions = ["Not Available"];
    }

    _applyFilters();
  }

  void toggleSelection(String employeeId) {
    if (_selectedEmployeeIds.contains(employeeId)) {
      _selectedEmployeeIds.remove(employeeId);
    } else {
      _selectedEmployeeIds.add(employeeId);
    }
    notifyListeners();
  }

  void toggleSelectAll(bool selectAll) {
    if (selectAll) {
      _selectedEmployeeIds.addAll(_filteredEmployees.map((e) => e.employeeID));
    } else {
      _selectedEmployeeIds.clear();
    }
    notifyListeners();
  }

  bool isAllSelected() {
    if (_filteredEmployees.isEmpty) return false;
    return _selectedEmployeeIds.length == _filteredEmployees.length;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    _applyFilters();
  }

  void _applyFilters() {
    _selectedEmployeeIds.clear();
    _filteredEmployees = _allEmployees.where((emp) {
      final matchesSearch = emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.employeeID.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (emp.mobile ?? '').contains(_searchQuery);
      
      final matchesRole = _selectedRole == 'All Roles' || emp.role == _selectedRole;
      
      return matchesSearch && matchesRole;
    }).toList();
    notifyListeners();
  }

  Future<void> fetchAllEmployees({bool showLoader = true}) async {
    if (showLoader) {
      _state = EmployeeDirectoryState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _employeeService.getEmployeeList();
      if (response.success) {
        _allEmployees = response.data ?? [];
        await _localStorage.saveEmployeeList(_allEmployees);
        _updateMetadataAndFilters();
        _state = EmployeeDirectoryState.loaded;
      } else {
        if (_allEmployees.isEmpty) {
          _errorMessage = response.message ?? 'Failed to load employees';
          _state = EmployeeDirectoryState.error;
        }
      }
    } catch (e, stack) {
      _logger.error('DIRECTORY', 'Exception in fetchAllEmployees: $e', error: e, stackTrace: stack);
      if (_allEmployees.isEmpty) {
        _errorMessage = e.toString();
        _state = EmployeeDirectoryState.error;
      }
    }
    notifyListeners();
  }

  Future<bool> tagEmployee(String employeeName, String teamLeadName) async {
    final response = await _employeeService.tagEmployee(
      employeeName: employeeName,
      teamLeadName: teamLeadName,
    );
    if (response.success) {
      await fetchAllEmployees(showLoader: false);
      return true;
    }
    return false;
  }

  Future<bool> tagSelectedEmployees(String teamLeadName) async {
    bool overallSuccess = true;
    for (var id in _selectedEmployeeIds) {
      final emp = _allEmployees.firstWhere((e) => e.employeeID == id);
      final response = await _employeeService.tagEmployee(
        employeeName: emp.name,
        teamLeadName: teamLeadName,
      );
      if (!response.success) overallSuccess = false;
    }
    
    if (overallSuccess) {
      _selectedEmployeeIds.clear();
      await fetchAllEmployees(showLoader: false);
    }
    return overallSuccess;
  }

  Future<bool> updateEmployeeRole(String employeeId, String newRole, String changedBy) async {
    final response = await _employeeService.changeRole(
      employeeId: employeeId,
      newRole: newRole,
      changedBy: changedBy,
    );
    if (response.success) {
      await fetchAllEmployees(showLoader: false);
      return true;
    }
    return false;
  }
}
