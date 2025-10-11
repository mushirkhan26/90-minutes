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
  final LoggerService _logger = LoggerService();

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

    final response = await _authService.login(employeeId: employeeId, password: password);

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
      _logger.logResponse(response.statusCode ?? 200, "✅ User logged in");
    } else {
      _state = AuthState.error;
      _errorMessage = response.message;
      _logger.logError("❌ Login failed: ${response.message}");
    }

    notifyListeners();
  }

  /// 🚪 Logout Flow
  Future<void> logout() async {
    await _secureStorage.clearUserData();
    await _localStorage.setLoginState(false);
    _userData = null;
    _state = AuthState.unauthenticated;
    _logger.logWarning("User logged out");
    notifyListeners();
  }

  /// 👤 Check existing session
  Future<void> checkAuthState() async {
    final loggedIn = await _localStorage.isLoggedIn();
    if (loggedIn) {
      _userData = await _secureStorage.getUserData();
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
