import 'dart:convert';

import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final LoggingService _logger = LoggingService.instance;

  static const String _keyIsLoggedIn = 'is_logged_in';

  /// 🚀 Initialize storage once on app start
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    LoggingService.instance.logStorage('📦 LocalStorageService initialized');
  }

  /// 📥 Safe getter
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        '❌ LocalStorageService not initialized. Call LocalStorageService.init() first.',
      );
    }
    return _prefs!;
  }

  /// 📝 Save string data
  Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
    _logger.logStorage('Saved string: $key');
  }

  Future<List<Employee>?> getEmployee() async {
    final value = prefs.get('employee');
    final list = <Employee>[];
    if (value != null && value is String) {
      list.addAll(
        (jsonDecode(value)['data'] as List).map((e) => Employee.fromJson(e)),
      );
      return list;
    } else {
      return null;
    }
  }

  Future<void> saveEmployee(List<Employee> list) async {
    final value = jsonEncode({'data': list.map((e) => e.toJson()).toList()});
    await prefs.setString('employee', value);
  }

  Future<String?> getString(String key) async {
    final value = prefs.getString(key);
    _logger.logStorage('Retrieved string: $key');
    return value;
  }

  Future<void> removeString(String key) async {
    await prefs.remove(key);
    _logger.logStorage('Removed string: $key');
  }

  /// 🔘 Boolean
  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
    _logger.logStorage('Saved bool: $key = $value');
  }

  Future<bool> getBool(String key) async {
    final value = prefs.getBool(key) ?? false;
    _logger.logStorage('Retrieved bool: $key = $value');
    return value;
  }

  /// 🧹 Clear all local data
  Future<void> clearAll() async {
    await prefs.clear();
    _logger.logStorage('🧼 All local data cleared');
  }

  /// 👤 Helper for login state
  Future<void> setLoginState(bool loggedIn) async {
    await setBool(_keyIsLoggedIn, loggedIn);
  }

  Future<bool> isLoggedIn() async {
    return getBool(_keyIsLoggedIn);
  }
}
