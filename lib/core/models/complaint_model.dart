class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String additionalInfo;
  final List<String> attachments;
  final DateTime? createdAt;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.additionalInfo,
    required this.attachments,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['complaintId'] ?? json['_id'] ?? '',
      title: json['complaintTitle'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['complaintStatus'] ?? 'Pending',
      additionalInfo: json['additionalInfo'] ?? '',
      attachments:
          (json['attachment'] as List?)?.map((e) => e.toString()).toList() ?? [],

      /// 🔥 HANDLE ALL POSSIBLE DATE KEYS
      createdAt: DateTime.tryParse(
        json['createdon'] ??
        json['createdOn'] ??
        json['createdAt'] ??
        '',
      ),
    );
  }

  /// ✅ NEVER EMPTY → UI ALWAYS SHOWS DATE
  String get createdAtFormatted {
    if (createdAt == null) return '—';
    return "${createdAt!.day.toString().padLeft(2, '0')}/"
        "${createdAt!.month.toString().padLeft(2, '0')}/"
        "${createdAt!.year}";
  }
}