class HolidayModel {
  final String date;
  final String day;
  final String holiday;

  HolidayModel({
    required this.date,
    required this.day,
    required this.holiday,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      date: json['Date'],
      day: json['Day'],
      holiday: json['Holiday'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Day': day,
      'Holiday': holiday,
    };
  }
}
