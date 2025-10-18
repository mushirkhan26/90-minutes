import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/auth_service.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/socket/socket_manager.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalStorageService _localStorage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  List<EmployeeModel>? _employeeList;
  bool _isFetchingEmployees = false;

  List<EmployeeModel>? get employeeList => _employeeList;
  bool get isFetchingEmployees => _isFetchingEmployees;

  /// 🔑 Login Flow
  Future<void> login(String employeeId, String password) async {
    _state = AuthState.loading;
    notifyListeners();

    _logger.logAuth('Attempting login for employeeId: $employeeId');

    final response = await _authService.login(
      employeeId: employeeId,
      password: password,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      _userData = data;

      // Save secure data
      await _secureStorage.saveUserData(
        token: data['token'],
        employeeId: data['employeeId'],
        username: data['username'],
        email: data['email'],
        role: data['role'],
      );

      // Save login state
      await _localStorage.setLoginState(true);

      _state = AuthState.authenticated;
      _logger.logAuth('✅ User logged in successfully');
    } else {
      _state = AuthState.error;
      _errorMessage = response.message;
      _logger.logAuth(
        '❌ Login failed: ${response.message}',
        level: LogLevel.error,
      );
    }

    notifyListeners();
  }

  /// 🚪 Logout Flow
  Future<void> logout() async {
    await SocketManager.instance.leave(); // disconnect socket first

    await _secureStorage.clearUserData();
    await _localStorage.setLoginState(false);
    _userData = null;
    _state = AuthState.unauthenticated;

    _logger.logAuth('User logged out', level: LogLevel.warning);
    notifyListeners();
  }

  /// 👤 Check existing session
  Future<void> checkAuthState() async {
    final loggedIn = await _localStorage.isLoggedIn();
    if (loggedIn) {
      _userData = await _secureStorage.getUserData();
      _state = AuthState.authenticated;
      _logger.logAuth('User session found, authenticated');
    } else {
      _state = AuthState.unauthenticated;
      _logger.logAuth('No  user session found, unauthenticated');
    }
    notifyListeners();
  }

  // 📲 Get OTP
  Future<(bool success, String message)> getOtp(String employeeId) async {
    _logger.logAuth('Requesting OTP for employeeId: $employeeId');
    final response = await _authService.getOtp(employeeId: employeeId);

    if (response.success && response.data?['message'] == 'OTP sent') {
      _logger.logAuth('✅ OTP sent successfully');
      return (true, 'OTP sent successfully');
    } else if (response.statusCode == 400 &&
        response.message == 'User Not Found') {
      _logger.logAuth(
        '❌ User not found for employeeId: $employeeId',
        level: LogLevel.error,
      );
      return (false, 'User not found. Please check your Employee ID.');
    } else {
      _logger.logAuth(
        '❌ Failed to get OTP: ${response.message}',
        level: LogLevel.error,
      );
      return (false, response.message ?? 'Something went wrong');
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String employeeId, int otp) async {
    _logger.logAuth('Verifying OTP for employeeId: $employeeId');
    final response = await _authService.verifyOtp(
      employeeId: employeeId,
      otp: otp,
    );

    if (response.success) {
      _logger.logAuth('OTP verified successfully');
      return true; // UI can navigate to change password page
    } else {
      _logger.logAuth(
        'OTP verification failed: ${response.message}',
        level: LogLevel.error,
      );
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String employeeId, String newPassword) async {
    _logger.logAuth('Changing password for employeeId: $employeeId');
    final response = await _authService.changePassword(
      employeeId: employeeId,
      password: newPassword,
    );

    if (response.success) {
      _logger.logAuth('Password changed successfully');
      return true; // UI can navigate to login page
    } else {
      _logger.logAuth(
        'Password change failed: ${response.message}',
        level: LogLevel.error,
      );
      return false;
    }
  }

  // Resend OTP
  Future<(bool success, String message)> resendOtp(String employeeId) async {
    _logger.logAuth('🔁 Resending OTP for employeeId: $employeeId');
    final (success, message) = await getOtp(employeeId);

    if (success) {
      _logger.logAuth('✅ OTP resent successfully');
    } else {
      _logger.logAuth(
        '❌ Failed to resend OTP: $message',
        level: LogLevel.error,
      );
    }

    return (success, message);
  }

  /// Fetch employee list from API and cache it
  Future<void> fetchAndCacheEmployeeList() async {
    try {
      _isFetchingEmployees = true;
      notifyListeners();

      // Try to get cached list first
      final cachedList = await _localStorage.getEmployeeList();
      final cachedTimestamp = await _localStorage.getEmployeeListTimestamp();

      // If we have cached data less than 1 hour old, use it
      if (cachedList != null && cachedTimestamp != null) {
        final duration = DateTime.now().difference(cachedTimestamp);
        if (duration.inHours < 1) {
          _employeeList = cachedList;
          _logger.logAuth('✅ Using cached employee list (${cachedList.length} employees)');
          _isFetchingEmployees = false;
          notifyListeners();
          return;
        }
      }

      // Fetch fresh data from API
      _logger.logAuth('🔄 Fetching fresh employee list from API');
      final response = await _authService.getEmployeeList();

      if (response.success && response.data != null) {
        _employeeList = response.data!;
        // Cache the fresh data
        await _localStorage.saveEmployeeList(_employeeList!);
        _logger.logAuth('✅ Fetched and cached employee list (${_employeeList!.length} employees)');
      } else {
        _logger.logAuth(
          '❌ Failed to fetch employee list: ${response.message}',
          level: LogLevel.error,
        );
        // If API fails but we have cached data, use the cached data
        if (cachedList != null) {
          _employeeList = cachedList;
          _logger.logAuth(
            'ℹ️ Using cached employee list as fallback (${cachedList.length} employees)',
          );
        }
      }
    } catch (e, s) {
      _logger.error('AUTH_PROVIDER', 'Error fetching employee list', error: e, stackTrace: s);
      // Try to use cached data if available
      final cachedList = await _localStorage.getEmployeeList();
      if (cachedList != null) {
        _employeeList = cachedList;
        _logger.logAuth(
          'ℹ️ Using cached employee list as fallback (${cachedList.length} employees)',
        );
      }
    } finally {
      _isFetchingEmployees = false;
      notifyListeners();
    }
  }

  /// Force refresh employee list from API
  Future<void> refreshEmployeeList() async {
    await fetchAndCacheEmployeeList();
  }

  /// Get employee by ID
  EmployeeModel? getEmployeeById(String employeeId) {
    return _employeeList?.firstWhere(
      (employee) => employee.employeeID == employeeId,
      orElse: () => throw Exception('Employee not found'),
    );
  }

  /// Get employee by name (search)
  List<EmployeeModel> searchEmployees(String query) {
    if (_employeeList == null) return [];

    return _employeeList!.where((employee) {
      return employee.name.toLowerCase().contains(query.toLowerCase()) ||
          employee.employeeID.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
