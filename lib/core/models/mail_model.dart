class MailModel {
  final String id;
  final String sender;
  final String senderName;
  final String? senderProfileUrl;
  final List<String> receiver;
  final List<String> receiverName;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final List<String> attachmentUrls;
  final String status;
  bool isStarred;
  final String? replyTo;
  final Map<String, dynamic> perUserStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  MailModel({
    required this.id,
    required this.sender,
    required this.senderName,
    this.senderProfileUrl,
    required this.receiver,
    required this.receiverName,
    required this.cc,
    required this.bcc,
    required this.subject,
    required this.body,
    required this.attachmentUrls,
    required this.status,
    required this.isStarred,
    this.replyTo,
    required this.perUserStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MailModel.fromJson(Map<String, dynamic> json) {
    return MailModel(
      id: json['_id'] ?? '',
      sender: json['sender']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      senderProfileUrl: json['senderProfileUrl'],
      receiver: json['receiver'] is List
          ? List<String>.from(json['receiver'].map((e) => e.toString()))
          : json['receiver'] != null ? [json['receiver'].toString()] : [],
      receiverName: json['receiverName'] is List
          ? List<String>.from(json['receiverName'].map((e) => e.toString()))
          : json['receiverName'] != null ? [json['receiverName'].toString()] : [],
      cc: json['cc'] is List ? List<String>.from(json['cc']) : [],
      bcc: json['bcc'] is List ? List<String>.from(json['bcc']) : [],
      subject: json['subject'] ?? '',
      // ✅ Fix: Check both 'message' and 'body' keys
      body: json['message'] ?? json['body'] ?? '',
      attachmentUrls: json['attachmentUrls'] is List ? List<String>.from(json['attachmentUrls']) : [],
      status: json['status'] ?? '',
      isStarred: json['isStarred'] ?? false,
      replyTo: json['replyTo'],
      perUserStatus: json['perUserStatus'] is Map ? Map<String, dynamic>.from(json['perUserStatus']) : {},
      // ✅ Fix: Local Time conversion
      createdAt: DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'senderName': senderName,
      'senderProfileUrl': senderProfileUrl,
      'receiver': receiver,
      'receiverName': receiverName,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'attachmentUrls': attachmentUrls,
      'status': status,
      'isStarred': isStarred,
      'replyTo': replyTo,
      'perUserStatus': perUserStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
