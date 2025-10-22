import 'package:hrtz_hrms/core/services/logger_service.dart';

class ChatMessageModel {
  /// 🆔 MongoDB `_id` — only present for messages received from the backend
  /// Used for read / deliver / delete operations via sockets
  String? id;

  /// 📝 Message content
  String? message;

  /// 👤 Sender's ID
  String? sender;

  /// 🕒 Timestamp when the message was sent
  DateTime timestamp;

  /// 📄 Message type: 'text', 'image', 'document', 'voice'
  String? messageType;

  /// 📎 File URL for media messages
  String? fileUrl;

  /// 📁 File name for media messages
  String? fileName;

  /// 🧭 Client-side generated message ID — used for local reference/offline mode
  String? messageId;

  /// 🗑️ Deleted flag
  bool isDeleted;

  /// 👁️ Read status
  bool? read;

  /// 📬 Delivery status
  bool? delivered;

  /// 💬 Conversation ID (senderId_receiverId)
  String? conversationId;

  /// ↩️ Reply to another message ID
  String? replyTo;

  ChatMessageModel({
    this.id, // null when sending a new message
    this.message,
    this.sender,
    required this.timestamp,
    this.messageType = 'text',
    this.fileUrl,
    this.fileName,
    this.messageId,
    this.isDeleted = false,
    this.read = false,
    this.delivered = false,
    this.conversationId,
    this.replyTo,
  });

  /// 🏗️ From backend message (includes MongoDB _id)
  factory ChatMessageModel.fromBackendMap(Map<String, dynamic> map) {
    final msg = ChatMessageModel(
      id: map['_id'], // ✅ id is only set here
      message: map['text'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
      messageType: map['messageType'] ?? 'text',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      messageId: map['messageId'] ?? map['_id'],
      isDeleted: map['isDeleted'] ?? false,
      read: map['read'],
      delivered: map['delivered'],
      conversationId: map['conversationId'],
      replyTo: map['replyTo'],
    );

    LoggingService.instance.logNetwork(
      "📥 Received message from backend: ${msg.toString()}",
      level: LogLevel.debug,
    );

    return msg;
  }

  /// 💾 From local storage (id may be null for unsent messages)
  factory ChatMessageModel.fromLocalMap(Map<String, dynamic> map) {
    final msg = ChatMessageModel(
      id: map['_id'], // May be null
      message: map['message'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
      messageType: map['type'] ?? map['messageType'] ?? 'text',
      fileUrl: map['mediaUrl'] ?? map['fileUrl'],
      fileName: map['fileName'],
      messageId: map['messageId'],
      isDeleted: map['isDeleted'] ?? false,
      read: map['read'],
      delivered: map['delivered'],
      conversationId: map['conversationId'],
      replyTo: map['replyTo'],
    );

    LoggingService.instance.logStorage(
      "💾 Loaded message from local: ${msg.toString()}",
      level: LogLevel.debug,
    );

    return msg;
  }

  /// 🧭 To local map (id might be null for new messages)
  Map<String, dynamic> toLocalMap() {
    final map = {
      '_id': id,
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'type': messageType,
      'messageType': messageType,
      'mediaUrl': fileUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'messageId': messageId,
      'isDeleted': isDeleted,
      'read': read,
      'delivered': delivered,
      'conversationId': conversationId,
      'replyTo': replyTo,
    };

    LoggingService.instance.logStorage("💽 Saved message to local: $map", level: LogLevel.debug);

    return map;
  }

  /// 🌐 To backend map (id only if already assigned by server)
  Map<String, dynamic> toBackendMap() {
    final map = {
      if (id != null) '_id': id, // ✅ only include if exists
      'sender': sender,
      'receiver': '', // Will be set dynamically when sending
      'text': message,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'conversationId': conversationId,
      'replyTo': replyTo,
      'delivered': delivered,
      'read': read,
      'isDeleted': isDeleted,
      'messageId': messageId, // client generated id always included
    };

    LoggingService.instance.logNetwork("📤 Sending message to backend: $map", level: LogLevel.info);

    return map;
  }

  /// ✍️ Copy with updates
  ChatMessageModel copyWith({
    String? id,
    String? message,
    String? sender,
    DateTime? timestamp,
    String? messageType,
    String? fileUrl,
    String? fileName,
    String? messageId,
    bool? isDeleted,
    bool? read,
    bool? delivered,
    String? conversationId,
    String? replyTo,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      messageId: messageId ?? this.messageId,
      isDeleted: isDeleted ?? this.isDeleted,
      read: read ?? this.read,
      delivered: delivered ?? this.delivered,
      conversationId: conversationId ?? this.conversationId,
      replyTo: replyTo ?? this.replyTo,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel('
        '_id: $id, ' // ✅ id may be null for unsent messages
        'message: $message, '
        'sender: $sender, '
        'timestamp: $timestamp, '
        'messageType: $messageType, '
        'fileUrl: $fileUrl, '
        'fileName: $fileName, '
        'messageId: $messageId, '
        'isDeleted: $isDeleted, '
        'read: $read, '
        'delivered: $delivered, '
        'conversationId: $conversationId, '
        'replyTo: $replyTo)';
  }
}
