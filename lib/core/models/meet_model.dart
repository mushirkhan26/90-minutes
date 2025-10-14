class Meet {
  final String? id;
  final String title;
  final String location;
  final String link;
  final DateTime startTime;

  Meet({
    this.id,
    required this.title,
    required this.location,
    required this.link,
    required this.startTime,
  });

  factory Meet.fromJson(Map<String, dynamic> json) {
    return Meet(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      location: json['location'],
      link: json['link'],
      startTime: DateTime.parse(json['startTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'link': link,
      'startTime': startTime.toIso8601String(),
    };
  }
}
