class ClockModel {
  final String employeeId;
  final String name;
  final String department;
  final String clockIn;
  final String? clockOut;
  final String imageUrl;
  final String date;
  final String attendenceId;
  final Map<String, dynamic> location;
  final String breakTime;
  final String meetingTime;
  final bool approved;
  final bool processedToday;
  final String createdOn;
  final List<Map<String, dynamic>>? records;

  ClockModel({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.clockIn,
    this.clockOut,
    required this.imageUrl,
    required this.date,
    required this.attendenceId,
    required this.location,
    required this.breakTime,
    required this.meetingTime,
    required this.approved,
    required this.processedToday,
    required this.createdOn,
    this.records,
  });
  factory ClockModel.fromJson(Map<String, dynamic> json) {
    return ClockModel(
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      clockIn: json['clockIn'] ?? '',
      clockOut: json['clockOut'],
      imageUrl: json['imageUrl'] ?? '',
      date: json['date'] ?? '',
      attendenceId: json['attendenceId'] ?? '',
      location: json['location'] ?? {},
      breakTime: json['break'] ?? '00:00',
      meetingTime: json['Meeting'] ?? '00:00',
      approved: json['approved'] ?? false,
      processedToday: json['processedToday'] ?? false,
      createdOn: json['createdOn'] ?? '',
      records: json['records'] != null
          ? List<Map<String, dynamic>>.from(json['records'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'clockIn': clockIn,
      'clockOut': clockOut,
      'imageUrl': imageUrl,
      'date': date,
      'attendenceId': attendenceId,
      'location': location,
      'break': breakTime,
      'Meeting': meetingTime,
      'approved': approved,
      'processedToday': processedToday,
      'createdOn': createdOn,
    };
  }

  ClockModel copyWith({
    String? employeeId,
    String? name,
    String? department,
    String? clockIn,
    String? clockOut,
    String? imageUrl,
    String? date,
    String? attendenceId,
    Map<String, dynamic>? location,
    String? breakTime,
    String? meetingTime,
    bool? approved,
    bool? processedToday,
    String? createdOn,
  }) {
    return ClockModel(
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      department: department ?? this.department,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      attendenceId: attendenceId ?? this.attendenceId,
      location: location ?? this.location,
      breakTime: breakTime ?? this.breakTime,
      meetingTime: meetingTime ?? this.meetingTime,
      approved: approved ?? this.approved,
      processedToday: processedToday ?? this.processedToday,
      createdOn: createdOn ?? this.createdOn,
    );
  }
}
