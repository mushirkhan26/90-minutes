// lib/providers/group_socket_provider.dart
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/services/local_notifications_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/socket/socket_manager.dart';

import '../models/group_message_model.dart';

class GroupSocketProvider extends ChangeNotifier {
  final SocketManager _manager = SocketManager.instance;
  final LoggingService _logger = LoggingService.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();

  // State for group chats
  List<GroupChatModel> _groupChats = [];
  List<GroupMessageModel> _groupMessages = [];
  final Map<String, bool> _groupTypingIndicators = {};
  final Map<String, int> _groupUnreadCounts = {};

  // Getters
  List<GroupChatModel> get groupChats => List.unmodifiable(_groupChats);
  List<GroupMessageModel> get groupMessages =>
      List.unmodifiable(_groupMessages);
  Map<String, bool> get groupTypingIndicators =>
      Map.unmodifiable(_groupTypingIndicators);
  Map<String, int> get groupUnreadCounts =>
      Map.unmodifiable(_groupUnreadCounts);

  // Active group chat
  String? _activeGroupId;
  void setActiveGroupId(String? groupId) {
    _activeGroupId = groupId;
  }

  // Initialize group event listeners
  void init() {
    _manager.registerGroupEvent('userGroups', (data) async {
      if (data == null || data is! Map<String, dynamic>) return;
      if (data['success'] == false) return;

      final groupsData = data['groups'];
      if (groupsData is List) {
        _groupChats = groupsData
            .map((g) => GroupChatModel.fromMap(g as Map<String, dynamic>))
            .toList();
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
    });

    _manager.registerGroupEvent('groupCreated', (data) async {
      if (data['group'] != null) {
        final newGroup = GroupChatModel.fromMap(data['group']);
        // Prevent duplicate group in list
        if (!_groupChats.any((g) => g.groupId == newGroup.groupId)) {
          _groupChats.add(newGroup);
          await _localStorage.saveGroupChats(_groupChats);
          notifyListeners();
        }
      }
    });

    _manager.registerGroupEvent('receiveGroupMessage', (data) async {
      final backendId = data['_id']?.toString();
      if (backendId == null) return;

      try {
        final message = GroupMessageModel.fromMap(data);

        // ✅ 1. Check for backend ID duplicate
        if (message.id != null &&
            _groupMessages.any((m) => m.id == message.id)) {
          _logger.logNetwork(
            "[GroupSocket] ⛔ Duplicate backend ID ignored: ${message.id}",
          );
          return;
        }

        // ✅ 2. Advanced Deduplication Logic
        // Look for the optimistic message we just sent
        int index = -1;

        // Try matching by messageId first
        index = _groupMessages.indexWhere(
          (m) => m.messageId == message.messageId,
        );

        // Fallback: Match by sender + text + proximity in time (within 10 seconds)
        if (index == -1 &&
            message.sender == await _secureStorage.getEmployeeId()) {
          index = _groupMessages.indexWhere(
            (m) =>
                m.sender == message.sender &&
                m.text == message.text &&
                m.messageId.startsWith('temp_') &&
                message.timestamp.difference(m.timestamp).inSeconds.abs() < 10,
          );
        }

        if (index != -1) {
          // If we found a match, check if it's already a finalized message
          if (!_groupMessages[index].messageId.startsWith('temp_') &&
              _groupMessages[index].id != null) {
            _logger.logNetwork(
              "[GroupSocket] ⛔ Duplicate message ignored (already finalized)",
            );
            return;
          }
          // Update the optimistic/temp message with backend data (including the new ID)
          _groupMessages[index] = message;
          _logger.logNetwork(
            "[GroupSocket] ✅ Optimistic message updated with backend data",
          );
        } else {
          _groupMessages.add(message);
          _logger.logNetwork(
            "[GroupSocket] 📩 New group message added to list",
          );
        }

        await _localStorage.addGroupMessage(message.groupId, message);

        final currentUserData = await SecureStorageService().getUserData();
        final currentUserId = currentUserData?['employeeId'] ?? "";

        if (message.sender != currentUserId) {
          if (message.groupId != _activeGroupId) {
            _groupUnreadCounts[message.groupId] =
                (_groupUnreadCounts[message.groupId] ?? 0) + 1;

            final group = _groupChats.firstWhere(
              (g) => g.groupId == message.groupId,
              orElse: () => GroupChatModel(
                groupId: message.groupId,
                name: "Group",
                members: [],
                createdBy: "",
                createdAt: DateTime.now(),
              ),
            );

            await LocalNotificationService().showGroupNotification(
              groupId: message.groupId,
              groupName: group.name,
              senderName: message.senderName,
              currentUserData: currentUserData,
            );
          }
        }
        // ✅ THIS FIXES YOUR BUG
        _moveGroupToTop(message);
        notifyListeners();
      } catch (e) {
        _logger.error("GroupSocket", "Failed to parse group message", error: e);
      }
    });

    _manager.registerGroupEvent('groupMessageDeleted', (data) async {
      final messageId = data['messageId'];
      final groupId = data['groupId'];
      _groupMessages.removeWhere(
        (m) => m.messageId == messageId || m.id == messageId,
      );
      await _localStorage.deleteGroupMessage(groupId, messageId);
      notifyListeners();
    });

    _manager.registerGroupEvent('groupChatCleared', (data) async {
      final groupId = data['groupId'];
      _groupMessages.removeWhere((m) => m.groupId == groupId);
      await _localStorage.clearGroupMessages(groupId);
      notifyListeners();
      _logger.logNetwork("Group chat cleared via socket: $groupId");
    });

    _manager.registerGroupEvent('removedFromGroup', (data) async {
      final groupId = data['groupId'];
      _groupChats.removeWhere((g) => g.groupId == groupId);
      await _localStorage.saveGroupChats(_groupChats);
      notifyListeners();
    });

    _manager.registerGroupEvent('groupDeleted', (data) async {
      final groupId = data['groupId'];
      _groupChats.removeWhere((g) => g.groupId == groupId);
      await _localStorage.saveGroupChats(_groupChats);
      notifyListeners();
    });
  }

  Future<void> fetchUserGroups() async {
    final userId = await _secureStorage.getEmployeeId();
    await _manager.getUserGroups(userId ?? "");
  }

  Future<void> createGroup({
    required String name,
    required String createdBy,
    required List<String> members,
    String? description,
    String? icon,
  }) async {
    await _manager.createGroup(
      name: name,
      createdBy: createdBy,
      members: members,
      description: description,
      icon: icon,
    );
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String sender,
    required String senderName,
    required String text,
    String? messageId,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
    List<String>? mentions,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Consistent temp_ prefix for deduplication match
    final idToSend =
        messageId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

    await _manager.sendGroupMessage(
      groupId: groupId,
      sender: sender,
      senderName: senderName,
      text: text,
      messageId: idToSend,
      messageType: messageType,
      fileName: fileName,
      fileUrl: fileUrl,
      replyTo: replyTo,
      mentions: mentions,
      timestamp: timestamp,
    );
  }

  Future<void> deleteGroupMessage({
    required String messageId,
    required String userId,
    required String groupId,
  }) async {
    await _manager.deleteGroupMessage(
      messageId: messageId,
      userId: userId,
      groupId: groupId,
    );
  }

  Future<void> clearGroupChat({
    required String groupId,
    required String userId,
  }) async {
    await _manager.clearGroupChat(groupId: groupId, userId: userId);

    // Clear locally immediately
    _groupMessages.removeWhere((m) => m.groupId == groupId);
    await _localStorage.clearGroupMessages(groupId);
    notifyListeners();
  }

  void sendGroupTypingStatus({
    required String userId,
    required String userName,
    required String groupId,
    required bool isTyping,
  }) {
    _manager.sendGroupTypingStatus(
      userId: userId,
      userName: userName,
      groupId: groupId,
      isTyping: isTyping,
    );
  }

  Future<void> loadGroupMessages(String groupId) async {
    _groupMessages = await _localStorage.getGroupMessages(groupId);
    notifyListeners();
  }

  List<GroupMessageModel> getGroupMessages(String groupId) {
    return _groupMessages.where((m) => m.groupId == groupId).toList();
  }

  void addLocalGroupMessage(GroupMessageModel message) {
    if (_groupMessages.any((m) => m.messageId == message.messageId)) return;
    _groupMessages.add(message);
    notifyListeners();
  }

  void resetGroupUnreadCount(String groupId, {bool notify = true}) {
    if (_groupUnreadCounts.containsKey(groupId)) {
      _groupUnreadCounts.remove(groupId);
      if (notify) notifyListeners();
    }
  }

  void removeLocalGroupMessage(String localmessageId) {
    _groupMessages.removeWhere((m) => m.messageId == localmessageId);
    notifyListeners();
  }

  Future<void> editGroupName(
    String groupId,
    String newName,
    String userId,
  ) async {
    await _manager.editGroupName(
      groupId: groupId,
      newName: newName,
      userId: userId,
    );
  }

  Future<void> addGroupMembers(
    String groupId,
    List<String> newMembers,
    String addedBy,
  ) async {
    //  Optimistic Update in Provider
    final index = _groupChats.indexWhere((g) => g.groupId == groupId);
    if (index != -1) {
      _groupChats[index] = _groupChats[index].copyWith(
        members: [..._groupChats[index].members, ...newMembers],
      );
      notifyListeners();
    }
    await _manager.addGroupMembers(
      groupId: groupId,
      newMembers: newMembers,
      addedBy: addedBy,
    );
  }

  Future<void> removeGroupMember(
    String groupId,
    String userToRemove,
    String removedBy,
  ) async {
    // 🚀 Optimistic Update in Provider
    final index = _groupChats.indexWhere((g) => g.groupId == groupId);
    if (index != -1) {
      final updatedMembers = List<String>.from(_groupChats[index].members)
        ..remove(userToRemove);
      _groupChats[index] = _groupChats[index].copyWith(members: updatedMembers);
      notifyListeners();
    }
    await _manager.removeGroupMember(
      groupId: groupId,
      userToRemove: userToRemove,
      removedBy: removedBy,
    );
  }

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _manager.leaveGroup(groupId: groupId, userId: userId);
    _groupChats.removeWhere((g) => g.groupId == groupId);
    await _localStorage.saveGroupChats(_groupChats);
    notifyListeners();
  }

  Future<void> deleteGroup({
    required String groupId,
    required String deletedBy,
  }) async {
    await _manager.deleteGroup(groupId: groupId, deletedBy: deletedBy);
  }

  Future<void> markGroupMessageAsRead({
    required String messageId,
    required String userId,
  }) async {}

  void _moveGroupToTop(GroupMessageModel message) {
    final index = _groupChats.indexWhere((g) => g.groupId == message.groupId);

    if (index == -1) return;

    final updatedGroup = _groupChats[index].copyWith(
      lastMessage: message.text,
      lastMessageTime: message.timestamp,
    );

    _groupChats.removeAt(index);
    _groupChats.insert(0, updatedGroup);
  }
}
