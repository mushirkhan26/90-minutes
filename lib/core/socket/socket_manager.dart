import 'dart:async';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'socket_service.dart';

class SocketManager {
  static final SocketManager instance = SocketManager._internal();
  SocketManager._internal();

  final socket = SocketService.instance.socket;
  bool _hasJoined = false;

  /// Join user room with employeeId and username
  Future<void> join(String userId, String username) async {
    if (_hasJoined) return;

    // Ensure socket is connected
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.warning("", 'Socket not connected yet. Initializing...');
      SocketService.instance.init();
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !SocketService.instance.isConnected;
      });
    }

    // Use emitWithAck with a resilient ack callback
    socket.emitWithAck(
      'join',
      {'userId': userId, 'name': username, "source": "app"},
      ack: ([dynamic res]) {
        // Make the argument optional
        LoggingService.instance.logNetwork('Join response: $res');
      },
    );

    _hasJoined = true;

    // Automatically rejoin on reconnect
    socket.onReconnect((attempt) {
      if (_hasJoined) {
        LoggingService.instance.info(
          "[SocketManager]",
          "Socket reconnected, rejoining user $userId...",
        );
        socket.emit('join', {'userId': userId, 'name': username});
      }
    });
  }

  /// Leave user room on logout
  Future<void> leave() async {
    if (SocketService.instance.isConnected) {
      // No need to emit 'leave'; backend handles disconnect
      socket.disconnect();
      _hasJoined = false;
      LoggingService.instance.logNetwork(
        'Socket disconnected, user left room (backend handles cleanup)',
      );
    }
  }

  /// Sends a message to a receiver.
  /// Emits 'sendMessage' event to backend.
  /// Sends a message to a receiver.
  /// Emits 'sendMessage' event to backend.
  Future<void> sendMessage({
    required String sender,
    required String senderName,
    required String receiver,
    required String text,
    required String messageId, // Added messageId parameter
    String? conversationId,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.warning("Socket", "socket disconnected, waiting to reconnect...");
      await SocketService.instance.waitForConnection();
      LoggingService.instance.logNetwork("Socket reconnected, proceeding to send message.");
    }

    socket.emitWithAck(
      'sendMessage',
      {
        'sender': sender,
        'senderName': senderName,
        'receiver': receiver,
        'text': text,
        'messageId': messageId, // Include messageId in payload
        'conversationId': conversationId,
        'messageType': messageType,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'replyTo': replyTo,
      },
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Message sent Full Ack Response: $res| Type : ${res.runtimeType}");
      },
    );
  }

  /// Sends typing status to a target user.
  /// Emits 'typing' event to backend.
  void sendTypingStatus({
    required String userId,
    required String targetUserId,
    required bool isTyping,
  }) {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot send typing status: socket not connected");
      return;
    }
    socket.emit('typing', {'userId': userId, 'targetUserId': targetUserId, 'isTyping': isTyping});
  }

  /// Marks a message as read.
  /// Emits 'messageRead' event to backend.
  Future<void> markMessageAsRead({required String messageId, required String userId}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot mark message as read: socket not connected");
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'messageRead',
      {'messageId': messageId, 'userId': userId},
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Message marked as read. Ack: $res");
      },
    );
  }

  /// Marks an entire conversation as read.
  /// Emits 'markConversationAsRead' event to backend.
  Future<void> markConversationAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error(
        "Socket",
        "Cannot mark conversation as read: socket not connected",
      );
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'markConversationAsRead',
      {'senderId': senderId, 'receiverId': receiverId},
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Conversation marked as read. Ack: $res");
      },
    );
  }

  /// Deletes a single message.
  /// Emits 'deleteMessage' event to backend.
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
    String? conversationId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot delete message: socket not connected");
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'deleteMessage',
      {'messageId': messageId, 'userId': userId, 'conversationId': conversationId},
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Message deleted. Ack: $res");
      },
    );
  }

  /// Clears an entire conversation.
  /// Emits 'clearConversation' event to backend.
  Future<void> clearConversation({
    required String senderId,
    required String receiverId,
    required String userId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot clear conversation: socket not connected");
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'clearConversation',
      {'senderId': senderId, 'receiverId': receiverId, 'userId': userId},
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Conversation cleared. Ack: $res");
      },
    );
  }

  /// Deletes multiple messages at once.
  /// Emits 'deleteMultipleMessages' event to backend.
  Future<void> deleteMultipleMessages({
    required List<String> messageIds,
    required String userId,
    String? conversationId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error(
        "Socket",
        "Cannot delete multiple messages: socket not connected",
      );
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'deleteMultipleMessages',
      {'messageIds': messageIds, 'userId': userId, 'conversationId': conversationId},
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork("Multiple messages deleted. Ack: $res");
      },
    );
  }

  /// Listen for backend events
  /// Registers a callback for a socket event.
  void registerEvent(String eventName, Function(dynamic data) callback) {
    socket.on(eventName, callback);
    LoggingService.instance.logNetwork('Registered socket event: $eventName');
  }

  /// Unregisters a callback for a socket event.
  void unregisterEvent(String eventName) {
    socket.off(eventName);
    LoggingService.instance.logNetwork('Unregistered socket event: $eventName');
  }
  //============================================================================
  // group functionality related sockets events
  //============================================================================

  /// Joins a group room
  Future<void> joinGroup({required String groupId, required String userId}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot join group: socket not connected");
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'joinGroup',
      {'groupId': groupId, 'userId': userId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to join group: $res");
          throw Exception(res);
        }
        LoggingService.instance.logNetwork("Joined group: $groupId");
      },
    );
  }

  /// Leaves a group room
  Future<void> leaveGroup({required String groupId, required String userId}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot leave group: socket not connected");
      throw Exception("Socket not connected");
    }
    socket.emitWithAck(
      'leaveGroup',
      {'groupId': groupId, 'userId': userId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to leave group: $res");
          throw Exception(res);
        }
        LoggingService.instance.logNetwork("Left group: $groupId");
      },
    );
  }

  // get user groups
  Future<void> getUserGroups(String userId) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot fetch user groups: socket not connected");
      throw Exception("Socket not connected");
    }

    try {
      socket.emitWithAck(
        'getUserGroups',
        {'userId': userId},
        ack: ([dynamic res]) {
          LoggingService.instance.info("Socket", "Ack received for getUserGroups: $res");
        },
      );
    } catch (e, st) {
      LoggingService.instance.error(
        "Socket",
        "Exception during emitWithAck",
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Creates a new group
  /// 🚀 Emits a createGroup event — handled by `groupCreated` listener
  Future<void> createGroup({
    required String name,
    required String createdBy,
    required List<String> members,
    String? description,
    String? icon,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "❌ Cannot create group: socket not connected");
      throw Exception("Socket not connected");
    }

    try {
      socket.emit('createGroup', {
        'name': name,
        'createdBy': createdBy,
        'members': members,
        if (description != null) 'description': description,
        if (icon != null) 'icon': icon,
      });

      LoggingService.instance.logNetwork("[SocketManager] 📤 createGroup event emitted");
    } catch (e, st) {
      LoggingService.instance.error(
        "SocketManager",
        "⚠️ Failed to emit createGroup event",
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Sends a group message
  /// Sends a group message to backend via socket
  Future<void> sendGroupMessage({
    required String groupId,
    required String sender,
    required String senderName,
    required String text,
    required String messageId, // ✅ Added messageId
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
    List<String>? mentions,
    required int timestamp, // ✅ backend expects timestamp
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "❌ Cannot send group message: socket not connected");
      await SocketService.instance.waitForConnection();
    }

    final payload = {
      'groupId': groupId,
      'sender': sender,
      'senderName': senderName,
      'text': text,
      'messageId': messageId, // ✅ Include messageId
      'messageType': messageType,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'replyTo': replyTo,
      'mentions': mentions ?? [],
      'timestamp': timestamp,
    };

    LoggingService.instance.logNetwork(
      "[SOCKET][SEND_GROUP] 🚀 Emitting sendGroupMessage → $payload",
    );

    socket.emitWithAck(
      'sendGroupMessage',
      payload,
      ack: ([dynamic res]) {
        LoggingService.instance.logNetwork(
          "[SOCKET][SEND_GROUP_ACK] ✅ Group message emit acknowledged: $res",
        );
      },
    );
  }

  /// Marks a group message as read
  Future<void> markGroupMessageAsRead({required String messageId, required String userId}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error(
        "Socket",
        "Cannot mark group message as read: socket not connected",
      );
      return;
    }
    socket.emitWithAck(
      'groupMessageRead',
      {'messageId': messageId, 'userId': userId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to mark group message as read: $res");
          return;
        }
        LoggingService.instance.logNetwork("Group message marked as read: $messageId");
      },
    );
  }

  /// Deletes a group message
  Future<void> deleteGroupMessage({
    required String messageId,
    required String userId,
    required String groupId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot delete group message: socket not connected");
      return;
    }
    socket.emitWithAck(
      'deleteGroupMessage',
      {'messageId': messageId, 'userId': userId, 'groupId': groupId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to delete group message: $res");
          return;
        }
        LoggingService.instance.logNetwork("Group message deleted: $messageId");
      },
    );
  }

  /// Clears a group chat
  Future<void> clearGroupChat({required String groupId, required String userId}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot clear group chat: socket not connected");
      return;
    }
    socket.emitWithAck(
      'clearGroupChat',
      {'groupId': groupId, 'userId': userId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to clear group chat: $res");
          return;
        }
        LoggingService.instance.logNetwork("Group chat cleared: $groupId");
      },
    );
  }

  /// Sends group typing status
  void sendGroupTypingStatus({
    required String userId,
    required String userName,
    required String groupId,
    required bool isTyping,
  }) {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error(
        "Socket",
        "Cannot send group typing status: socket not connected",
      );
      return;
    }
    socket.emit('groupTyping', {
      'userId': userId,
      'userName': userName,
      'groupId': groupId,
      'isTyping': isTyping,
    });
  }

  //============================================================================
  // Group Management Operations
  //============================================================================

  /// Edit group name
  Future<void> editGroupName({
    required String groupId,
    required String newName,
    required String userId,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot edit group name: socket not connected");
      return;
    }

    socket.emitWithAck(
      'editGroupName',
      {'groupId': groupId, 'newName': newName, 'userId': userId},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to edit group name: $res");
          return;
        }
        LoggingService.instance.logNetwork("Group name edited: $groupId → $newName");
      },
    );
  }

  /// Add members to group
  Future<void> addGroupMembers({
    required String groupId,
    required List<String> newMembers,
    required String addedBy,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot add members: socket not connected");
      return;
    }

    socket.emitWithAck(
      'addGroupMembers',
      {'groupId': groupId, 'newMembers': newMembers, 'addedBy': addedBy},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to add members: $res");
          return;
        }
        LoggingService.instance.logNetwork("Members added to group: $groupId");
      },
    );
  }

  /// Remove a member from group
  Future<void> removeGroupMember({
    required String groupId,
    required String userToRemove,
    required String removedBy,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot remove member: socket not connected");
      return;
    }

    socket.emitWithAck(
      'removeGroupMember',
      {'groupId': groupId, 'userToRemove': userToRemove, 'removedBy': removedBy},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to remove member: $res");
          return;
        }
        LoggingService.instance.logNetwork("Member removed from group: $groupId");
      },
    );
  }

  /// Delete a group
  Future<void> deleteGroup({required String groupId, required String deletedBy}) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot delete group: socket not connected");
      return;
    }

    socket.emitWithAck(
      'deleteGroup',
      {'groupId': groupId, 'deletedBy': deletedBy},
      ack: ([dynamic res]) {
        if (res is String) {
          LoggingService.instance.error("Socket", "Failed to delete group: $res");
          return;
        }
        LoggingService.instance.logNetwork("Group deleted: $groupId");
      },
    );
  }

  /// Registers a callback for a group socket event
  void registerGroupEvent(String eventName, Function(dynamic data) callback) {
    socket.on(eventName, callback);
    LoggingService.instance.logNetwork('Registered group socket event: $eventName');
  }

  /// Unregisters a callback for a group socket event
  void unregisterGroupEvent(String eventName) {
    socket.off(eventName);
    LoggingService.instance.logNetwork('Unregistered group socket event: $eventName');
  }
  /// Make a member as group admin
Future<void> makeGroupAdmin({
  required String groupId,
  required String userId,
  required String updatedBy,
}) async {
  if (!SocketService.instance.isConnected) {
    LoggingService.instance.error("Socket", "Cannot make admin: socket not connected");
    return;
  }

  socket.emitWithAck(
    'makeGroupAdmin',
    {
      'groupId': groupId,
      'userId': userId,
      'madeBy': updatedBy,
    },
    ack: ([dynamic res]) {
      if (res is String) {
        LoggingService.instance.error("Socket", "Failed to make admin: $res");
        return;
      }
      LoggingService.instance.logNetwork("Admin added in group: $groupId → $userId");
    },
  );
}
/// Remove admin role from a member
Future<void> removeGroupAdmin({
  required String groupId,
  required String userId,
  required String updatedBy,
}) async {
  if (!SocketService.instance.isConnected) {
    LoggingService.instance.error("Socket", "Cannot remove admin: socket not connected");
    return;
  }

  socket.emitWithAck(
    'removeGroupAdmin',
    {
      'groupId': groupId,
      'userId': userId,
      'removedBy': updatedBy,
    },
    ack: ([dynamic res]) {
      if (res is String) {
        LoggingService.instance.error("Socket", "Failed to remove admin: $res");
        return;
      }
      LoggingService.instance.logNetwork("Admin removed in group: $groupId → $userId");
    },
  );
}

/// Enable / Disable Admin Only Messaging
Future<void> toggleAdminOnlyMessaging({
  required String groupId,
  required bool enabled,
  required String userId,
}) async {
  if (!SocketService.instance.isConnected) {
    LoggingService.instance.error("Socket", "Cannot toggle adminOnlyMessaging: socket not connected");
    return;
  }

  socket.emitWithAck(
    'toggleAdminOnlyMessaging',
    {
      'groupId': groupId,
      'userId' : userId,
      'enabled' : enabled,
    },
    ack: ([dynamic res]) {
      if (res is String) {
        LoggingService.instance.error("Socket", "Failed to update adminOnlyMessaging: $res");
        return;
      }
      LoggingService.instance.logNetwork(
          "AdminOnlyMessaging updated: $groupId → $enabled");
    },
  );
}
Future<void> updateGroupProfileImage({
  required String groupId,
  required String imageUrl,
  required String updatedBy,
}) async {

  socket.emitWithAck(
    'updateGroupProfileImage',
    {
      'groupId': groupId,
      'imageUrl': imageUrl,
      'updatedBy': updatedBy,
    },
    ack: (res) {
      LoggingService.instance.logNetwork(
        "Group profile updated: $groupId",
      );
    },
  );
}
Future<void> updateGroupIcon({
  required String groupId,
  required String icon,
  required String updatedBy,
}) async {

  socket.emitWithAck(
    'updateGroupIcon',
    {
      'groupId': groupId,
      'icon': icon,
      'updatedBy': updatedBy,
    },
    ack: (res) {
      LoggingService.instance.logNetwork(
          "Group icon updated: $groupId");
    },
  );
}
  
}
