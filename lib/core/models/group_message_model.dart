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
    final backendId = map['_id']?.toString();
    
    // Improved timestamp parsing with explicit local conversion
    DateTime parsedTimestamp;
    var tsValue = map['timestamp'];
    if (tsValue is String) {
      // If it's a string, try to parse and ensure it's treated as UTC if no offset exists
      String ts = tsValue;
      if (!ts.contains('Z') && !ts.contains('+') && !ts.contains('-')) {
        ts += 'Z'; 
      }
      parsedTimestamp = DateTime.tryParse(ts)?.toLocal() ?? DateTime.now();
    } else if (tsValue is int) {
      // Handle seconds vs milliseconds (Unix timestamps are usually UTC)
      if (tsValue < 10000000000) { 
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(tsValue * 1000).toLocal();
      } else {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(tsValue).toLocal();
      }
    } else {
      parsedTimestamp = DateTime.now();
    }

    return GroupMessageModel(
      id: backendId,
      // Prefer messageId from map (client-generated), fallback to backend _id
      messageId: map['messageId']?.toString() ?? backendId ?? '',
      groupId: map['groupId']?.toString() ?? '',
      sender: map['sender']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      messageType: map['messageType']?.toString() ?? 'text',
      fileName: map['fileName']?.toString(),
      fileUrl: map['fileUrl']?.toString(),
      replyTo: map['replyTo']?.toString(),
      mentions: map['mentions'] != null ? List<String>.from(map['mentions']) : [],
      read: map['read'] ?? false,
      delivered: map['delivered'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      timestamp: parsedTimestamp,
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
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
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
