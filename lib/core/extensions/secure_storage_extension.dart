import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

extension SecureStorageExtensions on BuildContext {
  /// Get current user's ID from secure storage
  Future<String?> getCurrentUserId() async {
    final userData = await SecureStorageService().getUserData();
    return userData?['employeeId']; // We map userId to employeeId in getUserData for now
  }

  /// Get current user's username from secure storage
  Future<String?> getCurrentUsername() async {
    final userData = await SecureStorageService().getUserData();
    return userData?['username'];
  }

  /// Get current user's data from secure storage
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await SecureStorageService().getUserData();
  }

  /// Get current user's email from secure storage
  Future<String?> getCurrentUserEmail() async {
    final userData = await SecureStorageService().getUserData();
    return userData?['email'];
  }

  /// Get current user's role from secure storage
  Future<String?> getCurrentUserRole() async {
    final userData = await SecureStorageService().getUserData();
    return userData?['role'];
  }
}
