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
  final  List<EmployeeBenefit> benefit;

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
    this.benefit = const[],
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
      benefit: (json['benefit'] as List<dynamic>?)
            ?.map((e) => EmployeeBenefit.fromJson(e))
            .toList() ??
            [],
        
      
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
      'benefit' : benefit.map((e) => e.toJson()).toList(),
    };
  }
}
class EmployeeBenefit {
  final String benefitName;
  final String id;

  EmployeeBenefit({
    required this.benefitName,
    required this.id,
  });

  factory EmployeeBenefit.fromJson(Map<String, dynamic> json) {
    return EmployeeBenefit(
      benefitName: json['benefitName'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'benefitName': benefitName,
      'id': id,
    };
  }
}