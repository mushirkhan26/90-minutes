import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'socket_manager.dart';

/// Provider class to manage socket state and notify listeners.
/// Uses ChangeNotifier to update UI on socket events.

class SocketProvider extends ChangeNotifier {
  final SocketManager _manager = SocketManager.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  /// List of online users
  List<String> _onlineUsers = [];

  /// List of messages (now using ChatMessageModel)
  final List<ChatMessageModel> _messages = [];

  /// Typing indicators (userId -> isTyping)
  final Map<String, bool> _typingIndicators = {};

  /// Getters
  List<String> get onlineUsers => List.unmodifiable(_onlineUsers);
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  Map<String, bool> get typingIndicators => Map.unmodifiable(_typingIndicators);

  // Add a method to update a specific message
  void _updateMessage(ChatMessageModel updatedMessage) {
    final index = _messages.indexWhere((m) => m.messageId == updatedMessage.messageId);
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
  }

  /// Initializes socket event listeners.
  void init() {
    _manager.registerEvent('onlineUsers', (data) {
      _onlineUsers = List<String>.from(data);
      notifyListeners();
      _logger.logNetwork("Online users updated: $_onlineUsers");
    });

    _manager.registerEvent('receiveMessage', (data) async {
      final message = ChatMessageModel.fromBackendMap(data);
      _messages.add(message);

      // Save to local storage if conversationId is available
      if (message.conversationId != null) {
        final existingMessages = await _localStorage.getChatMessages(message.conversationId!);
        existingMessages.add(message);
        await _localStorage.saveChatMessages(message.conversationId!, existingMessages);
      }

      notifyListeners();
      _logger.logNetwork("New message received: ${message.messageId}");
    });

    _manager.registerEvent('messageStatusUpdate', (data) async {
      final messageId = data['messageId'];
      final status = data['status'];
      final index = _messages.indexWhere((m) => m.messageId == messageId);

      if (index != -1) {
        ChatMessageModel updatedMessage;
        if (status == 'read') {
          updatedMessage = _messages[index].copyWith(read: true);
        } else if (status == 'delivered') {
          updatedMessage = _messages[index].copyWith(delivered: true);
        } else {
          return;
        }

        _updateMessage(updatedMessage);

        // Update in local storage if conversationId is available
        if (updatedMessage.conversationId != null) {
          await _localStorage.updateChatMessage(updatedMessage.conversationId!, updatedMessage);
        }

        notifyListeners();
        _logger.logNetwork("Message status updated: $messageId -> $status");
      }
    });

    _manager.registerEvent('messageDeleted', (data) async {
      final messageId = data['messageId'];
      final conversationId = data['conversationId'];

      // Mark as deleted instead of removing
      final index = _messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        final updatedMessage = _messages[index].copyWith(
          isDeleted: true,
          message: "This message is deleted",
          fileUrl: null,
        );
        _updateMessage(updatedMessage);

        // Update in local storage if conversationId is available
        if (conversationId != null) {
          await _localStorage.updateChatMessage(conversationId, updatedMessage);
        }
      }

      notifyListeners();
      _logger.logNetwork("Message deleted: $messageId");
    });

    _manager.registerEvent('conversationCleared', (data) async {
      final conversationId = data['conversationId'];
      _messages.removeWhere((m) => m.conversationId == conversationId);

      // Clear from local storage if conversationId is available
      if (conversationId != null) {
        await _localStorage.clearConversationMessages(conversationId);
      }

      notifyListeners();
      _logger.logNetwork("Conversation cleared: $conversationId");
    });

    _manager.registerEvent('userTyping', (data) {
      _typingIndicators[data['userId']] = data['isTyping'];
      notifyListeners();
      _logger.logNetwork("Typing status: ${data['userId']} -> ${data['isTyping']}");
    });

    _logger.logNetwork("SocketProvider initialized");
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
    required String messageId, // Now required from frontend
    String? conversationId,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
  }) async {
    final timestamp = DateTime.now();

    // Create the message object with frontend-generated ID
    final message = ChatMessageModel(
      message: text,
      sender: sender,
      timestamp: timestamp,
      messageType: messageType,
      fileUrl: fileUrl,
      fileName: fileName,
      messageId: messageId,
      conversationId: conversationId,
      replyTo: replyTo,
      read: false,
      delivered: false,
      isDeleted: false,
    );

    // Add to local messages immediately
    _messages.add(message);
    notifyListeners();

    // Save to local storage if conversationId is available
    if (conversationId != null) {
      final existingMessages = await _localStorage.getChatMessages(conversationId);
      existingMessages.add(message);
      await _localStorage.saveChatMessages(conversationId, existingMessages);
    }

    // Send through socket
    await _manager.sendMessage(
      sender: sender,
      senderName: senderName,
      receiver: receiver,
      text: text,
      messageId: messageId, // Pass the frontend-generated ID
      conversationId: conversationId,
      messageType: messageType,
      fileName: fileName,
      fileUrl: fileUrl,
      replyTo: replyTo,
    );
  }

  /// Marks a message as deleted (instead of actually deleting)
  Future<void> markMessageAsDeleted({
    required String messageId,
    required String userId,
    String? conversationId,
  }) async {
    // Find the message and update it
    final index = _messages.indexWhere((m) => m.messageId == messageId);
    if (index != -1) {
      final updatedMessage = _messages[index].copyWith(
        isDeleted: true,
        message: "This message is deleted",
        fileUrl: null,
      );
      _updateMessage(updatedMessage);

      // Update in local storage if conversationId is available
      if (conversationId != null) {
        await _localStorage.updateChatMessage(conversationId, updatedMessage);
      }

      notifyListeners();
    }

    // Send delete request to server
    await _manager.deleteMessage(
      messageId: messageId,
      userId: userId,
      conversationId: conversationId,
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

      // Update in local storage if conversationId is available
      if (_messages[index].conversationId != null) {
        await _localStorage.updateChatMessage(_messages[index].conversationId!, _messages[index]);
      }
    }
  }

  /// Marks a conversation as read.
  Future<void> markConversationAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    final conversationId = [senderId, receiverId].join('_');
    await _manager.markConversationAsRead(senderId: senderId, receiverId: receiverId);

    // Update all unread messages in this conversation
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].conversationId == conversationId && !_messages[i].read!) {
        _messages[i] = _messages[i].copyWith(read: true);

        // Update in local storage
        await _localStorage.updateChatMessage(conversationId, _messages[i]);
      }
    }
    notifyListeners();
  }

  /// Clears a conversation.
  Future<void> clearConversation({
    required String senderId,
    required String receiverId,
    required String userId,
  }) async {
    final conversationId = [senderId, receiverId].join('_');
    await _manager.clearConversation(senderId: senderId, receiverId: receiverId, userId: userId);

    // Remove all messages in this conversation
    _messages.removeWhere((m) => m.conversationId == conversationId);
    notifyListeners();

    // Clear from local storage
    await _localStorage.clearConversationMessages(conversationId);
  }

  /// Load messages for a specific conversation
  Future<void> loadConversationMessages(String conversationId) async {
    final messages = await _localStorage.getChatMessages(conversationId);
    _messages.addAll(messages);
    notifyListeners();
  }

  /// Get messages for a specific conversation
  List<ChatMessageModel> getConversationMessages(String conversationId) {
    return _messages.where((m) => m.conversationId == conversationId).toList();
  }

  /// Disposes all event listeners.
  void disposeProvider() {
    _manager.unregisterEvent('onlineUsers');
    _manager.unregisterEvent('receiveMessage');
    _manager.unregisterEvent('messageStatusUpdate');
    _manager.unregisterEvent('messageDeleted');
    _manager.unregisterEvent('conversationCleared');
    _manager.unregisterEvent('userTyping');
    _logger.logNetwork("SocketProvider disposed");
  }
}
