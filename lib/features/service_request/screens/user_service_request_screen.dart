import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';
import 'package:hrtz_hrms/features/service_request/widgets/service_request_model.dart';

class UserServiceRequestScreen extends StatelessWidget {
  const UserServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Service Requests'),
      ),
      body: ListView(
        children: [
          _helpHeader(),
          _requestTypes(),
          const SizedBox(height: 16),
          _previousRequests(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _helpHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFDFF7F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for Requests',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= REQUEST TYPES =================
  Widget _requestTypes() {
    final types = [
      'Hardware',
      'Software',
      'Backup',
      'Maintenance',
      'Security',
      'Document',
      'Others',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: types
            .map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const Text(
                          'Click here if you need help',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ================= PREVIOUS REQUESTS =================
  Widget _previousRequests() {
    return Consumer<ServiceRequestProvider>(
      builder: (_, provider, __) {
        final myRequests = provider.allRequests; // ideally user-filtered

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Previous Requests',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...myRequests.map((r) => _requestCard(r)),
            ],
          ),
        );
      },
    );
  }

  Widget _requestCard(ServiceRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.type,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Status: ${r.requestStatus}',
              style: const TextStyle(color: Colors.blue)),
          const SizedBox(height: 4),
          Text('Employee ID: ${r.employeeId}'),
          Text('Description: ${r.description}'),
        ],
      ),
    );
  }
}