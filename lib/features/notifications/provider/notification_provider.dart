import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/notification_model.dart';
import 'package:hrtz_hrms/core/api/network/notification_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

enum NotificationState { idle, loading, success, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  final LocalStorageService _local = LocalStorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  
  NotificationState _state = NotificationState.idle;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;
  int _unreadCount = 0;

  NotificationState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    await _fetchInitialData();
  }

  Future<void> _loadFromLocal() async {
    try {
      final cached = await _local.getNotifications();
      if (cached != null) {
        _notifications = cached;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        _state = NotificationState.success;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading notifications from local: $e");
    }
  }

  Future<void> _fetchInitialData() async {
    final employeeId = await _secureStorage.getEmployeeId();
    if (employeeId != null) {
      await fetchNotifications(employeeId);
    }
  }

  Future<void> fetchNotifications(String employeeId) async {
    _state = NotificationState.loading;
    notifyListeners();

    try {
      final response = await _service.getNotifications(employeeId);
      
      if (response.success || (response.data != null && response.data!.isEmpty)) {
        _notifications = response.data ?? [];
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        _state = NotificationState.success;
        _errorMessage = null;
        
        // Save to local storage
        await _local.saveNotifications(_notifications);
      } else {
        _state = _notifications.isNotEmpty ? NotificationState.success : NotificationState.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      if (e.toString().contains("No requests found") || e.toString().contains("404")) {
        _notifications = [];
        _unreadCount = 0;
        _state = NotificationState.success;
        _errorMessage = null;
        await _local.saveNotifications([]);
      } else {
        _state = _notifications.isNotEmpty ? NotificationState.success : NotificationState.error;
        _errorMessage = e.toString();
      }
    }
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _service.markAsRead(notificationId);
      if (response.success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final n = _notifications[index];
          _notifications[index] = NotificationModel(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            createdAt: n.createdAt,
            isRead: true,
            data: n.data,
          );
          _unreadCount = _notifications.where((n) => !n.isRead).length;
          notifyListeners();
          
          // Update cache
          await _local.saveNotifications(_notifications);
        }
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead(String employeeId) async {
    try {
      final response = await _service.markAllAsRead(employeeId);
      if (response.success) {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          data: n.data,
        )).toList();
        _unreadCount = 0;
        notifyListeners();
        
        // Update cache
        await _local.saveNotifications(_notifications);
      }
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }
}
