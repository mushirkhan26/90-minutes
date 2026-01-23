class Meet {
  final String? id;
  final String meetLink;
  final Map<String, String> createdBy;
  final List<Map<String, String>> participants;
  final String time;
  final String description;
  final String? agenda;
  final int duration;
  final String? createdAt;
  final String? updatedAt;

  Meet({
    this.id,
    required this.meetLink,
    required this.createdBy,
    required this.participants,
    required this.time,
    required this.description,
    this.agenda,
    this.duration = 30,
    this.createdAt,
    this.updatedAt,
  });

  factory Meet.fromJson(Map<String, dynamic> json) {
    return Meet(
      id: json['_id'] ?? json['id'],
      meetLink: json['meetLink'] ?? '',
      createdBy: {
        'employeeId': (json['createdBy']?['employeeId'] ?? '').toString(),
        'name': (json['createdBy']?['name'] ?? '').toString(),
      },
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => {
                    'employeeId': (p['employeeId'] ?? '').toString(),
                    'name': (p['name'] ?? '').toString(),
                  })
              .cast<Map<String, String>>()
              .toList() ?? [],
      time: (json['time'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      agenda: json['agenda']?.toString(),
      duration: int.tryParse(json['duration']?.toString() ?? '30') ?? 30,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'meetLink': meetLink,
      'createdBy': createdBy,
      'participants': participants,
      'time': time,
      'description': description,
      'agenda': agenda,
      'duration': duration,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
