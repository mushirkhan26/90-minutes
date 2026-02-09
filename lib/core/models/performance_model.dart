class PerformanceModel {
  final String reviewId;
  final String employeeName;
  final String employeeId;
  final double rating;
  final String status;
  final String reviewPersonName;
  final String reviewPersonId;
  final String reviewText;
  final String? employeeComment;
  final bool employeeLiked;
  final String? createdAt;
  final String? updatedAt;
  final String? employeeResponseAt;

  PerformanceModel({
    required this.reviewId,
    required this.employeeName,
    required this.employeeId,
    required this.rating,
    required this.status,
    required this.reviewPersonName,
    required this.reviewPersonId,
    required this.reviewText,
    this.employeeComment,
    this.employeeLiked = false,
    this.createdAt,
    this.updatedAt,
    this.employeeResponseAt,
  });

  PerformanceModel copyWith({
    String? reviewId,
    String? employeeName,
    String? employeeId,
    double? rating,
    String? status,
    String? reviewPersonName,
    String? reviewPersonId,
    String? reviewText,
    String? employeeComment,
    bool? employeeLiked,
    String? createdAt,
    String? updatedAt,
    String? employeeResponseAt,
  }) {
    return PerformanceModel(
      reviewId: reviewId ?? this.reviewId,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      reviewPersonName: reviewPersonName ?? this.reviewPersonName,
      reviewPersonId: reviewPersonId ?? this.reviewPersonId,
      reviewText: reviewText ?? this.reviewText,
      employeeComment: employeeComment ?? this.employeeComment,
      employeeLiked: employeeLiked ?? this.employeeLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      employeeResponseAt: employeeResponseAt ?? this.employeeResponseAt,
    );
  }

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      reviewId: json['reviewId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      reviewPersonName: json['reviewPersonName']?.toString() ?? '',
      reviewPersonId: json['reviewPersonId']?.toString() ?? '',
      reviewText: json['reviewText']?.toString() ?? '',
      employeeComment: json['employeeComment']?.toString(),
      employeeLiked: json['employeeLiked'] ?? false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      employeeResponseAt: json['employeeResponseAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'rating': rating,
      'status': status,
      'reviewPersonName': reviewPersonName,
      'reviewPersonId': reviewPersonId,
      'reviewText': reviewText,
      'employeeComment': employeeComment,
      'employeeLiked': employeeLiked,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'employeeResponseAt': employeeResponseAt,
    };
  }
}

class TeamPerformanceSummary {
  final String employeeId;
  final String name;
  final String role;
  final String department;
  final double averageRating;
  final List<PerformanceModel> reviews;

  TeamPerformanceSummary({
    required this.employeeId,
    required this.name,
    required this.role,
    required this.department,
    required this.averageRating,
    this.reviews = const [],
  });
}
