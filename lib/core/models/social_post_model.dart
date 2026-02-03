//import 'dart:convert';

class SocialPostModel {
  final String id;
  final String type; // birthday, post, poll, event, wellbeing
  final String title;
  final String? userName;
  final String? userId;
  final String? employeeName;
  final String message;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> likes;
  final List<SocialComment> comments;
  
  // New fields for Poll
  final String? question;
  final DateTime? expiry;
  final List<PollOption>? options;

  // New fields for Event
  final DateTime? eventDate;

  SocialPostModel({
    required this.id,
    required this.type,
    required this.title,
    this.userName,
    this.userId,
    this.employeeName,
    required this.message,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.likes,
    required this.comments,
    this.question,
    this.expiry,
    this.options,
    this.eventDate,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse date and ensure it's local
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final parsed = DateTime.parse(value.toString());
        return parsed.isUtc ? parsed.toLocal() : parsed;
      } catch (e) {
        return DateTime.now();
      }
    }

    // Helper to try parse date and ensure it's local
    DateTime? tryParseDate(dynamic value) {
      if (value == null) return null;
      try {
        final parsed = DateTime.parse(value.toString());
        return parsed.isUtc ? parsed.toLocal() : parsed;
      } catch (e) {
        return null;
      }
    }

    return SocialPostModel(
      id: json['eventId'] ?? json['_id'] ?? '',
      type: json['eventType'] ?? json['type'] ?? 'post',
      title: json['title'] ?? '',
      userName: json['UserName'],
      userId: json['UserId'],
      employeeName: json['employeeName'],
      message: json['description'] ?? json['message'] ?? '',
      imageUrl: json['imageUrl'],
      createdBy: json['UserId'] ?? json['createdBy'] ?? '',
      createdAt: parseDate(json['createdAt']),
      // API uses likeMembers for the list of user IDs
      likes: List<String>.from(json['likeMembers'] ?? json['likes'] ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((x) => SocialComment.fromJson(x))
          .toList(),
      question: json['question'],
      expiry: tryParseDate(json['expiry']),
      options: (json['options'] as List? ?? [])
          .map((x) => PollOption.fromJson(x))
          .toList(),
      eventDate: tryParseDate(json['eventDate']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'UserId': userId ?? createdBy,
      'UserName': userName ?? 'User',
      'eventType': type,
      'title': title,
      'description': message,
      'imageUrl': imageUrl ?? '',
    };

    if (employeeName != null) {
      data['employeeName'] = employeeName;
    }

    if (type == 'poll') {
      data['question'] = question;
      // Convert to UTC before sending to server for consistency
      data['expiry'] = expiry?.toUtc().toIso8601String();
      data['options'] = options?.map((v) => v.toJson()).toList();
    }

    if (type == 'event') {
      // Convert to UTC before sending to server for consistency
      data['eventDate'] = eventDate?.toUtc().toIso8601String();
    }

    return data;
  }
}

class PollOption {
  final String? id;
  final String label;
  final int votes;
  final List<String>? voters;

  PollOption({this.id, required this.label, this.votes = 0, this.voters});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['optionId'],
      label: json['label'] ?? '',
      votes: json['votes'] ?? 0,
      voters: List<String>.from(json['voters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label};
  }
}

class SocialComment {
  final String? id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;

  SocialComment({
    this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final parsed = DateTime.parse(value.toString());
        return parsed.isUtc ? parsed.toLocal() : parsed;
      } catch (e) {
        return DateTime.now();
      }
    }

    return SocialComment(
      id: json['commentId'],
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      comment: json['content'] ?? json['comment'] ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
