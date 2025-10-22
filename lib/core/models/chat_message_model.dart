// import 'package:hrtz_hrms/core/services/logger_service.dart';

class ChatMessageModel {
  /// 🆔 MongoDB `_id` — only present for messages received from the backend
  String? id;

  /// 📝 Message content
  String? message;

  /// 👤 Sender's ID
  String? sender;

  /// 🧑 Sender's display name ✅ (new)
  String? senderName;

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
    this.id,
    this.message,
    this.sender,
    this.senderName, // ✅ added
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
      id: map['_id'],
      message: map['text'],
      sender: map['sender'],
      senderName: map['senderName'], // ✅ capture name from backend
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

    // LoggingService.instance.logNetwork(
    //   "📥 Received message from backend: ${msg.toString()}",
    //   level: LogLevel.debug,
    // );

    return msg;
  }

  /// 💾 From local storage
  factory ChatMessageModel.fromLocalMap(Map<String, dynamic> map) {
    final msg = ChatMessageModel(
      id: map['_id'],
      message: map['message'],
      sender: map['sender'],
      senderName: map['senderName'], // ✅ load from local
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

    // LoggingService.instance.logStorage(
    //   "💾 Loaded message from local: ${msg.toString()}",
    //   level: LogLevel.debug,
    // );

    return msg;
  }

  /// 🧭 To local map
  Map<String, dynamic> toLocalMap() {
    final map = {
      '_id': id,
      'message': message,
      'sender': sender,
      'senderName': senderName, // ✅ save name locally
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

    // LoggingService.instance.logStorage("💽 Saved message to local: $map", level: LogLevel.debug);
    return map;
  }

  /// 🌐 To backend map (senderName included ✅)
  Map<String, dynamic> toBackendMap() {
    final map = {
      if (id != null) '_id': id,
      'sender': sender,
      'senderName': senderName, // ✅ include when sending
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
      'messageId': messageId,
    };

    // LoggingService.instance.logNetwork("📤 Sending message to backend: $map", level: LogLevel.info);
    return map;
  }

  /// ✍️ Copy with updates
  ChatMessageModel copyWith({
    String? id,
    String? message,
    String? sender,
    String? senderName, // ✅ added
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
      senderName: senderName ?? this.senderName, // ✅
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
        '_id: $id, '
        'message: $message, '
        'sender: $sender, '
        'senderName: $senderName, ' // ✅ added in log
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
