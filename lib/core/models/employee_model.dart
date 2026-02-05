class EmployeeModel {
  final String name;
  final String employeeID;
  final String? profileImage;
  final String? email;
  final String? mobile;
  final String? alterMobile;
  final String? gender;
  final String? address;
  final String? role;
  final String? teamLead;
  final String? teamMembers;

  EmployeeModel({
    required this.name,
    required this.employeeID,
    this.profileImage,
    this.email,
    this.mobile,
    this.alterMobile,
    this.gender,
    this.address,
    this.role,
    this.teamLead,
    this.teamMembers,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      employeeID: json['employeeID']?.toString() ?? json['employeeId']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      alterMobile: json['alterMobile']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
      teamLead: json['teamLead']?.toString(),
      teamMembers: json['teamMembers'] is List
          ? (json['teamMembers'] as List).join(', ')
          : json['teamMembers']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'employeeID': employeeID,
      'profileImage': profileImage,
      'email': email,
      'mobile': mobile,
      'alterMobile': alterMobile,
      'gender': gender,
      'address': address,
      'role': role,
      'teamLead': teamLead,
      'teamMembers': teamMembers,
    };
  }
}
