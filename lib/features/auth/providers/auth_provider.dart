import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/auth_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

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
}
