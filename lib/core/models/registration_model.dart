class RegistrationModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String appliedOn;
  final String department;
  final String position;
  final String experience; // Changed to String to match API
  final String status;
  final String address;
  final String reference;

  RegistrationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.appliedOn,
    required this.department,
    required this.position,
    required this.experience,
    required this.status,
    required this.address,
    required this.reference,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['_id'] ?? json['id'] ?? '', // Handling MongoDB _id
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['mobile']?.toString() ?? '', // JSON uses 'mobile'
      gender: json['gender'] ?? 'Select',
      dob: json['DOB'] ?? json['dob'] ?? '', // JSON uses 'DOB'
      appliedOn: json['appliedDate'] ?? json['appliedOn'] ?? '', // JSON uses 'appliedDate'
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      experience: json['experience']?.toString() ?? '0', // Safely convert to String
      status: json['status'] ?? 'Pending',
      address: json['address'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'appliedOn': appliedOn,
      'department': department,
      'position': position,
      'experience': experience,
      'status': status,
      'address': address,
      'reference': reference,
    };
  }
}
