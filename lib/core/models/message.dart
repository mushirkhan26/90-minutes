/// Represents a message in the chat.
/// Used to serialize/deserialize message data from the backend.
class Message {
  final String id;
  final String sender;
  final String receiver;
  final String text;
  final String conversationId;
  final String messageType;
  final String? fileName;
  final String? fileUrl;
  final DateTime timestamp;
  final bool delivered;
  final bool read;
  final String? replyTo;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.conversationId,
    required this.messageType,
    this.fileName,
    this.fileUrl,
    required this.timestamp,
    required this.delivered,
    required this.read,
    this.replyTo,
  });

  /// Creates a Message from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      text: json['text'] ?? '',
      conversationId: json['conversationId'] ?? '',
      messageType: json['messageType'] ?? 'text',
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      timestamp: DateTime.parse(json['timestamp'].toString()),
      delivered: json['delivered'] ?? false,
      read: json['read'] ?? false,
      replyTo: json['replyTo'],
    );
  }

  /// Creates a copy of this message with updated fields.
  Message copyWith({
    String? id,
    String? sender,
    String? receiver,
    String? text,
    String? conversationId,
    String? messageType,
    String? fileName,
    String? fileUrl,
    DateTime? timestamp,
    bool? delivered,
    bool? read,
    String? replyTo,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      text: text ?? this.text,
      conversationId: conversationId ?? this.conversationId,
      messageType: messageType ?? this.messageType,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      timestamp: timestamp ?? this.timestamp,
      delivered: delivered ?? this.delivered,
      read: read ?? this.read,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}
