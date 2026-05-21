class UserModel {
  final String? id; // MongoDB _id
  final String name;
  final String userId;
  final String? profileImage;
  final String? email;
  final String? mobile;
  final String? address;
  final String? role;

  UserModel({
    this.id,
    required this.name,
    required this.userId,
    this.profileImage,
    this.email,
    this.mobile,
    this.address,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      userId: json['employeeID']?.toString() ?? json['employeeId']?.toString() ?? json['userId']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'profileImage': profileImage,
      'email': email,
      'mobile': mobile,
      'address': address,
      'role': role,
    };
  }
}
