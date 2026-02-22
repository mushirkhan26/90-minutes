import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
// import 'package:hrtz_hrms/features/home/widgets/face_verification.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../provider/clock_provider.dart';
import '../widgets/home_chart.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you really want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (context.mounted) {
                  context.go(AppRoutes.loginRoute);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final clockProvider = Provider.of<ClockProvider>(context);

    // void showFaceVerificationDialog({required bool isClockIn}) {
    //   showDialog(
    //     context: context,
    //     barrierColor: Colors.black.withValues(alpha: 0.5),
    //     builder: (BuildContext context) {
    //       return FaceVerification(
    //         isClockIn: isClockIn,
    //         onVerified: () async {
    //           if (isClockIn) {
    //             await clockProvider.clockIn(
    //               department:
    //                   authProvider.userData?['department'] ?? 'Department',
    //               imageUrl: clockProvider.capturedImageUrl!,
    //             );
    //           } else {
    //             await clockProvider.clockOut();
    //           }
    //           if (context.mounted) {
    //             Navigator.pop(context);
    //             if (clockProvider.state == ClockState.error) {
    //               AlertHelper.snackBarError(
    //                 context,
    //                 clockProvider.errorMessage ?? 'An error occurred',
    //               );
    //             } else {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text(
    //                     isClockIn
    //                         ? 'Clock in successful!'
    //                         : 'Clock out successful!',
    //                   ),
    //                   backgroundColor: Colors.green,
    //                 ),
    //               );
    //             }
    //           }
    //         },
    //       );
    //     },
    //   );
    // }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Home"),
        actions: [Image.asset(AppConstants.logo, height: 60)],
      ),
      drawer: HomeDrawer(
        hostContext: context,
        scaffoldKey: _scaffoldKey,
        onLogout: () => _showLogoutDialog(context, authProvider),
      ),
      body: SingleChildScrollView(
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
                      const Icon(Icons.timer_outlined, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Start Time: ${clockProvider.startTime ?? '00:00:00'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_off_outlined, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'End Time: ${clockProvider.endTime ?? '00:00:00'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Worked Duration: ${clockProvider.workedDuration ?? '00:00:00'}',
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
                    backgroundColor: clockProvider.isClockedIn
                        ? const Color(0xFF64748B) // Light grey when disabled
                        : AppColors.primary,
                    disabledBackgroundColor: const Color(0xFF64748B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  ),

                  onPressed: clockProvider.isClockedIn
                      ? null
                      // : () {
                      //     showFaceVerificationDialog(isClockIn: true);
                      //   },
                      : () async {
                          // showFaceVerificationDialog(isClockIn: true);
                          // comment face recognizaton
                          //
                          await clockProvider.clockIn(
                            department: authProvider.userData?['department'] ?? 'Department',
                            imageUrl: '', // Face recognition is off
                          );
                          if (context.mounted) {
                            if (clockProvider.state == ClockState.error) {
                              AlertHelper.snackBarError(
                                context,
                                clockProvider.errorMessage ?? 'An error occurred',
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Clock in successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  //
                  child: const Text(
                    'Clock In',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !clockProvider.isClockedIn
                        ? const Color(0xFF64748B) // Light grey when disabled
                        : AppColors.primary,
                    disabledBackgroundColor: const Color(0xFF64748B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: !clockProvider.isClockedOut
                      ? () async {
                          await clockProvider.clockOut();
                          if (context.mounted) {
                            if (clockProvider.state == ClockState.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(clockProvider.errorMessage ?? 'An error occurred'),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const HomeChart(),
          ],
        ),
      ),
    );
  }
}
