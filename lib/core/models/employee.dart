class Employee {
  final String name;
  final String employeeId;
  final String? profileImage;

  Employee({
    required this.name,
    required this.employeeId,
    required this.profileImage,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'],
      employeeId: json['employeeID'],
      profileImage: json['profileImage'],
    );
  }
  Map<String, dynamic> toJson() {
    final data = {'name': name, 'employeeID': employeeId};
    return data;
  }
}
