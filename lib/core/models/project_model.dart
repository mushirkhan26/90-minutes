class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final String priority;
  final String startDate;
  final String endDate;
  final String? imageUrl;
  final List<ProjectCredential>? credentials;
  final Map<String, dynamic>? links;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.credentials,
    this.links,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['projectId']?.toString() ?? '',
      name: json['projectName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['projectStatus']?.toString() ?? 'Not Started',
      priority: json['priority']?.toString() ?? 'Normal',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      imageUrl: json['imageLink']?.toString(),
      credentials: json['testCredentials'] != null 
          ? (json['testCredentials'] as List).map((i) => ProjectCredential.fromJson(i)).toList()
          : null,
      links: json['links'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': id,
      'projectName': name,
      'description': description,
      'projectStatus': status,
      'priority': priority,
      'startDate': startDate,
      'endDate': endDate,
      'imageLink': imageUrl,
      'testCredentials': credentials?.map((e) => e.toJson()).toList(),
      'links': links,
    };
  }
}

class ProjectCredential {
  final String role;
  final String username;
  final String password;
  final String? notes;

  ProjectCredential({
    required this.role,
    required this.username,
    required this.password,
    this.notes,
  });

  factory ProjectCredential.fromJson(Map<String, dynamic> json) {
    return ProjectCredential(
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'username': username,
      'password': password,
      'notes': notes,
    };
  }
}
