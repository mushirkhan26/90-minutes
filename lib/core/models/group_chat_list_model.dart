class GroupChatModel {
  final String groupId;
  final String name;
  final String? description;
  final String? icon;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;

  final String? lastMessage;
  final DateTime? lastMessageTime;
  final List<String> admins;
  final bool adminOnlyMessaging;

  GroupChatModel({
    required this.groupId,
    required this.name,
    this.description,
    this.icon,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.admins = const [],
    this.adminOnlyMessaging = false,
  });

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      groupId: map['_id']?.toString() ?? map['groupId']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      icon: map['icon'],
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy']?.toString() ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),

      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,

      admins: List<String>.from(map['admins'] ?? []),
      adminOnlyMessaging: map['adminOnlyMessaging'] ?? false,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'icon': icon,
      'members': members,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'admins': admins,
      'adminOnlyMessaging': adminOnlyMessaging,
    };
  }

  factory GroupChatModel.fromLocalMap(Map<String, dynamic> map) {
    return GroupChatModel(
      groupId: map['groupId'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      members: List<String>.from(map['members'] ?? []),
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt']),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,

      admins: List<String>.from(map['admins'] ?? []),
      adminOnlyMessaging: map['adminOnlyMessaging'] ?? false,
    );
  }

  GroupChatModel copyWith({
    String? groupId,
    String? name,
    String? description,
    String? icon,
    List<String>? members,
    String? createdBy,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageTime,
    List<String>? admins,
    bool? adminOnlyMessaging,
  }) {
    return GroupChatModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,

      admins: admins ?? this.admins,
      adminOnlyMessaging:
          adminOnlyMessaging ?? this.adminOnlyMessaging,
    );
  }
}