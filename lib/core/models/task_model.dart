class Task {
  final String id;
  final String taskKey;
  final String title;
  final String description;
  final DateTime deadline;
  final String status;
  final String priority;
  final String assignedBy;
  final String? itemType; // 'task' or 'subtask'
  final int subtaskCount;

  Task({
    required this.id,
    required this.taskKey,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.assignedBy,
    this.itemType,
    this.subtaskCount = 0,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['taskId'] ?? map['subtaskId'] ?? '',
      taskKey: map['taskKey'] ?? '',
      title: map['taskName'] ?? map['title'] ?? '',
      description: map['taskDescription'] ?? map['description'] ?? '',
      deadline: DateTime.parse(map['deadline'] ?? DateTime.now().toString()),
      status: map['status'] ?? 'ToDo',
      priority: map['priority'] ?? 'Medium',
      assignedBy: map['assignedBy'] ?? '',
      itemType: map['itemType'],
      subtaskCount: map['subtaskCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': id,
      'taskName': title,
      'taskDescription': description,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'priority': priority,
      'assignedBy': assignedBy,
    };
  }
}
