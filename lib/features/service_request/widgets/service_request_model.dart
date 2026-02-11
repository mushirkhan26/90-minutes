class ServiceRequest {
  final String requestId;
  final String department;
  final String type;
  final String name;
  final String description;
  final String requestStatus;
  final String employeeId;
  final String managerId;
  final String managerName;
  final String email;
  final String mobile;
  final String adminComment;
  final String videoUrl;
  final DateTime createdOn;
  final List<String> attachmentUrl;

  ServiceRequest({
    required this.requestId,
    required this.department,
    required this.type,
    required this.description,
    required this.requestStatus,
    required this.employeeId,
    required this.managerId,
    required this.managerName,
    required this.email,
    required this.name,
    required this.mobile,
    required this.adminComment,
    required this.videoUrl,
    required this.createdOn,
    required this.attachmentUrl,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      requestId: json['requestId'] ?? '',
      department: json['department'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      requestStatus: json['requestStatus'] ?? '',
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      adminComment: json['adminComment'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      createdOn: json['createdOn'] != null
      ? DateTime.parse(json['createdOn'])
      :DateTime.now(),
      
      attachmentUrl:
          (json['attachmentUrl'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "requestId": requestId,
      "department": department,
      "type": type,
      "name": name,
      "description": description,
      "requestStatus": requestStatus,
      "employeeId": employeeId,
      "managerId": managerId,
      "managerName": managerName,
      "email": email,
      "mobile": mobile,
      "adminComment": adminComment,
      "videoUrl": videoUrl,
      "createdOn": createdOn.toIso8601String(),
      "attachmentUrl": attachmentUrl,
    };
  }

  ServiceRequest copyWith({
    String? requestStatus,
    String? adminComment,
    String? videoUrl,
  }) {
    return ServiceRequest(
      requestId: requestId,
      department: department,
      type: type,
      name: name,
      description: description,
      requestStatus: requestStatus ?? this.requestStatus,
      employeeId: employeeId,
      managerId: managerId,
      managerName: managerName,
      email: email,
      mobile: mobile,
      adminComment: adminComment ?? this.adminComment,
      videoUrl: videoUrl ?? this.videoUrl,
      createdOn: createdOn,
      attachmentUrl: attachmentUrl,
    );
  }
}