class Meet {
  final String? id;
  final String meetLink;
  final Map<String, String> createdBy;
  final List<Map<String, String>> participants;
  final String time;
  final String description;
  final String? agenda;
  final int duration;
  final String? status;
  final String? createdAt;
  final bool isRecurring;
  final String? reccurrencePattern;

  Meet({
    this.id,
    required this.meetLink,
    required this.createdBy,
    required this.participants,
    required this.time,
    required this.description,
    this.agenda,
    this.duration = 30,
    this.isRecurring = false,
    this.reccurrencePattern,
    this.status,
    this.createdAt,
  });

  factory Meet.fromJson(Map<String, dynamic> json) {

    // 🔹 Combine meetingDate + meetingTime → time
    final meetingDate = json['meetingDate'] ?? '';
    final meetingTime = json['meetingTime'] ?? '';
    final combinedTime = "$meetingDate $meetingTime";

    return Meet(
      id: json['meetingId']?.toString(),
      meetLink: json['meetingLink'] ?? '',
      createdBy: {
        'employeeId': (json['organizer'] ?? '').toString(),
        'name': (json['organizerName'] ?? '').toString(),
      },
      participants: (json['joinerDetails'] as List<dynamic>?)
              ?.map((p) => {
                    'employeeId': (p['employeeId'] ?? '').toString(),
                    'name': (p['name'] ?? '').toString(),
                  })
              .toList()
              .cast<Map<String, String>>() ??
          [],
      time: combinedTime,
      description: (json['meetingTitle'] ?? '').toString(),
      agenda: json['meetingSummary']?.toString(),
      duration: int.tryParse(json['duration']?.toString() ?? '30') ?? 30,
      isRecurring: json['isRecurring'] ?? false,
      reccurrencePattern: json['recurrencePattern'],
      status: json['status']?.toString(),
      createdAt: json['createdOn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meetingId': id,
      'meetingLink': meetLink,
      'organizer': createdBy['employeeId'],
      'organizerName': createdBy['name'],
      'participants': participants,
      'time': time,
      'meetingTitle': description,
      'meetingSummary': agenda,
      'duration': duration,
      'status': status,
      'createdOn': createdAt,
    };
  }
}