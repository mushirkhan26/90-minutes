import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/features/leave/provider/leave_provider.dart';
import 'leave_request_form_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _name = '';
  String _employeeId = '';

  @override
  void initState() {
    super.initState();
    _loadEmployeeDetails();
  }

  Future<void> _loadEmployeeDetails() async {
    final secureStorage = SecureStorageService();
    final userData = await secureStorage.getUserData();
    setState(() {
      _name = userData?['username'] ?? '';
      _employeeId = userData?['employeeId'] ?? '';
    });
    if (_employeeId.isNotEmpty && mounted) {
      context.read<LeaveProvider>().fetchLeaveInfo(employeeId: _employeeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, leaveProvider, child) {
          final leaveHistory = leaveProvider.leaveHistory;
          final availableLeave = leaveProvider.availableLeave;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Apply for Leave Button
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveRequestFormScreen(
                              name: _name,
                              employeeId: _employeeId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xff009990), Color(0xff02A6A6)],
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 24),
                            SizedBox(width: 10),
                             Text(
                              'Apply for Leave',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (leaveProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (availableLeave != null) ...[
                          const Text(
                            'Available Leave',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildLeaveInfoRow('Casual/Sick Leave', '${availableLeave['available']?['casualOrSickLeave'] ?? 0}', Colors.blue),
                                  const Divider(),
                                  _buildLeaveInfoRow('Earned Leave', '${availableLeave['available']?['earnedLeave'] ?? 0}', Colors.green),
                                  const Divider(),
                                  _buildLeaveInfoRow('Emergency Leave', '${availableLeave['available']?['emergencyLeave'] ?? 0}', Colors.orange),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        const Text(
                          'Leave History',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (leaveHistory?['message']?['data'] != null && (leaveHistory!['message']['data'] as List).isNotEmpty)
                          ...(leaveHistory['message']['data'] as List).map((leave) => _buildLeaveHistoryCard(leave))
                        else
                          const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No leave history found'),
                          )),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaveInfoRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildLeaveHistoryCard(Map<String, dynamic> leave) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leave['type'] ?? 'Leave', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(leave['leaveStatus'] ?? 'Pending', style: TextStyle(color: _getStatusColor(leave['leaveStatus']), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${leave['startDate']} to ${leave['endDate']}'),
            Text('Duration: ${leave['duration']} Day(s)'),
            Text('Reason: ${leave['reason'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Waiting': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
