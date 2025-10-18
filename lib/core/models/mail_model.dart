class MailResponse {
  final String message;
  final List<Mail>? data;

  MailResponse({required this.message, this.data});

  factory MailResponse.fromJson(Map<String, dynamic> json) {
    return MailResponse(
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List).map((e) => Mail.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.map((e) => e.toJson()).toList()};
  }
}

class Mail {
  final List<String> receiverName;
  final List<String> bcc;
  final String? id;
  final String sender;
  final String senderName;
  final List<String> receiver;
  final List<String> cc;
  final String subject;
  final String body;
  final List<String> attachmentUrls;
  final String status;
  final String? replyTo;
  final Map<String, PerUserStatus> perUserStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String? senderProfileUrl;

  Mail({
    required this.receiverName,
    required this.bcc,
    this.id,
    required this.sender,
    required this.senderName,
    required this.receiver,
    required this.cc,
    required this.subject,
    required this.body,
    required this.attachmentUrls,
    required this.status,
    required this.replyTo,
    required this.perUserStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.v,

    required this.senderProfileUrl,
  });

  factory Mail.fromJson(Map<String, dynamic> json) {
    final Map<String, PerUserStatus> statusMap = {};
    if (json['perUserStatus'] != null) {
      json['perUserStatus'].forEach((key, value) {
        statusMap[key] = PerUserStatus.fromJson(value);
      });
    }

    return Mail(
      receiverName: List<String>.from(json['receiverName'] ?? []),
      bcc: List<String>.from(json['bcc'] ?? []),
      id: json['_id'] ?? json['id'],
      sender: json['sender'] ?? '',
      senderName: json['senderName'] ?? '',
      receiver: List<String>.from(json['receiver'] ?? []),
      cc: List<String>.from(json['cc'] ?? []),
      subject: json['subject'] ?? '',
      body: json['body'] ?? '',
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      status: json['status'] ?? '',
      replyTo: json['replyTo'],
      perUserStatus: statusMap,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,

      senderProfileUrl: json['senderProfileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> statusMap = {};
    perUserStatus.forEach((key, value) {
      statusMap[key] = value.toJson();
    });

    return {
      'receiverName': receiverName,
      'bcc': bcc,
      '_id': id,
      'sender': sender,
      'senderName': senderName,
      'receiver': receiver,
      'cc': cc,
      'subject': subject,
      'body': body,
      'attachmentUrls': attachmentUrls,
      'status': status,
      'replyTo': replyTo,
      'perUserStatus': statusMap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,

      'senderProfileUrl': senderProfileUrl,
    };
  }
}

class PerUserStatus {
  final bool isRead;
  final bool isDeleted;
  final String folder;
  final String? id;

  PerUserStatus({
    required this.isRead,
    required this.isDeleted,
    required this.folder,
    this.id,
  });

  factory PerUserStatus.fromJson(Map<String, dynamic> json) {
    return PerUserStatus(
      isRead: json['isRead'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      folder: json['folder'] ?? '',
      id: json['_id'] ?? json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRead': isRead,
      'isDeleted': isDeleted,
      'folder': folder,
      '_id': id,
    };
  }
}
