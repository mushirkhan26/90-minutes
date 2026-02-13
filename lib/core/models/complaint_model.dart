class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String employeeName;
  final String employeeId;
  final DateTime? createdAt;
  final String additionalInfo;
  final List<String> attachments;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.employeeName,
    required this.employeeId,
    required this.createdAt,
    required this.additionalInfo,
    required this.attachments,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['complaintId'] ?? json['_id'] ?? '',
      title: json['complaintTitle'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['complaintStatus'] ?? 'Pending',
      employeeName: json['name'] ?? '',
      employeeId: json['employeeId'] ?? '',
      createdAt: DateTime.tryParse(
        json['createdon'] ??
        json['createdOn'] ??
        json['createdAt'] ??
        '',
      ),
      additionalInfo: json['additionalInfo'] ?? '',
      attachments:
          (json['attachment'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'complaintId': id,
      'complaintTitle': title,
      'description': description,
      'category': category,
      'complaintStatus': status,
      'name': employeeName,
      'employeeId': employeeId,
      'createdAt': createdAt?.toIso8601String(),
      'additionalInfo': additionalInfo,
      'attachment': attachments,
    };
  }

  ComplaintModel copyWith({
    String? status,
  }) {
    return ComplaintModel(
      id: id,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      employeeName: employeeName,
      employeeId: employeeId,
      createdAt: createdAt,
      additionalInfo: additionalInfo,
      attachments: attachments,
    );
  }

  String get createdAtFormatted {
    if (createdAt == null) return '-';
    return "${createdAt!.day.toString().padLeft(2, '0')}/"
           "${createdAt!.month.toString().padLeft(2, '0')}/"
           "${createdAt!.year}";
  }
}
