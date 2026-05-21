import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message_model.dart';
import '../models/group_chat_list_model.dart';
import '../models/group_message_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'logger_service.dart';


class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final LoggingService _logger = LoggingService.instance;

  static const String _keyIsLoggedIn = 'is_logged_in';

  static const String _keyLastSeenPrefix = 'last_seen_';

  static const String _keyRecentChats = 'recent_chats';
  
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserList = 'user_list';
  static const String _keyUserListTimestamp = 'user_list_timestamp';
  static const String _keyUserRole = 'user_role';

  // chat messages storage related  keys
  static const String _keyChatMessages = 'chat_messages_';

  // group chat related keys
  static const String _keyGroupChats = 'group_chats';
  static const String _keyGroupMessages = 'group_messages_';

 // 🔔 Notification caching keys
 static const String keyNotifications = 'notifications_list';

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

  Future<void> saveJson(String key, dynamic data) async {
    await prefs.setString(key, jsonEncode(data));
    await prefs.setInt(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved JSON cache: $key');
  }

  Future<dynamic> getJson(String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    _logger.logStorage('Loaded JSON cache: $key');
    return jsonDecode(jsonString);
  }

  Future<DateTime?> getTimestamp(String key) async {
    final ts = prefs.getInt('${key}_timestamp');
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
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

  // 🕒 Save user's last seen time
  Future<void> saveLastSeenTime(String userId) async {
    await prefs.setInt(
      '$_keyLastSeenPrefix$userId',
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved last seen time for $userId');
  }

  // ⏱ Get user's last seen time
  Future<DateTime?> getLastSeenTime(String userId) async {
    final ts = prefs.getInt('$_keyLastSeenPrefix$userId');
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  // --------------------------------------------------------------------------
  // 🕓 Recently Chatted Users (sorted by last opened chat)
  // --------------------------------------------------------------------------

  /// Save the recent chat user order
  Future<void> saveRecentChatUsers(List<String> userIds) async {
    await prefs.setStringList(_keyRecentChats, userIds);
    _logger.logStorage('Saved recent chat users: ${userIds.join(', ')}');
  }

  /// Add or update one user in recent chat list
  Future<void> addRecentChatUser(String userId) async {
    final currentList = await getRecentChatUsers();
    currentList.remove(userId);
    currentList.insert(0, userId); // newest first
    await saveRecentChatUsers(currentList);
  }

  /// Get persisted list of recently chatted users
  Future<List<String>> getRecentChatUsers() async {
    final list = prefs.getStringList(_keyRecentChats) ?? [];
    _logger.logStorage('Retrieved ${list.length} recent chat users');
    return list;
  }

  /// Clear all recent chat history
  Future<void> clearRecentChats() async {
    await prefs.remove(_keyRecentChats);
    _logger.logStorage('Cleared all recent chat users');
  }

  /// 👥 User list methods
  Future<void> saveUserList(List<UserModel> users) async {
    final userJsonList = users.map((e) => e.toJson()).toList();
    await prefs.setString(_keyUserList, jsonEncode(userJsonList));
    await prefs.setInt(
      _keyUserListTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved user list (${users.length} users)');
  }

  Future<List<UserModel>?> getUserList() async {
    final jsonString = prefs.getString(_keyUserList);
    if (jsonString == null) return null;

    try {
      final List<dynamic> userJsonList = jsonDecode(jsonString);
      final users = userJsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      _logger.logStorage(
        'Retrieved user list (${users.length} users)',
      );
      return users;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse user list', error: e);
      return null;
    }
  }

  Future<DateTime?> getUserListTimestamp() async {
    final timestamp = prefs.getInt(_keyUserListTimestamp);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> clearUserList() async {
    await prefs.remove(_keyUserList);
    await prefs.remove(_keyUserListTimestamp);
    _logger.logStorage('Cleared user list cache');
  }

  Future<void> saveUserRole(String role) async {
  await prefs.setString(_keyUserRole, role);
  _logger.logStorage('Saved user role: $role');
}

Future<String?> getUserRole() async {
  return prefs.getString(_keyUserRole);
}

  // chat message storage

  /// Save chat messages for a specific conversation
  Future<void> saveChatMessages(
    String conversationId,
    List<ChatMessageModel> messages,
  ) async {
    final key = _getChatMessagesKey(conversationId);
    final messageJsonList = messages.map((m) => m.toLocalMap()).toList();
    await prefs.setString(key, jsonEncode(messageJsonList));
    _logger.logStorage(
      'Saved ${messages.length} messages for conversation $conversationId',
    );
  }

  /// Get chat messages for a specific conversation
  Future<List<ChatMessageModel>> getChatMessages(String conversationId) async {
    final key = _getChatMessagesKey(conversationId);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> messageJsonList = jsonDecode(jsonString);
      final messages = messageJsonList
          .map((json) => ChatMessageModel.fromLocalMap(json))
          .toList();
      _logger.logStorage(
        'Retrieved ${messages.length} messages for conversation $conversationId',
      );
      return messages;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse chat messages', error: e);
      return [];
    }
  }

  /// Add a single message to a conversation
  Future<void> addChatMessage(
    String conversationId,
    ChatMessageModel message,
  ) async {
    final existingMessages = await getChatMessages(conversationId);
    existingMessages.add(message);
    await saveChatMessages(conversationId, existingMessages);
  }

  /// Update a message in a conversation
  Future<void> updateChatMessage(
    String conversationId,
    ChatMessageModel updatedMessage,
  ) async {
    final existingMessages = await getChatMessages(conversationId);
    final index = existingMessages.indexWhere(
      (m) => m.messageId == updatedMessage.messageId,
    );
    if (index != -1) {
      existingMessages[index] = updatedMessage;
      await saveChatMessages(conversationId, existingMessages);
    }
  }

  /// Delete a message from a conversation
  Future<void> deleteChatMessage(
    String conversationId,
    String messageId,
  ) async {
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

  // --------------------------------------------------------------------------
  // group functionality related saving methods
  //---------------------------------------------------------------------------

  /// Save group chats to local storage
  Future<void> saveGroupChats(List<GroupChatModel> groups) async {
    final groupJsonList = groups.map((g) => g.toLocalMap()).toList();
    await prefs.setString(_keyGroupChats, jsonEncode(groupJsonList));
    _logger.logStorage('Saved ${groups.length} group chats');
  }

  /// Get group chats from local storage
  Future<List<GroupChatModel>> getGroupChats() async {
    final jsonString = prefs.getString(_keyGroupChats);
    if (jsonString == null) return [];
    try {
      final List<dynamic> groupJsonList = jsonDecode(jsonString);
      final groups = groupJsonList
          .map((json) => GroupChatModel.fromLocalMap(json))
          .toList();
      _logger.logStorage('Retrieved ${groups.length} group chats');
      return groups;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse group chats', error: e);
      return [];
    }
  }

  /// Save group messages for a specific group
  Future<void> saveGroupMessages(
    String groupId,
    List<GroupMessageModel> messages,
  ) async {
    final key = _getGroupMessagesKey(groupId);
    final messageJsonList = messages.map((m) => m.toLocalMap()).toList();
    await prefs.setString(key, jsonEncode(messageJsonList));
    _logger.logStorage('Saved ${messages.length} messages for group $groupId');
  }

  /// Get group messages for a specific group
  Future<List<GroupMessageModel>> getGroupMessages(String groupId) async {
    final key = _getGroupMessagesKey(groupId);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> messageJsonList = jsonDecode(jsonString);
      final messages = messageJsonList
          .map((json) => GroupMessageModel.fromLocalMap(json))
          .toList();
      _logger.logStorage(
        'Retrieved ${messages.length} messages for group $groupId',
      );
      return messages;
    } catch (e) {
      _logger.error(
        'LOCAL_STORAGE',
        'Failed to parse group messages',
        error: e,
      );
      return [];
    }
  }

  /// Add a single group message to a group
  Future<void> addGroupMessage(
    String groupId,
    GroupMessageModel message,
  ) async {
    final existingMessages = await getGroupMessages(groupId);
    existingMessages.add(message);
    await saveGroupMessages(groupId, existingMessages);
  }

  /// Update a group message
  Future<void> updateGroupMessage(
    String groupId,
    GroupMessageModel updatedMessage,
  ) async {
    final existingMessages = await getGroupMessages(groupId);
    final index = existingMessages.indexWhere(
      (m) => m.messageId == updatedMessage.messageId,
    );
    if (index != -1) {
      existingMessages[index] = updatedMessage;
      await saveGroupMessages(groupId, existingMessages);
    }
  }

  /// Delete a group message
  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    final existingMessages = await getGroupMessages(groupId);
    existingMessages.removeWhere((m) => m.messageId == messageId);
    await saveGroupMessages(groupId, existingMessages);
  }

  /// Clear all messages for a group
  Future<void> clearGroupMessages(String groupId) async {
    final key = _getGroupMessagesKey(groupId);
    await prefs.remove(key);
    _logger.logStorage('Cleared messages for group $groupId');
  }

  /// Get the storage key for a group's messages
  String _getGroupMessagesKey(String groupId) {
    return '$_keyGroupMessages$groupId';
  }

  /// 🔹 Get logged-in user name
  Future<String?> getUserName() async {
    return prefs.getString(_keyUserName);
  }

  /// 🔹 Save logged-in user details
  Future<void> saveLoggedInUser({
    required String userId,
    required String userName,
  }) async {
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    _logger.logStorage('Saved logged-in user: $userId - $userName');
  }

  /// 🔹 Get logged-in user ID
  Future<String?> getUserId() async {
    return prefs.getString(_keyUserId);
  }

  // ================= LOGGED IN USER =================
Future<void> clearLoggedInUser() async {
  await prefs.remove(_keyUserId);
  await prefs.remove(_keyUserName);
}

  // --------------------------------------------------------------------------
  // 🔔 Notifications caching methods
  // --------------------------------------------------------------------------

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final jsonList = notifications.map((e) => e.toJson()).toList();
    await prefs.setString(keyNotifications, jsonEncode(jsonList));
    _logger.logStorage('Saved ${notifications.length} notifications to cache');
  }

  Future<List<NotificationModel>?> getNotifications() async {
    final jsonString = prefs.getString(keyNotifications);
    if (jsonString == null) return null;
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse cached notifications', error: e);
      return null;
    }
  }

  Future<void> clearNotificationsCache() async {
    await prefs.remove(keyNotifications);
    _logger.logStorage('Cleared notifications cache');
  }
}
