class ChatMessageModel {
  /// Message content (text for text messages, "image"/"document" for media)
  String? message;

  /// Sender's ID (employeeId)
  String? sender;

  /// When the message was sent/received
  DateTime timestamp;

  /// Type of message: 'text', 'image', 'document', 'voice'
  String? messageType;

  /// URL for media messages (images, documents, voice notes)
  String? fileUrl;

  /// Filename for media messages
  String? fileName;

  /// Unique message ID
  String? messageId;

  /// Whether message is deleted
  bool isDeleted;

  /// Whether message is read
  bool? read;

  /// Whether message is delivered
  bool? delivered;

  /// Conversation ID (format: "senderId_receiverId")
  String? conversationId;

  /// Reply to message ID (for threaded replies)
  String? replyTo;

  ChatMessageModel({
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

  /// Factory constructor to create from backend message format
  factory ChatMessageModel.fromBackendMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      message: map['text'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
      messageType: map['messageType'] ?? 'text',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      messageId: map['_id'] ?? map['messageId'],
      isDeleted: map['isDeleted'] ?? false,
      read: map['read'],
      delivered: map['delivered'],
      conversationId: map['conversationId'],
      replyTo: map['replyTo'],
    );
  }

  /// Factory constructor to create from local storage format
  factory ChatMessageModel.fromLocalMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      message: map['message'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
      messageType: map['type'] ?? map['messageType'] ?? 'text',
      fileUrl: map['mediaUrl'] ?? map['fileUrl'],
      fileName: map['fileName'],
      messageId: map['messageId'] ?? map['_id'],
      isDeleted: map['isDeleted'] ?? false,
      read: map['read'],
      delivered: map['delivered'],
      conversationId: map['conversationId'],
      replyTo: map['replyTo'],
    );
  }

  /// Convert to map for local storage
  Map<String, dynamic> toLocalMap() {
    return {
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'type': messageType, // Keep 'type' for backward compatibility
      'messageType': messageType,
      'mediaUrl': fileUrl, // Keep 'mediaUrl' for backward compatibility
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

  /// Convert to map for backend API
  Map<String, dynamic> toBackendMap() {
    return {
      '_id': messageId,
      'sender': sender,
      'receiver': '', // Will be set when sending
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
    };
  }

  /// Create a copy with updated values
  ChatMessageModel copyWith({
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
