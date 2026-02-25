class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['notificationId'] ?? json['id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: (json['message'] ?? json['body'])?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      createdAt: (json['createdOn'] ?? json['createdAt']) != null 
          ? DateTime.parse(json['createdOn'] ?? json['createdAt']) 
          : DateTime.now(),
      isRead: json['viewed'] ?? json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }
}
