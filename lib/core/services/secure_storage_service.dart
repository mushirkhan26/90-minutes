import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SecureStorageService._internal();

  // 🔑 Keys
  static const String _keyToken = 'auth_token';
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';

  /// ✅ Save user data securely
  Future<void> saveUserData({
    required String token,
    required String employeeId,
    required String username,
    required String email,
    required String role,
  }) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyEmployeeId, value: employeeId);
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyRole, value: role);
  }

  /// 📥 Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final token = await _secureStorage.read(key: _keyToken);
    if (token == null) return null;

    return {
      "token": token,
      "employeeId": await _secureStorage.read(key: _keyEmployeeId),
      "username": await _secureStorage.read(key: _keyUsername),
      "email": await _secureStorage.read(key: _keyEmail),
      "role": await _secureStorage.read(key: _keyRole),
    };
  }

  /// 🧽 Clear user data (logout)
  Future<void> clearUserData() async {
    await _secureStorage.deleteAll();
  }

  /// 🧾 Get only token
  Future<String?> getToken() async {
    return _secureStorage.read(key: _keyToken);
  }
}
