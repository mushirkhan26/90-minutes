class GroupMessageModel {
  final String? id; // MongoDB _id (optional)
  final String messageId; // Client-generated ID
  final String groupId;
  final String sender;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'document', 'system'
  final String? fileName;
  final String? fileUrl;
  final String? replyTo;
  final List<String>? mentions;
  final bool read;
  final bool delivered;
  final bool isDeleted;

  GroupMessageModel({
    this.id,
    required this.messageId,
    required this.groupId,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.messageType = 'text',
    this.fileName,
    this.fileUrl,
    this.replyTo,
    this.mentions,
    this.read = false,
    this.delivered = false,
    this.isDeleted = false,
  });

  // Create from backend/server map
  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      id: map['_id']?.toString(),
      messageId: map['messageId'] ?? map['_id'].toString(),
      groupId: map['groupId'],
      sender: map['sender'],
      senderName: map['senderName'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp'].toString()),
      messageType: map['messageType'] ?? 'text',
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      replyTo: map['replyTo'],
      mentions: map['mentions'] != null ? List<String>.from(map['mentions']) : null,
      read: map['read'] ?? false,
      delivered: map['delivered'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  // Convert to local storage map
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'messageId': messageId,
      'groupId': groupId,
      'sender': sender,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'replyTo': replyTo,
      'mentions': mentions,
      'read': read,
      'delivered': delivered,
      'isDeleted': isDeleted,
    };
  }

  // Create from local storage map
  factory GroupMessageModel.fromLocalMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      id: map['id'],
      messageId: map['messageId'],
      groupId: map['groupId'],
      sender: map['sender'],
      senderName: map['senderName'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      messageType: map['messageType'] ?? 'text',
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      replyTo: map['replyTo'],
      mentions: map['mentions'] != null ? List<String>.from(map['mentions']) : null,
      read: map['read'] ?? false,
      delivered: map['delivered'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  // Copy with updated fields
  GroupMessageModel copyWith({
    String? id,
    String? messageId,
    String? groupId,
    String? sender,
    String? senderName,
    String? text,
    DateTime? timestamp,
    String? messageType,
    String? fileName,
    String? fileUrl,
    String? replyTo,
    List<String>? mentions,
    bool? read,
    bool? delivered,
    bool? isDeleted,
  }) {
    return GroupMessageModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      groupId: groupId ?? this.groupId,
      sender: sender ?? this.sender,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      replyTo: replyTo ?? this.replyTo,
      mentions: mentions ?? this.mentions,
      read: read ?? this.read,
      delivered: delivered ?? this.delivered,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
