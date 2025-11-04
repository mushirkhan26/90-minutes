import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/home/screens/leave_screens/leave_request_form_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String _name = '';
  String _employeeId = '';
  Map<String, dynamic>? _leaveHistory;
  Map<String, dynamic>? _availableLeave;
  bool _isLoading = true;

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
    if (_employeeId.isNotEmpty) {
      await _fetchLeaveInfo();
    }
  }

  Future<void> _fetchLeaveInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.fetchLeaveHistory(employeeId: _employeeId);
    await authProvider.fetchAvailableLeave(employeeId: _employeeId);
    setState(() {
      _leaveHistory = authProvider.leaveHistory;
      _availableLeave = authProvider.availableLeave;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            // color: Colors.white,
          ),
        ),
        // centerTitle: true,
        // elevation: 4,
        // backgroundColor: AppColors.background,
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Apply for Leave Button
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 24,
                          ),
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
                // Loading Indicator
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                // Leave Info Section
                if (!_isLoading &&
                    (_availableLeave != null || _leaveHistory != null))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Available Leave Section
                      const Text(
                        'Available Leave',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeaveInfoRow(
                                'Casual/Sick Leave',
                                '${_availableLeave?['leave']?['casualOrSickLeave'] ?? 'N/A'}',
                                Colors.blue,
                              ),
                              const Divider(height: 20, thickness: 1),
                              _buildLeaveInfoRow(
                                'Earned Leave',
                                '${_availableLeave?['leave']?['earnedLeave'] ?? 'N/A'}',
                                Colors.green,
                              ),
                              const Divider(height: 20, thickness: 1),
                              _buildLeaveInfoRow(
                                'Emergency Leave',
                                '${_availableLeave?['leave']?['emergencyLeave'] ?? 'N/A'}',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Leave History Section
                      const Text(
                        'Leave History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_leaveHistory?['message']?['data'] != null)
                                ...(_leaveHistory!['message']['data'] as List)
                                    .map<Widget>(
                                      (leave) => _buildLeaveHistoryCard(
                                        leave,
                                        context,
                                      ),
                                    ),
                              if (_leaveHistory?['message']?['data'] == null ||
                                  (_leaveHistory!['message']['data'] as List)
                                      .isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No leave history found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper method to build leave info rows
Widget _buildLeaveInfoRow(String title, String value, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    ],
  );
}

// Helper method to build leave history cards
Widget _buildLeaveHistoryCard(
  Map<String, dynamic> leave,
  BuildContext context,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leave['type'] ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getLeaveTypeColor(leave['type']),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  leave['leaveStatus'],
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(
                    leave['leaveStatus'],
                  ).withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                leave['leaveStatus'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(leave['leaveStatus']),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildHistoryDetailRow(
          'Date',
          '${leave['startDate']} to ${leave['endDate']}',
        ),
        const SizedBox(height: 4),
        _buildHistoryDetailRow('Duration', '${leave['duration']} day(s)'),
        const SizedBox(height: 4),
        _buildHistoryDetailRow('Reason', leave['reason'] ?? 'N/A'),
        const SizedBox(height: 4),
        if (leave['managerName'] != null)
          _buildHistoryDetailRow('Manager', leave['managerName']),
      ],
    ),
  );
}

// Helper method to build detail rows for history
Widget _buildHistoryDetailRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
      ),
    ],
  );
}

// Helper method to get color based on leave type
Color _getLeaveTypeColor(String? type) {
  switch (type) {
    case 'casualOrSickLeave':
      return Colors.blue;
    case 'earnedLeave':
      return Colors.green;
    case 'emergencyLeave':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

// Helper method to get color based on status
Color _getStatusColor(String? status) {
  switch (status) {
    case 'Approved':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    case 'Waiting':
      return Colors.orange;
    case 'Recalled':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
