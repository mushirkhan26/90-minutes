import 'dart:convert';

import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final LoggingService _logger = LoggingService.instance;

  static const String _keyIsLoggedIn = 'is_logged_in';

  // employee list data related keys
  static const String _keyEmployeeList = 'employee_list';
  static const String _keyEmployeeListTimestamp = 'employee_list_timestamp';

  // 📩 Mail caching related keys
  static const String keyInboxMails = 'inbox_mails';
  static const String keySentMails = 'sent_mails';
  static const String keyTrashMails = 'trash_mails';

  // chat messages storage related  keys
  static const String _keyChatMessages = 'chat_messages_';

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

  // mail related save methods

  // Save list of mails + timestamp
  Future<void> saveMails(String key, List<MailModel> mails) async {
    final jsonList = mails.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
    await prefs.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    _logger.logStorage('Saved ${mails.length} mails to cache ($key)');
  }

  // Get cached mails
  Future<List<MailModel>?> getMails(String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => MailModel.fromJson(json)).toList();
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse cached mails', error: e);
      return null;
    }
  }

  // Get cache timestamp
  Future<DateTime?> getMailCacheTimestamp(String key) async {
    final ts = prefs.getInt('${key}_timestamp');
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  // Clear a cache
  Future<void> clearMailCache(String key) async {
    await prefs.remove(key);
    await prefs.remove('${key}_timestamp');
    _logger.logStorage('Cleared mail cache for $key');
  }

  // chat message storage

  /// Save chat messages for a specific conversation
  Future<void> saveChatMessages(String conversationId, List<ChatMessageModel> messages) async {
    final key = _getChatMessagesKey(conversationId);
    final messageJsonList = messages.map((m) => m.toLocalMap()).toList();
    await prefs.setString(key, jsonEncode(messageJsonList));
    _logger.logStorage('Saved ${messages.length} messages for conversation $conversationId');
  }

  /// Get chat messages for a specific conversation
  Future<List<ChatMessageModel>> getChatMessages(String conversationId) async {
    final key = _getChatMessagesKey(conversationId);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> messageJsonList = jsonDecode(jsonString);
      final messages = messageJsonList.map((json) => ChatMessageModel.fromLocalMap(json)).toList();
      _logger.logStorage('Retrieved ${messages.length} messages for conversation $conversationId');
      return messages;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse chat messages', error: e);
      return [];
    }
  }

  /// Add a single message to a conversation
  Future<void> addChatMessage(String conversationId, ChatMessageModel message) async {
    final existingMessages = await getChatMessages(conversationId);
    existingMessages.add(message);
    await saveChatMessages(conversationId, existingMessages);
  }

  /// Update a message in a conversation
  Future<void> updateChatMessage(String conversationId, ChatMessageModel updatedMessage) async {
    final existingMessages = await getChatMessages(conversationId);
    final index = existingMessages.indexWhere((m) => m.messageId == updatedMessage.messageId);
    if (index != -1) {
      existingMessages[index] = updatedMessage;
      await saveChatMessages(conversationId, existingMessages);
    }
  }

  /// Delete a message from a conversation
  Future<void> deleteChatMessage(String conversationId, String messageId) async {
    final existingMessages = await getChatMessages(conversationId);
    existingMessages.removeWhere((m) => m.messageId == messageId);
    await saveChatMessages(conversationId, existingMessages);
  }

  /// Clear all messages for a conversation
  Future<void> clearConversationMessages(String conversationId) async {
    final key = _getChatMessagesKey(conversationId);
    await prefs.remove(key);
    _logger.logStorage('Cleared messages for conversation $conversationId');
  }

  /// Get the storage key for a conversation's messages
  String _getChatMessagesKey(String conversationId) {
    return '$_keyChatMessages$conversationId';
  }
}
