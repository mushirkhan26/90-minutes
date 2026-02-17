import 'dart:convert';

import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/models/group_message_model.dart';
import 'package:hrtz_hrms/core/models/leaderboard_model.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/core/models/meet_model.dart';
import 'package:hrtz_hrms/core/models/performance_model.dart';
import 'package:hrtz_hrms/core/models/project_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrtz_hrms/core/models/benefits_claim_model.dart';


class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;
  final LoggingService _logger = LoggingService.instance;

  static const String _keyIsLoggedIn = 'is_logged_in';

  static const String _keyLastSeenPrefix = 'last_seen_';

  static const String _keyRecentChats = 'recent_chats';
  // employee list data related keys
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyEmployeeName = 'employee_name';
  static const String _keyEmployeeList = 'employee_list';
  static const String _keyEmployeeListTimestamp = 'employee_list_timestamp';
  // meet caching data related keys
  static const String keyMeetList = 'meet_list';
  static const String keyMeetListTimestamp = 'meet_list_timestamp';

  // 📩 Mail caching related keys
  static const String keyInboxMails = 'inbox_mails';
  static const String keySentMails = 'sent_mails';
  static const String keyTrashMails = 'trash_mails';

  // 📈 Performance caching related keys
  static const String keyMyRatings = 'my_ratings';
  static const String keyTeamRatings = 'team_ratings';

  // 🏆 Leaderboard caching related keys
  static const String keyLeaderboardList = 'leaderboard_list';
  static const String keyUserStats = 'user_stats';

  // 📁 Project caching related keys
  static const String keyProjectList = 'project_list';

  // chat messages storage related  keys
  static const String _keyChatMessages = 'chat_messages_';

  // group chat related keys
  static const String _keyGroupChats = 'group_chats';
  static const String _keyGroupMessages = 'group_messages_';

  static const String keyLeaveHistory = 'leave_history';
  static const String keyAvailableLeave = 'available_leave';
  static const String keyAttendanceData = 'attendance_data';

  ///learning studio related keys
  // Learning Studio cache keys
  static const String keyDepartments = 'ls_departments';
  static const String keySubDepartmentsPrefix = 'ls_sub_departments_';
  static const String keyCoursesPrefix = 'ls_courses_';
  static const String keyEmployeeCourses = 'ls_employee_courses';
  static const String keyCourseCount = 'ls_course_count';

  ///service request cache keys

  static const String keyServiceRequests = 'service_requests';
  static const String keyServiceRequestCounts = 'service_request_counts';
  static const String keyDepartmentsConfig = 'config_departments';

  //  Benefits-Claims cache keys
  static const String keyMyClaimsPrefix = 'benefits_my_claims_';
  static const String keyMyClaimsTimestampPrefix = 'benefits_my_claims_ts_';

  static const String keyAllClaims = 'benefits_all_claims';
  static const String keyAllClaimsTimestamp = 'benefits_all_claims_ts';

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

  /// 👥 employee  data related methods
  /// Save employee list to local storage
  Future<void> saveEmployeeList(List<EmployeeModel> employees) async {
    final employeeJsonList = employees.map((e) => e.toJson()).toList();
    await prefs.setString(_keyEmployeeList, jsonEncode(employeeJsonList));
    await prefs.setInt(
      _keyEmployeeListTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved employee list (${employees.length} employees)');
  }

  ///  Get employee list from local storage
  Future<List<EmployeeModel>?> getEmployeeList() async {
    final jsonString = prefs.getString(_keyEmployeeList);
    if (jsonString == null) return null;

    try {
      final List<dynamic> employeeJsonList = jsonDecode(jsonString);
      final employees = employeeJsonList
          .map((json) => EmployeeModel.fromJson(json))
          .toList();
      _logger.logStorage(
        'Retrieved employee list (${employees.length} employees)',
      );
      return employees;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse employee list', error: e);
      return null;
    }
  }

  /// Get timestamp when employee list was last cached
  Future<DateTime?> getEmployeeListTimestamp() async {
    final timestamp = prefs.getInt(_keyEmployeeListTimestamp);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
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
    await prefs.setInt(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
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

  // 📈 Performance related save methods
  Future<void> savePerformanceRatings(
    String key,
    List<PerformanceModel> ratings,
  ) async {
    final jsonList = ratings.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
    await prefs.setInt(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage(
      'Saved ${ratings.length} performance ratings to cache ($key)',
    );
  }

  Future<List<PerformanceModel>?> getPerformanceRatings(String key) async {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((json) => PerformanceModel.fromJson(json)).toList();
    } catch (e) {
      _logger.error(
        'LOCAL_STORAGE',
        'Failed to parse cached performance ratings',
        error: e,
      );
      return null;
    }
  }

  //--------------------------------------------------------------------------
  // meet api  storage methods
  // -------------------------------------------------------------------------
  // Meet caching related keys

  // Save meet list to local storage
  Future<void> saveMeetList(List<Meet> meets) async {
    final meetJsonList = meets.map((e) => e.toJson()).toList();
    await prefs.setString(keyMeetList, jsonEncode(meetJsonList));
    await prefs.setInt(
      keyMeetListTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved meet list (${meets.length} meets)');
  }

  // Get meet list from local storage
  Future<List<Meet>?> getMeetList() async {
    final jsonString = prefs.getString(keyMeetList);
    if (jsonString == null) return null;
    try {
      final List<dynamic> meetJsonList = jsonDecode(jsonString);
      final meets = meetJsonList.map((json) => Meet.fromJson(json)).toList();
      _logger.logStorage('Retrieved meet list (${meets.length} meets)');
      return meets;
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse meet list', error: e);
      return null;
    }
  }

  // Get timestamp when meet list was last cached
  Future<DateTime?> getMeetListTimestamp() async {
    final timestamp = prefs.getInt(keyMeetListTimestamp);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // Clear meet list cache
  Future<void> clearMeetList() async {
    await prefs.remove(keyMeetList);
    await prefs.remove(keyMeetListTimestamp);
    _logger.logStorage('Cleared meet list cache');
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

  /// Save leave history
  Future<void> saveLeaveHistory(Map<String, dynamic> leaveHistory) async {
    await saveString(keyLeaveHistory, jsonEncode(leaveHistory));
  }

  /// Get leave history
  Future<Map<String, dynamic>?> getLeaveHistory() async {
    final jsonString = await getString(keyLeaveHistory);
    if (jsonString == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      _logger.error('LOCAL_STORAGE', 'Failed to parse leave history', error: e);
      return null;
    }
  }

  /// Save available leave
  Future<void> saveAvailableLeave(Map<String, dynamic> availableLeave) async {
    await saveString(keyAvailableLeave, jsonEncode(availableLeave));
  }

  /// Get available leave
  Future<Map<String, dynamic>?> getAvailableLeave() async {
    final jsonString = await getString(keyAvailableLeave);
    if (jsonString == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      _logger.error(
        'LOCAL_STORAGE',
        'Failed to parse available leave',
        error: e,
      );
      return null;
    }
  }

  /// Save attendance data
  Future<void> saveAttendanceData(Map<String, dynamic> attendanceData) async {
    await saveString(keyAttendanceData, jsonEncode(attendanceData));
  }

  /// Get attendance data
  Future<Map<String, dynamic>?> getAttendanceData() async {
    final jsonString = await getString(keyAttendanceData);
    if (jsonString == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      _logger.error(
        'LOCAL_STORAGE',
        'Failed to parse attendance data',
        error: e,
      );
      return null;
    }
  }

  /// 🔹 Get logged-in employee name
  Future<String?> getEmployeeName() async {
    return prefs.getString(_keyEmployeeName);
  }

  /// 🔹 Save logged-in employee details
  Future<void> saveLoggedInEmployee({
    required String employeeId,
    required String employeeName,
  }) async {
    await prefs.setString(_keyEmployeeId, employeeId);
    await prefs.setString(_keyEmployeeName, employeeName);
    _logger.logStorage('Saved logged-in employee: $employeeId - $employeeName');
  }

  /// 🔹 Get logged-in employee ID
  Future<String?> getEmployeeId() async {
    return prefs.getString(_keyEmployeeId);
  }

  // ================= SERVICE REQUEST STORAGE =================

  // Save service request list
  Future<void> saveServiceRequests(List<Map<String, dynamic>> requests) async {
    await prefs.setString(keyServiceRequests, jsonEncode(requests));
    await prefs.setInt(
      '${keyServiceRequests}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    _logger.logStorage('Saved service requests (${requests.length})');
  }

  // Get cached service request list
  Future<List<Map<String, dynamic>>?> getServiceRequests() async {
    final jsonString = prefs.getString(keyServiceRequests);
    if (jsonString == null) return null;

    try {
      final List list = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      _logger.error(
        'LOCAL_STORAGE',
        'Failed to parse service requests',
        error: e,
      );
      return null;
    }
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    await prefs.setString(keyUserStats, jsonEncode(stats.toJson()));
    _logger.logStorage('Saved user stats');
  }

  Future<UserStatsModel?> getUserStats() async {
    final jsonString = prefs.getString(keyUserStats);
    if (jsonString == null) return null;
    try {
      return UserStatsModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  // ================= DEPARTMENTS =================
  Future<void> saveDepartments(List<String> departments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('departments', departments);
  }

  Future<List<String>?> getDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('departments');
  }

  // ================= REQUEST COUNTS =================
  Future<void> saveServiceRequestCounts(Map<String, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    final map = counts.map((k, v) => MapEntry(k, v.toString()));
    await prefs.setString('service_request_counts', jsonEncode(map));
  }

  Future<Map<String, dynamic>?> getServiceRequestCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('service_request_counts');
    if (json == null) return null;
    return Map<String, dynamic>.from(jsonDecode(json));
  }

  // ================= TIMESTAMP =================
  Future<void> saveServiceRequestTimestamp(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('service_request_timestamp', time.toIso8601String());
  }

  Future<DateTime?> getServiceRequestTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('service_request_timestamp');
    if (value == null) return null;
    return DateTime.parse(value);
  }

  // ================= LOGGED IN EMPLOYEE =================
Future<void> clearLoggedInEmployee() async {
  await prefs.remove(_keyEmployeeId);
  await prefs.remove(_keyEmployeeName);
}

// 📁 Project caching methods
Future<void> saveProjectList(List<ProjectModel> list) async {
  final jsonList = list.map((e) => e.toJson()).toList();
  await prefs.setString(keyProjectList, jsonEncode(jsonList));
  _logger.logStorage('Saved ${list.length} project entries');
}

Future<List<ProjectModel>?> getProjectList() async {
  final jsonString = prefs.getString(keyProjectList);
  if (jsonString == null) return null;
  try {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((json) => ProjectModel.fromJson(json)).toList();
  } catch (e) {
    return null;
  }
}

/// employee benefits 

Future<void> saveClaims(
  String employeeId,
  List<BenefitsClaimModel> claims,
) async {
  final key = '$keyMyClaimsPrefix$employeeId';
  final tsKey = '$keyMyClaimsTimestampPrefix$employeeId';

  final jsonList = claims.map((e) => e.toJson()).toList();

  await prefs.setString(key, jsonEncode(jsonList));
  await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);

  _logger.logStorage(
      'Saved ${claims.length} benefits claims for $employeeId');
}

Future<List<BenefitsClaimModel>?> getClaims(
    String employeeId) async {
  final key = '$keyMyClaimsPrefix$employeeId';

  final jsonString = prefs.getString(key);
  if (jsonString == null) return null;

  try {
    final List<dynamic> list = jsonDecode(jsonString);
    return list
        .map((json) =>
            BenefitsClaimModel.fromJson(json))
        .toList();
  } catch (e) {
    _logger.error(
      'LOCAL_STORAGE',
      'Failed to parse benefits claims',
      error: e,
    );
    return null;
  }
}

Future<DateTime?> getClaimsTimestamp(
    String employeeId) async {
  final tsKey = '$keyMyClaimsTimestampPrefix$employeeId';
  final ts = prefs.getInt(tsKey);

  return ts != null
      ? DateTime.fromMillisecondsSinceEpoch(ts)
      : null;
}

Future<List<BenefitsClaimModel>?> getAllClaims() async {
  final jsonString = prefs.getString(keyAllClaims);
  if (jsonString == null) return null;

  try {
    final List<dynamic> list = jsonDecode(jsonString);
    return list
        .map((json) =>
            BenefitsClaimModel.fromJson(json))
        .toList();
  } catch (e) {
    _logger.error(
      'LOCAL_STORAGE',
      'Failed to parse all benefits claims',
      error: e,
    );
    return null;
  }
}

Future<void> saveAllClaims(
    List<BenefitsClaimModel> claims) async {
  final jsonList = claims.map((e) => e.toJson()).toList();

  await prefs.setString(
      keyAllClaims, jsonEncode(jsonList));
  await prefs.setInt(
      keyAllClaimsTimestamp,
      DateTime.now().millisecondsSinceEpoch);

  _logger.logStorage(
      'Saved ${claims.length} all benefits claims');
}

Future<DateTime?> getAllClaimsTimestamp() async {
  final ts = prefs.getInt(keyAllClaimsTimestamp);

  return ts != null
      ? DateTime.fromMillisecondsSinceEpoch(ts)
      : null;
}
}
