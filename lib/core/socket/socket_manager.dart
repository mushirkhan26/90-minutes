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
      {'userId': userId, 'name': username},
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
  Future<void> sendMessage({
    required String sender,
    required String senderName,
    required String receiver,
    required String text,
    String? conversationId,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
  }) async {
    if (!SocketService.instance.isConnected) {
      LoggingService.instance.error("Socket", "Cannot send message: socket not connected");
      throw Exception("Socket not connected");
    }

    socket.emit(
      'sendMessage',
      {
        'sender': sender,
        'senderName': senderName,
        'receiver': receiver,
        'text': text,
        'conversationId': conversationId,
        'messageType': messageType,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'replyTo': replyTo,
      },
      // ack: ([dynamic res]) {
      //   LoggingService.instance.logNetwork("Message sent. Ack: $res");
      // },
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
}
