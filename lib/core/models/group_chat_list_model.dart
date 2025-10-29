class GroupChatModel {
  final String groupId;
  final String name;
  final String? description;
  final String? icon;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;

  GroupChatModel({
    required this.groupId,
    required this.name,
    this.description,
    this.icon,
    required this.members,
    required this.createdBy,
    required this.createdAt,
  });

  // Create from backend/server map
  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      groupId: map['_id']?.toString() ?? map['groupId']?.toString() ?? '', // Ensure it's a String
      name: map['name'] ?? '',
      description: map['description'],
      icon: map['icon'],
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy']?.toString() ?? '', // Ensure it's a String
      createdAt: DateTime.parse(map['createdAt'].toString()), // Ensure it's a String or int
    );
  }

  // Convert to local storage map
  Map<String, dynamic> toLocalMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'icon': icon,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from local storage map
  factory GroupChatModel.fromLocalMap(Map<String, dynamic> map) {
    return GroupChatModel(
      groupId: map['groupId'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
