class EmployeeModel {
  final String name;
  final String employeeID;
  final String? profileImage;
  final String? email;
  final String? mobile;
  final String? alterMobile;
  final String? gender;
  final String? address;

  EmployeeModel({
    required this.name,
    required this.employeeID,
    this.profileImage,
    this.email,
    this.mobile,
    this.alterMobile,
    this.gender,
    this.address,
  });

  /// Creates an `EmployeeModel` from a JSON map.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      name: json['name'] ?? '',
      employeeID: json['employeeID'] ?? '',
      profileImage: json['profileImage'],
      email: json['email'],
      mobile: json['mobile']?.toString(),
      alterMobile: json['alterMobile']?.toString(),
      gender: json['gender'],
      address: json['address'],
    );
  }

  /// Converts the `EmployeeModel` to a JSON map.
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
    };
  }

  @override
  String toString() {
    return '''
EmployeeModel(
  name: $name,
  employeeID: $employeeID,
  profileImage: $profileImage,
  email: $email,
  mobile: $mobile,
  alterMobile: $alterMobile,
  gender: $gender,
  address: $address
)
''';
  }
}
