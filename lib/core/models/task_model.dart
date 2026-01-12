class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // 'Pending', 'In Progress', 'Completed'
  final String priority; // 'Low', 'Medium', 'High'
  final String assignedTo;
  final String assignedBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.assignedBy,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toString()),
      status: map['status'] ?? 'Pending',
      priority: map['priority'] ?? 'Medium',
      assignedTo: map['assignedTo'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
    };
  }
}
