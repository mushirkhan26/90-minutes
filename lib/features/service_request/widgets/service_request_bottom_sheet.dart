import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';
import 'package:hrtz_hrms/features/service_request/screens/request_details_screen.dart';
import 'package:hrtz_hrms/features/service_request/widgets/service_request_model.dart';
import 'package:provider/provider.dart';


class ServiceRequestBottomSheet extends StatelessWidget {
  final ServiceRequest request;
  final int requestIndex;

  const ServiceRequestBottomSheet({
    super.key,
    required this.request,
    required this.requestIndex,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildRequestInfo(),
                  const SizedBox(height: 20),
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  _buildViewDetailsButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.computer, color: Colors.white),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Request #$requestIndex',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= PROFILE =================
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha:  0.15),
          child: Text(
            request.name.isNotEmpty ? request.name[0].toUpperCase() : '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          request.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          request.department,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip(),
            const SizedBox(width: 8),
            _buildTypeChip(),
          ],
        ),
      ],
    );
  }

  // ================= REQUEST INFO =================
  Widget _buildRequestInfo() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Request Information',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: 12),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Type
            const Text(
              'Request Type',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              request.type,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            // Date Submitted
            const Text(
              'Date Submitted',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'N/A',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'Description',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(request.description),
            ),

            const SizedBox(height: 16),

            // Attachment
          
const Text(
  'Attachment',
  style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 8),

if (request.attachmentUrl.isEmpty)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Text(
      'No attachment available',
      style: TextStyle(color: Colors.grey),
    ),
  )
else
  Column(
    children: request.attachmentUrl.map((url) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16/9,
          
          child: Image.network(
            url,
            
            fit: BoxFit.cover,
          ),
          ),
        ),
      );
    }).toList(),
  ),
          ],
        ),
      ),
    ],
  );
}
  // ================= CONTACT INFO =================
  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        _infoCard(
          children: [
            _contactRow(Icons.email, 'Email', request.email),
            _contactRow(Icons.call, 'Mobile', request.mobile),
            _contactRow(Icons.badge, 'Employee ID', request.employeeId),
          ],
        ),
      ],
    );
  }

  // ================= BUTTON =================
  Widget _buildViewDetailsButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<ServiceRequestProvider>(),
              child: RequestDetailScreen(request: request),

            )
          ),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'View Full Details',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

  // ================= HELPERS =================
  Widget _infoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha:  0.15),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _statusBgColor(request.requestStatus),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      request.requestStatus,
      style: TextStyle(
        color: _statusTextColor(request.requestStatus),
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:  0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.computer,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            request.type,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Color _statusBgColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green.shade100;
    case 'waiting':
    case 'pending':
      return Colors.grey.shade300;
    case 'rejected':
      return Colors.red.shade100;
    default:
      return Colors.grey.shade300;
  }
}

Color _statusTextColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green.shade800;
    case 'waiting':
    case 'pending':
      return Colors.grey.shade800;
    case 'rejected':
      return Colors.red.shade800;
    default:
      return Colors.grey.shade800;
  }
}
}