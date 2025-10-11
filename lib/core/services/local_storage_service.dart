import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger_service.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final _logger = LoggerService();

  static const String _keyIsLoggedIn = 'is_logged_in';

  /// 🚀 Initialize storage once on app start
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    LoggerService().logStorage('📦 LocalStorageService initialized');
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
  }

  Future<String?> getString(String key) async {
    return prefs.getString(key);
  }

  Future<void> removeString(String key) async {
    await prefs.remove(key);
  }

  /// 🔘 Boolean
  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    return prefs.getBool(key) ?? false;
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
