import 'dart:convert';

class SocialPostModel {
  final String id;
  final String type; // birthday, post, poll, event, wellbeing
  final String title;
  final String? employeeName;
  final String message;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> likes;
  final List<SocialComment> comments;

  SocialPostModel({
    required this.id,
    required this.type,
    required this.title,
    this.employeeName,
    required this.message,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    return SocialPostModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'post',
      title: json['title'] ?? '',
      employeeName: json['employeeName'],
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((x) => SocialComment.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'employeeName': employeeName,
      'message': message,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
    };
  }
}

class SocialComment {
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;

  SocialComment({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    return SocialComment(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
