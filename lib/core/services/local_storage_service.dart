import 'dart:convert';

import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final LoggingService _logger = LoggingService.instance;

  static const String _keyIsLoggedIn = 'is_logged_in';

  static const String _keyEmployeeList = 'employee_list';
  static const String _keyEmployeeListTimestamp = 'employee_list_timestamp';

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

  /// 👥 employee  data related methods
  /// Save employee list to local storage
  Future<void> saveEmployeeList(List<EmployeeModel> employees) async {
    final employeeJsonList = employees.map((e) => e.toJson()).toList();
    await prefs.setString(_keyEmployeeList, jsonEncode(employeeJsonList));
    await prefs.setInt(_keyEmployeeListTimestamp, DateTime.now().millisecondsSinceEpoch);
    _logger.logStorage('Saved employee list (${employees.length} employees)');
  }

  ///  Get employee list from local storage
  Future<List<EmployeeModel>?> getEmployeeList() async {
    final jsonString = prefs.getString(_keyEmployeeList);
    if (jsonString == null) return null;

    try {
      final List<dynamic> employeeJsonList = jsonDecode(jsonString);
      final employees = employeeJsonList.map((json) => EmployeeModel.fromJson(json)).toList();
      _logger.logStorage('Retrieved employee list (${employees.length} employees)');
      return employees;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse employee list', error: e);
      return null;
    }
  }

  /// Get timestamp when employee list was last cached
  Future<DateTime?> getEmployeeListTimestamp() async {
    final timestamp = prefs.getInt(_keyEmployeeListTimestamp);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Clear employee list cache
  Future<void> clearEmployeeList() async {
    await prefs.remove(_keyEmployeeList);
    await prefs.remove(_keyEmployeeListTimestamp);
    _logger.logStorage('Cleared employee list cache');
  }
}
