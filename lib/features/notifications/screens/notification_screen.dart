import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/notifications/provider/notification_provider.dart';
import 'package:hrtz_hrms/features/notifications/widgets/notification_action_bar.dart';
import 'package:hrtz_hrms/features/notifications/widgets/notification_empty_state.dart';
import 'package:hrtz_hrms/features/notifications/widgets/notification_header.dart';
import 'package:hrtz_hrms/features/notifications/widgets/notification_list_item.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _handleRefresh(BuildContext context) async {
    final employeeId =
        context.read<AuthProvider>().userData?['employeeId']?.toString();
    if (employeeId != null) {
      await context.read<NotificationProvider>().fetchNotifications(employeeId);
      if (context.mounted) {
        final provider = context.read<NotificationProvider>();
        if (provider.state == NotificationState.error) {
          AlertHelper.snackBarError(
              context, provider.errorMessage ?? "Failed to fetch notifications");
        }
      }
    }
  }

  void _handleClear(BuildContext context) async {
    final employeeId =
        context.read<AuthProvider>().userData?['employeeId']?.toString();
    if (employeeId != null) {
      await context.read<NotificationProvider>().markAllAsRead(employeeId);
      if (context.mounted) {
        AlertHelper.snackBarSuccess(context, "Notifications cleared successfully");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const NotificationHeader(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      NotificationActionBar(
                        provider: provider,
                        onRefresh: () => _handleRefresh(context),
                        onClear: () => _handleClear(context),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildContent(provider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(NotificationProvider provider) {
    if (provider.state == NotificationState.loading &&
        provider.notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF14B8A6)),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return NotificationListItem(
          notification: notification,
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
          },
        );
      },
    );
  }
}
