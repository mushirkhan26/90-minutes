import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/payroll_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/models/payroll_model.dart';
import 'package:intl/intl.dart';

enum PayrollState { idle, loading, success, error, empty }

class PayrollProvider extends ChangeNotifier {
  final PayrollService _payrollService = PayrollService();
  final LocalStorageService _storage = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LoggingService _logger = LoggingService.instance;

  PayrollState _state = PayrollState.idle;
  PayrollState get state => _state;

  PayrollModel? _payrollData;
  PayrollModel? get payrollData => _payrollData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedYear = '2025';
  String _selectedMonth = 'January';

  String get selectedYear => _selectedYear;
  String get selectedMonth => _selectedMonth;

  PayrollProvider() {
    _init();
  }

  void _init() {
    final now = DateTime.now();
    _selectedYear = now.year.toString();
    _selectedMonth = DateFormat('MMMM').format(now);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId != null) {
      await fetchPayroll(
        employeeId: employeeId,
        year: _selectedYear,
        month: _selectedMonth,
      );
    }
  }

  void updateSelection(String year, String month) {
    if (_selectedYear == year && _selectedMonth == month) return;
    _selectedYear = year;
    _selectedMonth = month;
    notifyListeners();
    // Fetch data for new selection
    _loadInitialData();
  }

  Future<void> fetchPayroll({
    required String employeeId,
    required String year,
    required String month,
    bool forceRefresh = false,
  }) async {
    _selectedYear = year;
    _selectedMonth = month;
    
    // 1. Try to load from cache first
    if (!forceRefresh) {
      final cachedData = await _storage.getPayroll(employeeId, year, month);
      if (cachedData != null) {
        _payrollData = cachedData;
        _state = PayrollState.success;
        notifyListeners();
        _logger.logNetwork('Payroll data loaded from cache for $employeeId');
      }
    }

    // 2. Fetch from API if needed
    if (_payrollData == null || forceRefresh) {
      if (_payrollData == null) {
        _state = PayrollState.loading;
        _errorMessage = null;
        notifyListeners();
      }

      try {
        final response = await _payrollService.getPayrollHistory(
          employeeId: employeeId,
          year: year,
          month: month,
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          if (data.containsKey('packageDetails') && data['packageDetails'] != null) {
            _payrollData = PayrollModel.fromJson(data, employeeId: employeeId);
            _state = PayrollState.success;
            
            // Save to local storage
            await _storage.savePayroll(_payrollData!);
            
            _logger.logNetwork('Payroll data fetched from API and saved to cache for $employeeId');
          } else {
            _payrollData = null;
            _state = PayrollState.empty;
            _logger.logNetwork('No payroll data found for $employeeId');
          }
        } else {
          if (_payrollData == null) {
            _state = PayrollState.error;
            _errorMessage = response.message ?? 'Failed to fetch payroll data';
          }
          _logger.error('PAYROLL_PROVIDER', response.message ?? 'Failed to fetch payroll data');
        }
      } catch (e, s) {
        if (_payrollData == null) {
          _state = PayrollState.error;
          _errorMessage = 'An unexpected error occurred';
        }
        _logger.error('PAYROLL_PROVIDER', 'Error fetching payroll', error: e, stackTrace: s);
      } finally {
        notifyListeners();
      }
    }
  }
  
  void reset() {
    _state = PayrollState.idle;
    _payrollData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
