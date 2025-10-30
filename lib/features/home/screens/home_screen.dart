import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/clock/screens/face_verification.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../clock/provider/clock_provider.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final clockProvider = Provider.of<ClockProvider>(context);
    final secureStorage = SecureStorageService();

    void showFaceVerificationDialog({required bool isClockIn}) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext context) {
          return FaceVerification(
            isClockIn: isClockIn,
            onVerified: () async {
              if (isClockIn) {
                await clockProvider.clockIn(
                  department:
                      authProvider.userData?['department'] ?? 'Department',
                  imageUrl:
                      'https://task-m.s3.us-east-1.amazonaws.com/1761370008430-face-verification-176137000425.jpg',
                );
              } else {
                await clockProvider.clockOut();
              }
              if (context.mounted) {
                Navigator.pop(context);
                if (clockProvider.state == ClockState.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        clockProvider.errorMessage ?? 'An error occurred',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isClockIn
                            ? 'Clock in successful!'
                            : 'Clock out successful!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Home'),
            const Spacer(),
            Image.asset(AppConstants.logo, height: 40),
          ],
        ),
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: secureStorage.getUserData(),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: AppColors.primary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Initicon(text: " ${userData?['username'] ?? 'User'}"),
                      const SizedBox(width: 8),
                      const SizedBox(height: 20),
                      InkWell(
                        // onTap: () {
                        //   if (userData != null) {
                        //     showUserDetailsDialog(context, userData);
                        //   }
                        // },
                        child: Text(
                          'Welcome ${userData?['username'] ?? 'User'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 340),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.userProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    context.goToPermissions();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go(AppRoutes.loginRoute);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome ${authProvider.userData?['username'] ?? 'User'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Team: ${authProvider.userData?['team'] ?? 'Mukilan K'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Employee ID: ${authProvider.userData?['employeeId'] ?? '24110002'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Position: ${authProvider.userData?['position'] ?? 'Software Engineer'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Start Time: ${clockProvider.startTime ?? '12:59:28'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_off_outlined,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'End Time: ${clockProvider.endTime ?? '12:59:35'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Worked Duration: ${clockProvider.workedDuration ?? '00:00:06'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    showFaceVerificationDialog(isClockIn: true);
                  },
                  child: const Text(
                    'Clock In',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: clockProvider.isClockedIn
                        ? AppColors.gray475467
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: clockProvider.isClockedIn
                      ? () async {
                          await clockProvider.clockOut();
                          if (context.mounted) {
                            if (clockProvider.state == ClockState.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    clockProvider.errorMessage ??
                                        'An error occurred',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Clock out successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text(
                    'Clock Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
