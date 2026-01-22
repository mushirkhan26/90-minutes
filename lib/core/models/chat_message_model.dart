class ChatMessageModel {
  String? id;
  String? message;
  String? sender;
  String? senderName;
  DateTime timestamp;
  String? messageType;
  String? fileUrl;
  String? fileName;
  String? messageId;
  bool isDeleted;
  bool? read;
  bool? delivered;
  String? conversationId;
  String? replyTo;

  ChatMessageModel({
    this.id,
    this.message,
    this.sender,
    this.senderName,
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

  factory ChatMessageModel.fromBackendMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['_id'],
      message: map['text'],
      sender: map['sender'],
      senderName: map['senderName'],
      // ✅ Fix: Convert to Local Time
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
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
  }

  factory ChatMessageModel.fromLocalMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['_id'],
      message: map['message'],
      sender: map['sender'],
      senderName: map['senderName'],
      // ✅ Fix: Local Time
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
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
  }

  Map<String, dynamic> toLocalMap() {
    return {
      '_id': id,
      'message': message,
      'sender': sender,
      'senderName': senderName,
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
  }

  Map<String, dynamic> toBackendMap() {
    return {
      if (id != null) '_id': id,
      'sender': sender,
      'senderName': senderName,
      'receiver': '',
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
  }

  ChatMessageModel copyWith({
    String? id, String? message, String? sender, String? senderName, DateTime? timestamp,
    String? messageType, String? fileUrl, String? fileName, String? messageId,
    bool? isDeleted, bool? read, bool? delivered, String? conversationId, String? replyTo,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      senderName: senderName ?? this.senderName,
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
}
