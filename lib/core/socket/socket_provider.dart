import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:uuid/uuid.dart';
import 'socket_manager.dart';

/// Provider class to manage socket state and notify listeners.
/// Uses ChangeNotifier to update UI on socket events.
class SocketProvider extends ChangeNotifier {
  final SocketManager _manager = SocketManager.instance;

  /// List of online users
  List<String> _onlineUsers = [];

  /// List of messages (now using ChatMessageModel)
  final List<ChatMessageModel> _messages = [];

  /// Typing indicators (userId -> isTyping)
  final Map<String, bool> _typingIndicators = {};

  /// Getters
  List<String> get onlineUsers => _onlineUsers;
  List<ChatMessageModel> get messages => _messages;
  Map<String, bool> get typingIndicators => _typingIndicators;

  /// Initializes socket event listeners.
  void init() {
    _manager.registerEvent('onlineUsers', (data) {
      _onlineUsers = List<String>.from(data);
      notifyListeners();
      LoggingService.instance.logNetwork("Online users updated: $_onlineUsers");
    });

    _manager.registerEvent('receiveMessage', (data) {
      _messages.add(ChatMessageModel.fromBackendMap(data));
      notifyListeners();
      LoggingService.instance.logNetwork("New message received: ${data['_id']}");
    });

    _manager.registerEvent('messageStatusUpdate', (data) {
      final messageId = data['messageId'];
      final status = data['status'];
      final index = _messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        if (status == 'read') {
          _messages[index] = _messages[index].copyWith(read: true);
        } else if (status == 'delivered') {
          _messages[index] = _messages[index].copyWith(delivered: true);
        }
        notifyListeners();
      }
      LoggingService.instance.logNetwork("Message status updated: $messageId -> $status");
    });

    _manager.registerEvent('messageDeleted', (data) {
      _messages.removeWhere((m) => m.messageId == data['messageId']);
      notifyListeners();
      LoggingService.instance.logNetwork("Message deleted: ${data['messageId']}");
    });

    _manager.registerEvent('conversationCleared', (data) {
      _messages.removeWhere((m) => m.conversationId == data['conversationId']);
      notifyListeners();
      LoggingService.instance.logNetwork("Conversation cleared: ${data['conversationId']}");
    });

    _manager.registerEvent('userTyping', (data) {
      _typingIndicators[data['userId']] = data['isTyping'];
      notifyListeners();
      LoggingService.instance.logNetwork("Typing status: ${data['userId']} -> ${data['isTyping']}");
    });

    LoggingService.instance.logNetwork("SocketProvider initialized");
  }

  /// Joins the user's room.
  Future<void> joinUser(String userId, String name) async {
    await _manager.join(userId, name);
  }

  /// Leaves the user's room.
  Future<void> leaveUser() async {
    await _manager.leave();
  }

  /// Sends a message to a receiver.
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
    // Generate message ID if not provided
    final messageId = Uuid().v4();

    // Create the message object
    final message = ChatMessageModel(
      message: text,
      sender: sender,
      timestamp: DateTime.now(),
      messageType: messageType,
      fileUrl: fileUrl,
      fileName: fileName,
      messageId: messageId,
      conversationId: conversationId,
      replyTo: replyTo,
    );

    // Add to local messages immediately
    _messages.add(message);
    notifyListeners();

    // Send through socket
    await _manager.sendMessage(
      sender: sender,
      senderName: senderName,
      receiver: receiver,
      text: text,
      conversationId: conversationId,
      messageType: messageType,
      fileName: fileName,
      fileUrl: fileUrl,
      replyTo: replyTo,
    );
  }

  /// Sends typing status to a target user.
  void sendTypingStatus({
    required String userId,
    required String targetUserId,
    required bool isTyping,
  }) {
    _manager.sendTypingStatus(userId: userId, targetUserId: targetUserId, isTyping: isTyping);
  }

  /// Marks a message as read.
  Future<void> markMessageAsRead({required String messageId, required String userId}) async {
    await _manager.markMessageAsRead(messageId: messageId, userId: userId);

    // Update local message status
    final index = _messages.indexWhere((m) => m.messageId == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(read: true);
      notifyListeners();
    }
  }

  /// Marks a conversation as read.
  Future<void> markConversationAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    await _manager.markConversationAsRead(senderId: senderId, receiverId: receiverId);

    // Update all unread messages in this conversation
    final conversationId = [senderId, receiverId].join('_');
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].conversationId == conversationId && !_messages[i].read!) {
        _messages[i] = _messages[i].copyWith(read: true);
      }
    }
    notifyListeners();
  }

  /// Deletes a message.
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
    String? conversationId,
  }) async {
    await _manager.deleteMessage(
      messageId: messageId,
      userId: userId,
      conversationId: conversationId,
    );

    // Remove from local messages
    _messages.removeWhere((m) => m.messageId == messageId);
    notifyListeners();
  }

  /// Clears a conversation.
  Future<void> clearConversation({
    required String senderId,
    required String receiverId,
    required String userId,
  }) async {
    await _manager.clearConversation(senderId: senderId, receiverId: receiverId, userId: userId);

    // Remove all messages in this conversation
    final conversationId = [senderId, receiverId].join('_');
    _messages.removeWhere((m) => m.conversationId == conversationId);
    notifyListeners();
  }

  /// Deletes multiple messages.
  Future<void> deleteMultipleMessages({
    required List<String> messageIds,
    required String userId,
    String? conversationId,
  }) async {
    await _manager.deleteMultipleMessages(
      messageIds: messageIds,
      userId: userId,
      conversationId: conversationId,
    );

    // Remove deleted messages from local list
    _messages.removeWhere((m) => messageIds.contains(m.messageId));
    notifyListeners();
  }

  /// Disposes all event listeners.
  void disposeProvider() {
    _manager.unregisterEvent('onlineUsers');
    _manager.unregisterEvent('receiveMessage');
    _manager.unregisterEvent('messageStatusUpdate');
    _manager.unregisterEvent('messageDeleted');
    _manager.unregisterEvent('conversationCleared');
    _manager.unregisterEvent('userTyping');
    LoggingService.instance.logNetwork("SocketProvider disposed");
  }
}
