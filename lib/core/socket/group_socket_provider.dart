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
  List<GroupMessageModel> get groupMessages => List.unmodifiable(_groupMessages);
  Map<String, bool> get groupTypingIndicators => Map.unmodifiable(_groupTypingIndicators);
  Map<String, int> get groupUnreadCounts => Map.unmodifiable(_groupUnreadCounts);

  // Active group chat
  String? _activeGroupId;
  void setActiveGroupId(String? groupId) {
    _activeGroupId = groupId;
    _logger.logNetwork("[GroupSocketProvider] Active group set: $_activeGroupId");
  }

  // Initialize group event listeners
  void init() {
    _manager.registerGroupEvent('userGroups', (data) async {
      _logger.logNetwork("[GroupSocket] 📥 Raw userGroups event received: $data");

      // ✅ Step 1: Validate payload type
      if (data == null || data is! Map<String, dynamic>) {
        _logger.logNetwork("[GroupSocket] ❌ Invalid or null data for userGroups");
        _groupChats = [];
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
        return;
      }

      // ✅ Step 2: Handle failed responses
      if (data['success'] == false) {
        _logger.logNetwork("[GroupSocket] ⚠️ userGroups event failed: ${data['message']}");
        _groupChats = [];
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
        return;
      }

      // ✅ Step 3: Safely parse the groups
      final groupsData = data['groups'];
      if (groupsData is List && groupsData.isNotEmpty) {
        _logger.logNetwork("[GroupSocket] ✅ Parsed ${groupsData.length} groups for user");
        _groupChats = groupsData
            .map((g) => GroupChatModel.fromMap(g as Map<String, dynamic>))
            .toList();
      } else {
        _logger.logNetwork("[GroupSocket] ℹ️ No groups found for user");
        _groupChats = [];
      }

      // ✅ Step 4: Save and update UI
      try {
        await _localStorage.saveGroupChats(_groupChats);
      } catch (e) {
        _logger.logNetwork("[GroupSocket] ⚠️ Failed to save groups locally: $e");
      }

      notifyListeners();
    });

    // --- groupCreated event ---
    _manager.registerGroupEvent('groupCreated', (data) async {
      _logger.logNetwork("[GroupSocket] 📥 Raw groupCreated event received: $data");
      _logger.logNetwork("[GroupSocket] 🆕 Group created: ${data['group']}");
      if (data['group'] != null) {
        final newGroup = GroupChatModel.fromMap(data['group']);
        _groupChats.add(newGroup);
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
      //       📤 createGroup event emitted
      //  📥 Raw groupCreated event received: {success: true, group: {_id: 69025b8e2a0c6298d73de276, name: hrms team, description: Group created by 24110002, members: [24110002, 25090016, 25060018, 25100009, 25100001], createdBy: 24110002, icon: null, createdAt: 2025-10-29T18:23:10.971Z}}
      //  🆕 Group created: {_id: 69025b8e2a0c6298d73de276, name: hrms team, description: Group created by 24110002, members: [24110002, 25090016, 25060018, 25100009, 25100001], createdBy: 24110002, icon: null, createdAt: 2025-10-29T18:23:10.971Z}
      // Saved 1 group chats
    });

    _manager.registerGroupEvent('groupDeleted', (data) async {
      _logger.logNetwork("[GroupSocket] Group deleted: ${data['groupId']}");
      _groupChats.removeWhere((g) => g.groupId == data['groupId']);
      await _localStorage.saveGroupChats(_groupChats);
      notifyListeners();
    });

    _manager.registerGroupEvent('receiveGroupMessage', (data) async {
      _logger.logNetwork(
        "[GroupSocket][EVENT:RECEIVE] 🔔 Incoming socket data: ${data.toString()}",
      );

      final backendId = data['_id']?.toString();
      if (backendId == null || backendId.isEmpty) {
        _logger.logNetwork("[GroupSocket][EVENT:RECEIVE][SKIP] ⚠️ Missing _id in payload");
        return;
      }

      try {
        final message = GroupMessageModel.fromMap(data);

        // ✅ Prevent duplicates by backend ID
        if (_groupMessages.any((m) => m.id == message.id)) {
          _logger.logNetwork(
            "[GroupSocket][MESSAGE:DUPLICATE] ⛔ Duplicate ignored → ${message.id}",
          );
          return;
        }

        _groupMessages.add(message);
        await _localStorage.addGroupMessage(message.groupId, message);
        _logger.logNetwork("[GroupSocket][MESSAGE:STORE] 💾 Stored → ${message.id}");

        // ✅ Notify only if not sent by current user
        final currentUserData = await SecureStorageService().getUserData();
        final currentUserId = currentUserData?['employeeId'] ?? "";

        if (message.sender != currentUserId) {
          // Unread counter + notification logic
          if (message.groupId != _activeGroupId) {
            _groupUnreadCounts[message.groupId] = (_groupUnreadCounts[message.groupId] ?? 0) + 1;

            _logger.logNetwork(
              "[GroupSocket][UNREAD] 📈 Group ${message.groupId} count=${_groupUnreadCounts[message.groupId]}",
            );

            final group = _groupChats.firstWhere(
              (g) => g.groupId == message.groupId,
              orElse: () => GroupChatModel(
                groupId: message.groupId,
                name: "Unknown Group",
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

            _logger.logNetwork(
              "[GroupSocket][NOTIFICATION] 🔔 Notification shown for ${group.name} | sender=${message.senderName}",
            );
          } else {
            _logger.logNetwork(
              "[GroupSocket][ACTIVE_CHAT] 💬 Message added to active chat UI: ${message.text}",
            );
          }
        }

        notifyListeners();
      } catch (e, st) {
        _logger.error("GroupSocket", "❌ Failed to parse group message", error: e, stackTrace: st);
      }
    });

    _manager.registerGroupEvent('groupMessageStatusUpdate', (data) async {
      _logger.logNetwork("[GroupSocket] Group message status updated: ${data['messageId']}");
      final index = _groupMessages.indexWhere((m) => m.messageId == data['messageId']);
      if (index != -1) {
        if (data['status'] == 'read') {
          _groupMessages[index] = _groupMessages[index].copyWith(read: true);
        } else if (data['status'] == 'delivered') {
          _groupMessages[index] = _groupMessages[index].copyWith(delivered: true);
        }
        await _localStorage.updateGroupMessage(
          _groupMessages[index].groupId,
          _groupMessages[index],
        );
        notifyListeners();
      }
    });

    _manager.registerGroupEvent('groupMessageDeleted', (data) async {
      _logger.logNetwork("[GroupSocket] Group message deleted: ${data['messageId']}");
      final index = _groupMessages.indexWhere((m) => m.messageId == data['messageId']);
      if (index != -1) {
        _groupMessages[index] = _groupMessages[index].copyWith(isDeleted: true);
        await _localStorage.updateGroupMessage(
          _groupMessages[index].groupId,
          _groupMessages[index],
        );
        notifyListeners();
      }
    });

    _manager.registerGroupEvent('groupChatCleared', (data) async {
      _logger.logNetwork("[GroupSocket] Group chat cleared: ${data['groupId']}");
      _groupMessages.removeWhere((m) => m.groupId == data['groupId']);
      await _localStorage.clearGroupMessages(data['groupId']);
      notifyListeners();
    });

    _manager.registerGroupEvent('groupUserTyping', (data) {
      _logger.logNetwork("[GroupSocket] User typing in group: ${data['userId']}");
      _groupTypingIndicators['${data['groupId']}_${data['userId']}'] = data['isTyping'];
      notifyListeners();
    });

    // --- groupNameChanged event ---
    _manager.registerGroupEvent('groupNameChanged', (data) async {
      _logger.logNetwork("[GroupSocket] 📝 Group name changed event: $data");

      final groupId = data['groupId'];
      final newName = data['newName'];

      final index = _groupChats.indexWhere((g) => g.groupId == groupId);
      if (index != -1) {
        _groupChats[index] = _groupChats[index].copyWith(name: newName);
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
    });

    // --- groupMembersAdded event ---
    _manager.registerGroupEvent('groupMembersAdded', (data) async {
      _logger.logNetwork("[GroupSocket] ➕ Members added event: $data");

      final groupId = data['groupId'];
      final updatedGroup = data['updatedGroup'];
      final index = _groupChats.indexWhere((g) => g.groupId == groupId);

      if (index != -1 && updatedGroup != null) {
        _groupChats[index] = GroupChatModel.fromMap(updatedGroup);
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
    });

    // --- addedToGroup event ---
    _manager.registerGroupEvent('addedToGroup', (data) async {
      _logger.logNetwork("[GroupSocket] 🆕 Added to new group event: $data");
      final groupData = data['group'];
      if (groupData != null) {
        final newGroup = GroupChatModel.fromMap(groupData);
        _groupChats.add(newGroup);
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
    });

    // --- groupMemberRemoved event ---
    _manager.registerGroupEvent('groupMemberRemoved', (data) async {
      _logger.logNetwork("[GroupSocket] 🚫 Member removed event: $data");
      final groupId = data['groupId'];
      final updatedGroup = data['updatedGroup'];

      final index = _groupChats.indexWhere((g) => g.groupId == groupId);
      if (index != -1 && updatedGroup != null) {
        _groupChats[index] = GroupChatModel.fromMap(updatedGroup);
        await _localStorage.saveGroupChats(_groupChats);
        notifyListeners();
      }
    });

    // --- removedFromGroup event ---
    _manager.registerGroupEvent('removedFromGroup', (data) async {
      _logger.logNetwork("[GroupSocket] ⚠️ You were removed from group: $data");

      final groupId = data['groupId'];
      _groupChats.removeWhere((g) => g.groupId == groupId);
      await _localStorage.saveGroupChats(_groupChats);
      notifyListeners();
    });

    // --- groupDeleted event ---
    _manager.registerGroupEvent('groupDeleted', (data) async {
      _logger.logNetwork("[GroupSocket] 🗑️ Group deleted event: $data");

      final groupId = data['groupId'];
      _groupChats.removeWhere((g) => g.groupId == groupId);
      await _localStorage.saveGroupChats(_groupChats);
      notifyListeners();
    });

    _logger.logNetwork("GroupSocketProvider initialized");
  }

  //  Fetch groups for logged-in user
  Future<void> fetchUserGroups() async {
    final userId = await _secureStorage.getEmployeeId();
    _logger.logNetwork("🔄 Fetching groups list for user id: $userId");

    try {
      // ✅ Just trigger request — no need to parse response here
      await _manager.getUserGroups(userId ?? "");
    } catch (e, st) {
      _logger.error("GroupSocket", "❌ Failed to fetch user groups", error: e, stackTrace: st);
    }
  }

  // Create a group
  Future<void> createGroup({
    required String name,
    required String createdBy,
    required List<String> members,
    String? description,
    String? icon,
  }) async {
    try {
      await _manager.createGroup(
        name: name,
        createdBy: createdBy,
        members: members,
        description: description,
        icon: icon,
      );
    } catch (e) {
      _logger.error("GroupSocket", "Failed to create group", error: e);
      rethrow;
    }
  }

  // Send a group message
  Future<void> sendGroupMessage({
    required String groupId,
    required String sender,
    required String senderName,
    required String text,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
    List<String>? mentions,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _manager.sendGroupMessage(
        groupId: groupId,
        sender: sender,
        senderName: senderName,
        text: text,
        messageType: messageType,
        fileName: fileName,
        fileUrl: fileUrl,
        replyTo: replyTo,
        mentions: mentions,
        timestamp: timestamp,
      );

      _logger.logNetwork(
        "[GroupSocket][SEND_SUCCESS] ✅ Sent group message → group=$groupId, type=$messageType",
      );
    } catch (e) {
      _logger.error("GroupSocket", "❌ Failed to send group message", error: e);
      rethrow;
    }
  }

  // Mark group message as read
  Future<void> markGroupMessageAsRead({required String messageId, required String userId}) async {
    // Skip if the messageId is a timestamp (not a valid ObjectId)
    if (messageId.length == 13 || int.tryParse(messageId) != null) {
      _logger.logNetwork("[Socket] ⚠️ Skipping non-message ID: $messageId");
      return;
    }

    try {
      await _manager.markGroupMessageAsRead(messageId: messageId, userId: userId);
    } catch (e) {
      _logger.error("GroupSocket", "Failed to mark group message as read", error: e);
      rethrow;
    }
  }

  // Delete a group message
  Future<void> deleteGroupMessage({
    required String messageId,
    required String userId,
    required String groupId,
  }) async {
    try {
      await _manager.deleteGroupMessage(messageId: messageId, userId: userId, groupId: groupId);
    } catch (e) {
      _logger.error("GroupSocket", "Failed to delete group message", error: e);
      rethrow;
    }
  }

  // Clear a group chat
  Future<void> clearGroupChat({required String groupId, required String userId}) async {
    try {
      await _manager.clearGroupChat(groupId: groupId, userId: userId);
    } catch (e) {
      _logger.error("GroupSocket", "Failed to clear group chat", error: e);
      rethrow;
    }
  }

  // Send group typing status
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

  // Load group messages
  Future<void> loadGroupMessages(String groupId) async {
    _groupMessages = await _localStorage.getGroupMessages(groupId);
    notifyListeners();
  }

  // Get messages for a specific group
  List<GroupMessageModel> getGroupMessages(String groupId) {
    return _groupMessages.where((m) => m.groupId == groupId).toList();
  }

  // Reset unread count for a group
  void resetGroupUnreadCount(String groupId, {bool notify = true}) {
    if (_groupUnreadCounts.containsKey(groupId)) {
      _groupUnreadCounts.remove(groupId);
      if (notify) notifyListeners();
    }
  }

  Future<void> editGroupName(String groupId, String newName, String userId) async {
    try {
      _logger.logNetwork("[GroupSocket] ✏️ Editing group name → $groupId to '$newName'");
      await _manager.editGroupName(groupId: groupId, newName: newName, userId: userId);
      _logger.logNetwork("[GroupSocket] ✅ Group name updated successfully");
    } catch (e, st) {
      _logger.error("GroupSocket", "❌ Failed to edit group name", error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> addGroupMembers(String groupId, List<String> newMembers, String addedBy) async {
    try {
      _logger.logNetwork("[GroupSocket] ➕ Adding ${newMembers.length} members to group $groupId");
      await _manager.addGroupMembers(groupId: groupId, newMembers: newMembers, addedBy: addedBy);
      _logger.logNetwork("[GroupSocket] ✅ Members added successfully");
    } catch (e, st) {
      _logger.error("GroupSocket", "❌ Failed to add members to group", error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> removeGroupMember(String groupId, String userToRemove, String removedBy) async {
    try {
      _logger.logNetwork("[GroupSocket] 🚫 Removing member $userToRemove from group $groupId");
      await _manager.removeGroupMember(
        groupId: groupId,
        userToRemove: userToRemove,
        removedBy: removedBy,
      );
      _logger.logNetwork("[GroupSocket] ✅ Member removed successfully");
    } catch (e, st) {
      _logger.error("GroupSocket", "❌ Failed to remove group member", error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteGroup({required String groupId, required String deletedBy}) async {
    try {
      _logger.logNetwork("[GroupSocket] 🗑️ Deleting group → $groupId");
      await _manager.deleteGroup(groupId: groupId, deletedBy: deletedBy);
      _logger.logNetwork("[GroupSocket] ✅ Group deleted successfully");
    } catch (e, st) {
      _logger.error("GroupSocket", "❌ Failed to delete group", error: e, stackTrace: st);
      rethrow;
    }
  }

  // Dispose provider
  void disposeProvider() {
    _manager.unregisterGroupEvent('userGroups');
    _manager.unregisterGroupEvent('groupCreated');
    _manager.unregisterGroupEvent('groupDeleted');
    _manager.unregisterGroupEvent('receiveGroupMessage');
    _manager.unregisterGroupEvent('groupMessageStatusUpdate');
    _manager.unregisterGroupEvent('groupMessageDeleted');
    _manager.unregisterGroupEvent('groupChatCleared');
    _manager.unregisterGroupEvent('groupUserTyping');
    _logger.logNetwork("GroupSocketProvider disposed");
  }
}
