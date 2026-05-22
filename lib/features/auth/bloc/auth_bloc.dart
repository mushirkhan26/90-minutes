import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/network/auth_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/socket/socket_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final AuthService _authService;

  AuthBloc({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required AuthService authService,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage,
        _authService = authService,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ─────────────────────────────────────────
  // APP STARTED — Token validity check
  // ─────────────────────────────────────────
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading(action: 'appStart'));
      final loggedIn = await _localStorage.isLoggedIn();
      if (!loggedIn) {
        emit(AuthUnauthenticated());
        return;
      }

      final userData = await _secureStorage.getUserData();
      if (userData == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // ✅ Token expiry check
      final token = userData['token'] as String?;
      if (token == null || token.isEmpty) {
        debugPrint("AuthBloc: Token missing, clearing session");
        await _clearSession();
        emit(AuthUnauthenticated());
        return;
      }

      if (_isTokenExpired(token)) {
        debugPrint("AuthBloc: Token expired, attempting refresh");
        final refreshed = await _refreshToken();
        if (!refreshed) {
          debugPrint("AuthBloc: Token refresh failed, clearing session");
          await _clearSession();
          emit(AuthUnauthenticated());
          return;
        }
        
        // Reload userData after refresh
        final newUserData = await _secureStorage.getUserData();
        if (newUserData == null) {
          emit(AuthUnauthenticated());
          return;
        }

        emit(AuthAuthenticated(UserModel(
          id: newUserData['userId']?.toString() ?? '',
          name: newUserData['name'] ?? 'User',
          userId: newUserData['userId']?.toString() ?? '',
          email: newUserData['email'],
          mobile: newUserData['phone'],
          role: newUserData['role'] ?? 'customer',
        )));
        return;
      }

      emit(AuthAuthenticated(UserModel(
        id: userData['userId']?.toString() ?? '',
        name: userData['name'] ?? 'User',
        userId: userData['userId']?.toString() ?? '',
        email: userData['email'],
        mobile: userData['phone'], // SecureStorage uses 'phone'
        role: userData['role'] ?? 'customer',
      )));
    } catch (e) {
      debugPrint("AuthBloc: AppStarted error: $e");
      emit(AuthUnauthenticated());
    }
  }

  // ─────────────────────────────────────────
  // LOGIN — Send OTP
  // ─────────────────────────────────────────
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(action: 'login'));

    final response = await _authService.getOtp(userId: event.mobile);

    if (response.success) {
      emit(AuthOtpSent(event.mobile));
    } else {
      emit(AuthError(response.message ?? 'Failed to send OTP'));
    }
  }

  // ─────────────────────────────────────────
  // OTP VERIFY — Smart new/existing user routing
  // ─────────────────────────────────────────
  Future<void> _onOtpVerificationRequested(
      OtpVerificationRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(action: 'verify'));

    // ✅ OTP format validation using Constant
    final otpInt = int.tryParse(event.otp);
    if (otpInt == null || event.otp.length != AppConstants.otpLength) {
      emit(const AuthError('Invalid OTP format'));
      return;
    }

    final response =
        await _authService.verifyOtp(userId: event.mobile, otp: otpInt);

    if (!response.success || response.data == null) {
      emit(AuthError(response.message ?? 'Verification failed'));
      return;
    }

    final data = response.data!;

    // ✅ Consistent field naming for customer app
    final userData = {
      'token': data['token'] ?? '',
      'userId': data['userId']?.toString() ?? data['employeeId']?.toString() ?? event.mobile,
      'name': data['name'] ?? data['username'] ?? 'User',
      'email': data['email'] ?? '',
      'phone': event.mobile,
      'role': data['role'] ?? 'customer',
    };

    await _saveAuthData(userData);

    emit(AuthAuthenticated(UserModel(
      id: userData['userId']!,
      name: userData['name']!,
      userId: userData['userId']!,
      email: userData['email'],
      mobile: userData['phone'],
      role: userData['role']!,
    )));
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await SocketManager.instance.leave();
    await _clearSession();
    emit(AuthUnauthenticated());
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  Future<bool> _refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      if (response.success && response.data != null) {
        final data = response.data!;
        // Note: Ensure _saveAuthData logic handles what's returned here
        // Usually refresh gives a new token and maybe updated user info
        await _saveAuthData({
          'token': data['token'] ?? '',
          'userId': data['userId']?.toString() ?? '',
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'role': data['role'] ?? 'customer',
        });
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    await _secureStorage.saveUserData(
      token: data['token'],
      userId: data['userId'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      role: data['role'],
    );
    await _localStorage.saveLoggedInUser(
      userId: data['userId'].toString(),
      userName: data['name'],
    );
    await _localStorage.setLoginState(true);
  }

  Future<void> _clearSession() async {
    await _secureStorage.clearUserData();
    await _secureStorage.clearProfileData();
    await _localStorage.setLoginState(false);
    await _localStorage.clearLoggedInUser();
  }

  // ✅ JWT expiry check (without external package)
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode base64 payload
      String payload = parts[1];
      // Pad base64 string if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decodedBytes = base64Url.decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> claims = json.decode(decodedString);

      final exp = claims['exp'];
      if (exp == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true; // Parse fail = treat as expired
    }
  }
}
