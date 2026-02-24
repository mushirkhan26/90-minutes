import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  final BuildContext hostContext;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.hostContext,
    required this.scaffoldKey,
    required this.onLogout,
  });

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final SecureStorageService _secureStorage = SecureStorageService();

  // Handles close -> navigate -> reopen drawer when user comes back to Home.
  Future<void> _navigateFromDrawer({
    required BuildContext drawerContext,
    required Future<dynamic> Function() action,
  }) async {
    Navigator.of(drawerContext).pop();
    await Future.delayed(const Duration(milliseconds: 120));

    await action();

    if (!widget.hostContext.mounted) return;
    await Future.delayed(const Duration(milliseconds: 80));
    widget.scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userData?['role']?.toString().toLowerCase();
    final isEmployee = userRole != 'manager' && userRole != 'admin';
    final canManagePeople = userRole == 'manager' || userRole == 'admin';
    final canOpenResignationManagement =
        userRole == 'manager' || userRole == 'hr';

    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _secureStorage.getUserData(),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final username = userData?['username'] ?? 'User';

          return Column(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D8D85), AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Initicon(
                            text: " $username",
                            size: 44,
                            backgroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildTile(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.userProfile),
                      ),
                    ),
                    _buildTile(
                      icon: Icons.event_busy,
                      title: 'Leave Request',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.leaveRequest),
                      ),
                    ),
                    _buildTile(
                      icon: Icons.calendar_month,
                      title: 'Holiday Calendar',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.holidayCalendar),
                      ),
                    ),
                    _buildTile(
                      icon: Icons.photo_library_outlined,
                      title: 'Social Hub',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.socialHub),
                      ),
                    ),
                    _buildTile(
                      icon: Icons.task_sharp,
                      title: 'Tasks',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.tasksRoute),
                      ),
                    ),
                    _buildTile(
                      icon: Icons.bar_chart,
                      title: 'Performance',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.performance),
                      ),
                    ),
                    if (!isEmployee)
                      _buildTile(
                        icon: Icons.checklist_rtl_outlined,
                        title: 'Manage Tasks',
                        onTap: () => _navigateFromDrawer(
                          drawerContext: context,
                          action: () =>
                              widget.hostContext.push(AppRoutes.manageTasks),
                        ),
                      ),
                    if (isEmployee)
                      _buildTile(
                        icon: Icons.emoji_events_outlined,
                        title: 'Leaderboard',
                        onTap: () => _navigateFromDrawer(
                          drawerContext: context,
                          action: () =>
                              widget.hostContext.push(AppRoutes.leaderboard),
                        ),
                      ),
                    if (!isEmployee)
                      _buildTile(
                        icon: Icons.emoji_events,
                        title: 'Admin Leaderboard',
                        onTap: () => _navigateFromDrawer(
                          drawerContext: context,
                          action: () => widget.hostContext.push(
                            AppRoutes.adminLeaderboard,
                          ),
                        ),
                      ),
                    if (canManagePeople)
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: const Icon(
                            Icons.groups_2_outlined,
                            color: Colors.black87,
                          ),
                          title: const Text('Team & Employee'),
                          childrenPadding: const EdgeInsets.only(left: 16),
                          children: [
                            _buildTile(
                              icon: Icons.people_alt_outlined,
                              iconColor: Colors.black87,
                              title: 'Employee Directory',
                              onTap: () => _navigateFromDrawer(
                                drawerContext: context,
                                action: () => widget.hostContext.push(
                                  AppRoutes.employeeDirectory,
                                ),
                              ),
                            ),
                            _buildTile(
                              icon: Icons.person_add_alt_1,
                              iconColor: Colors.black87,
                              title: 'New Registrations',
                              onTap: () => _navigateFromDrawer(
                                drawerContext: context,
                                action: () => widget.hostContext.push(
                                  AppRoutes.newRegistrations,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.work_outline,
                          color: Colors.black87,
                        ),
                        title: const Text('HR Services'),
                        childrenPadding: const EdgeInsets.only(left: 16),
                        children: [
                          _buildTile(
                            icon: Icons.person_remove_alt_1,
                            iconColor: Colors.black87,
                            title: 'Resignation',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.resignation,
                                extra: {
                                  'openManagement':
                                      canOpenResignationManagement,
                                },
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.headset_mic,
                            title: 'Service Request',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.serviceRequest,
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.report_problem_outlined,
                            iconColor: Colors.black87,
                            title: 'Complaint',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () =>
                                  widget.hostContext.push(AppRoutes.complaint),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.description_outlined,
                            iconColor: Colors.black87,
                            title: 'Payroll Documents',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.payrollDocuments,
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.assignment_outlined,
                            iconColor: Colors.black87,
                            title: 'HR Employee Task',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.complianceCenter,
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.folder_shared_outlined,
                            iconColor: Colors.black87,
                            title: 'Documents',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.myDocuments,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.school,
                          color: Colors.black87,
                        ),
                        title: const Text('Learning & Growth'),
                        childrenPadding: const EdgeInsets.only(left: 16),
                        children: [
                          _buildTile(
                            icon: Icons.menu_book,
                            iconColor: Colors.black87,
                            title: 'Learning Studio',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.learningStudio,
                              ),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.card_giftcard,
                            iconColor: Colors.black87,
                            title: 'Employee Benefits',
                            onTap: () => _navigateFromDrawer(
                              drawerContext: context,
                              action: () => widget.hostContext.push(
                                AppRoutes.employeeBenefits,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTile(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => _navigateFromDrawer(
                        drawerContext: context,
                        action: () =>
                            widget.hostContext.push(AppRoutes.permissionsRoute),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  widget.onLogout();
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
