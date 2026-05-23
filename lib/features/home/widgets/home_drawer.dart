import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:go_router/go_router.dart';

import '../../../config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/services/secure_storage_service.dart';


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

  @override
  Widget build(BuildContext context) {
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
                      colors: [Color(0xFF1D8D85), AppColors.primaryDarkGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '90-min Delivery',
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
                      onTap: () {
                        Navigator.pop(context);
                        widget.hostContext.push(AppRoutes.userProfile);
                      },
                    ),
                     _buildTile(
                      icon: Icons.shopping_bag,
                      title: 'My Orders',
                      onTap: () {
                        Navigator.pop(context);
                        widget.hostContext.push(AppRoutes.ordersRoute);
                      },
                    ),
                    _buildTile(


                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        widget.hostContext.push(AppRoutes.notifications);
                      },
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
