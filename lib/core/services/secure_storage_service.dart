import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SecureStorageService._internal();

  // 🔑 Keys
  static const String _keyToken = 'auth_token';
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyAppToken = 'app_token'; // 🔥 Added for FCM

  // 📄 Profile Keys
  static const String _keyMobile = 'mobile';
  static const String _keyAlterMobile = 'alter_mobile';
  static const String _keyGender = 'gender';
  static const String _keyAddress = 'address';
  static const String _keyProfileImage = 'profile_image';

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

  // Get user ID or employee ID
  Future<String?> getEmployeeId() async =>
      _secureStorage.read(key: _keyEmployeeId);

  // Get current username or employee name
  Future<String?> getUserName() async => _secureStorage.read(key: _keyUsername);

  // 🔥 FCM Token Methods
  Future<void> saveAppToken(String token) async =>
      _secureStorage.write(key: _keyAppToken, value: token);

  Future<String?> getAppToken() async => _secureStorage.read(key: _keyAppToken);

  Future<void> deleteAppToken() async =>
      _secureStorage.delete(key: _keyAppToken);

  // 📄 Profile Data Methods

  /// Save profile data
  Future<void> saveProfileData({
    required String mobile,
    required String alterMobile,
    required String gender,
    required String address,
    String? profileImage,
  }) async {
    await _secureStorage.write(key: _keyMobile, value: mobile);
    await _secureStorage.write(key: _keyAlterMobile, value: alterMobile);
    await _secureStorage.write(key: _keyGender, value: gender);
    await _secureStorage.write(key: _keyAddress, value: address);
    if (profileImage != null) {
      await _secureStorage.write(key: _keyProfileImage, value: profileImage);
    }
  }

  /// Get profile data
  Future<Map<String, String?>?> getProfileData() async {
    final mobile = await _secureStorage.read(key: _keyMobile);
    if (mobile == null) return null;
    return {
      "mobile": mobile,
      "alterMobile": await _secureStorage.read(key: _keyAlterMobile),
      "gender": await _secureStorage.read(key: _keyGender),
      "address": await _secureStorage.read(key: _keyAddress),
      "profileImage": await _secureStorage.read(key: _keyProfileImage),
    };
  }

  /// Get individual profile fields
  Future<String?> getMobile() async => _secureStorage.read(key: _keyMobile);
  Future<String?> getAlterMobile() async =>
      _secureStorage.read(key: _keyAlterMobile);
  Future<String?> getGender() async => _secureStorage.read(key: _keyGender);
  Future<String?> getAddress() async => _secureStorage.read(key: _keyAddress);
  Future<String?> getProfileImage() async =>
      _secureStorage.read(key: _keyProfileImage);

  /// Clear profile data
  Future<void> clearProfileData() async {
    await _secureStorage.delete(key: _keyMobile);
    await _secureStorage.delete(key: _keyAlterMobile);
    await _secureStorage.delete(key: _keyGender);
    await _secureStorage.delete(key: _keyAddress);
    await _secureStorage.delete(key: _keyProfileImage);
  }
}
