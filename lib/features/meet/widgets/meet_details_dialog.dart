import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/meet_model.dart';
import 'package:hrtz_hrms/features/meet/providers/meet_provider.dart';
import 'package:hrtz_hrms/features/meet/widgets/cancel_meeting_dialog.dart'; // 🚀 Imported new dialog
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetDetailsDialog extends StatelessWidget {
  final Meet meeting;
  const MeetDetailsDialog({super.key, required this.meeting});

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(meeting.time).toLocal();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
    final startTime = DateFormat('h:mm a').format(dateTime);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meeting.description,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(formattedDate, 
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInfoCard(Icons.access_time, 'Start Time', startTime)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfoCard(Icons.timer_outlined, 'Duration', '${meeting.duration} min')),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Organizer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(meeting.createdBy['name']?[0] ?? '?', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(meeting.createdBy['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                subtitle: Text('ID: ${meeting.createdBy['employeeId']}', overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 10),
              Text('Participants (${meeting.participants.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              ...meeting.participants.map((p) => _buildParticipantTile(
                p['name']?[0] ?? '?', 
                p['name'] ?? '', 
                '', 
                p['employeeId'] ?? ''
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(meeting.meetLink),
                  icon: const Icon(Icons.launch, color: Colors.white),
                  label: const Text('Join Meeting', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 🚀 Now calling the beautiful new Cancel dialog from image
                    showDialog(
                      context: context,
                      builder: (context) => CancelMeetingDialog(
                        onConfirm: () async {
                          await context.read<MeetProvider>().deleteMeeting(meeting.id!);
                          if (context.mounted) Navigator.pop(context); // Close details dialog
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Cancel Meeting', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Status: Scheduled   Meeting ID: ${meeting.id?.toUpperCase() ?? "N/A"}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(String initials, String name, String email, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: .1),
            child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(id, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
