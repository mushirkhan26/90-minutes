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

  /// ✨ Optional: Keep track of pending messages (for UI loaders etc.)
  final Set<String> _pendingMessages = {};

  /// Getters
  List<String> get onlineUsers => List.unmodifiable(_onlineUsers);
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  Map<String, bool> get typingIndicators => Map.unmodifiable(_typingIndicators);
  Set<String> get pendingMessages => _pendingMessages;

  // Add a method to update a specific message
  /// 🆕 Helper to update a message by either MongoDB _id or messageId (fallback)
  void _updateMessage(ChatMessageModel updatedMessage) {
    final index = _messages.indexWhere(
      (m) => m.id == updatedMessage.id || m.messageId == updatedMessage.messageId,
    );
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
  }

  /// Initializes socket event listeners.
  void init() {
    /// 🟢 Online Users Listener
    _manager.registerEvent('onlineUsers', (data) {
      _onlineUsers = List<String>.from(data);
      notifyListeners();
      _logger.logNetwork("[Socket] Online users updated: $_onlineUsers");
    });

    /// 📨 Receive Message Listener (this is now the only place where message is added to local)
    _manager.registerEvent('receiveMessage', (data) async {
      _logger.logNetwork("[Socket] Incoming raw message data: $data");

      final message = ChatMessageModel.fromBackendMap(data);

      // 🆕 Check duplicates using either `id` (MongoDB) or `messageId` (client)
      final exists = _messages.any(
        (m) =>
            (message.id != null && m.id == message.id) ||
            (message.messageId != null && m.messageId == message.messageId),
      );

      if (exists) {
        _logger.warning(
          "[Socket] Duplicate message ignored: ",
          "${message.id ?? message.messageId}",
        );
        return;
      }

      // 🟢 Remove pending state if matches client messageId
      if (message.messageId != null) {
        _pendingMessages.remove(message.messageId);
      }

      _messages.add(message);
      _logger.logNetwork(
        "[Socket] Message added locally: id=${message.id} | messageId=${message.messageId}",
      );

      if (message.conversationId != null) {
        final existingMessages = await _localStorage.getChatMessages(message.conversationId!);
        existingMessages.add(message);
        await _localStorage.saveChatMessages(message.conversationId!, existingMessages);
        _logger.logNetwork(
          "[LocalStorage] Message saved for conversation: ${message.conversationId}",
        );
      }

      notifyListeners();
    });

    /// 📬 Status Updates (unchanged)
    /// 📬 Status Update (read/delivered) — now lookup by id first
    _manager.registerEvent('messageStatusUpdate', (data) async {
      final mongoId = data['_id'];
      final clientId = data['messageId'];
      final status = data['status'];

      final index = _messages.indexWhere(
        (m) =>
            (mongoId != null && m.id == mongoId) || (clientId != null && m.messageId == clientId),
      );

      if (index != -1) {
        ChatMessageModel updatedMessage;
        if (status == 'read') {
          updatedMessage = _messages[index].copyWith(read: true);
        } else if (status == 'delivered') {
          updatedMessage = _messages[index].copyWith(delivered: true);
        } else {
          return;
        }

        _messages[index] = updatedMessage;
        if (updatedMessage.conversationId != null) {
          await _localStorage.updateChatMessage(updatedMessage.conversationId!, updatedMessage);
        }

        notifyListeners();
        _logger.logNetwork("[Socket] Message status updated: ${mongoId ?? clientId} -> $status");
      }
    });

    /// 🗑️ Delete
    _manager.registerEvent('messageDeleted', (data) async {
      final mongoId = data['_id'];
      final clientId = data['messageId'];
      final conversationId = data['conversationId'];

      final index = _messages.indexWhere(
        (m) =>
            (mongoId != null && m.id == mongoId) || (clientId != null && m.messageId == clientId),
      );

      if (index != -1) {
        final updatedMessage = _messages[index].copyWith(
          isDeleted: true,
          message: "This message is deleted",
          fileUrl: null,
        );
        _updateMessage(updatedMessage);

        if (conversationId != null) {
          await _localStorage.updateChatMessage(conversationId, updatedMessage);
        }
      }

      notifyListeners();
      _logger.logNetwork("Message deleted: ${mongoId ?? clientId}");
    });

    _manager.registerEvent('conversationCleared', (data) async {
      final conversationId = data['conversationId'];
      _messages.removeWhere((m) => m.conversationId == conversationId);

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

  /// ✨ Send Message - No local save anymore, only emit
  Future<void> sendMessage({
    required String sender,
    required String senderName,
    required String receiver,
    required String text,
    required String messageId,
    String? conversationId,
    String messageType = 'text',
    String? fileName,
    String? fileUrl,
    String? replyTo,
  }) async {
    // 🟡 Log the outgoing payload
    final payload = {
      'sender': sender,
      'senderName': senderName,
      'receiver': receiver,
      'text': text,
      'messageId': messageId,
      'conversationId': conversationId,
      'messageType': messageType,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'replyTo': replyTo,
    };
    _logger.logNetwork("[Socket] Sending message payload: $payload");

    // 🕒 Add to pending state (optional UI loader)
    _pendingMessages.add(messageId);
    notifyListeners();

    // 🚀 Send through socket manager
    await _manager.sendMessage(
      sender: sender,
      senderName: senderName,
      receiver: receiver,
      text: text,
      messageId: messageId,
      conversationId: conversationId,
      messageType: messageType,
      fileName: fileName,
      fileUrl: fileUrl,
      replyTo: replyTo,
    );

    _logger.logNetwork("[Socket] Message emit completed for: $messageId");
  }

  /// Marks a message as deleted (instead of actually deleting)
  Future<void> markMessageAsDeleted({
    required String messageId,
    required String userId,
    String? conversationId,
  }) async {
    final index = _messages.indexWhere((m) => m.id == messageId || m.messageId == messageId);

    if (index != -1) {
      final updatedMessage = _messages[index].copyWith(
        isDeleted: true,
        message: "This message is deleted",
        fileUrl: null,
      );
      _updateMessage(updatedMessage);

      if (conversationId != null) {
        await _localStorage.updateChatMessage(conversationId, updatedMessage);
      }

      notifyListeners();
    }

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

    final index = _messages.indexWhere((m) => m.id == messageId || m.messageId == messageId);

    if (index != -1) {
      _messages[index] = _messages[index].copyWith(read: true);
      notifyListeners();

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

  void clearConversationMemory(String conversationId, {bool notify = true}) {
    _messages.removeWhere((m) => m.conversationId == conversationId);
    if (notify) notifyListeners();
  }

  /// Load messages for a specific conversation
  Future<void> loadConversationMessages(String conversationId) async {
    final messages = await _localStorage.getChatMessages(conversationId);

    // Clear old messages of this conversation
    _messages.removeWhere((m) => m.conversationId == conversationId);

    // Deduplicate just in case
    final existingIds = _messages.map((m) => m.id ?? m.messageId).toSet();
    final uniqueMessages = messages
        .where((m) => !existingIds.contains(m.id ?? m.messageId))
        .toList();

    _messages.addAll(uniqueMessages);
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
