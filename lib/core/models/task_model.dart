import 'package:intl/intl.dart';

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
  
  final String type; // Story, Task, Bug, Epic
  final List<String> assignees;
  final List<String> reviewers; 
  final String? category; 
  final int storyPoints;
  final List<String>? references;
  final String? department;
  final String? sprintId;
  final String? projectId;

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
    this.type = 'Task',
    this.assignees = const [],
    this.reviewers = const [],
    this.category,
    this.storyPoints = 0,
    this.references,
    this.department,
    this.sprintId,
    this.projectId,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    List<String> reviewerList = [];
    if (map['reviewer'] is List) {
      reviewerList = List<String>.from(map['reviewer']);
    } else if (map['reviewer'] != null && map['reviewer'].toString().isNotEmpty) {
      reviewerList = [map['reviewer'].toString()];
    }

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
      type: map['type'] ?? 'Task',
      assignees: List<String>.from(map['assignedTo'] ?? map['assignees'] ?? []),
      reviewers: reviewerList,
      category: map['category'],
      storyPoints: map['storyPoints'] ?? 0,
      references: map['referenceFileUrl'] != null ? List<String>.from(map['referenceFileUrl']) : (map['references'] != null ? List<String>.from(map['references']) : null),
      department: map['department'],
      sprintId: map['sprintId'],
      projectId: map['projectId'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'taskName': title,
      'taskDescription': description,
      'deadline': DateFormat('yyyy-MM-dd').format(deadline),
      'priority': priority,
      'assignedBy': assignedBy,
      'type': type,
      'assignedTo': assignees, 
      // API only supports ONE reviewer string as per schema errors
      'reviewer': reviewers.isNotEmpty ? reviewers.first : "", 
      'category': category?.toLowerCase() ?? "development",
      'department': department ?? "Development", 
      'storyPoints': storyPoints,
      'referenceFileUrl': references ?? [],
      'sprintId': sprintId ?? "",
      'projectId': projectId ?? "",
    };
    
    if (id.isNotEmpty) {
      map['taskId'] = id;
      map['status'] = status;
    }
    
    return map;
  }
}
