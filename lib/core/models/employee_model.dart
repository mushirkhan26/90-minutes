class EmployeeModel {
  final String name;
  final String employeeID;
  final String? profileImage;

  EmployeeModel({required this.name, required this.employeeID, this.profileImage});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      name: json['name'] ?? '',
      employeeID: json['employeeID'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'employeeID': employeeID, 'profileImage': profileImage};
  }

  @override
  String toString() {
    return 'EmployeeModel(name: $name, employeeID: $employeeID, profileImage: $profileImage)';
  }
}
