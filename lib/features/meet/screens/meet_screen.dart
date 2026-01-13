import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/meet/providers/meet_provider.dart';
import 'package:hrtz_hrms/features/meet/widgets/meet_widget.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

import '../../../config/navigation/app_routes.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meetProvider = Provider.of<MeetProvider>(context, listen: false);
      meetProvider.fetchUpcomingMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetProvider = Provider.of<MeetProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upcoming Meetings', style: AppTextStyles.black16_700),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final meetProvider = Provider.of<MeetProvider>(context, listen: false);
                meetProvider.fetchUpcomingMeetings(forceRefresh: true);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Only show search bar if there are meetings
            if (meetProvider.meetList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomSearchBar(
                  controller: _searchController,
                  enable: true,
                  hintText: 'Search meetings...',
                  onChanged: (query) {
                    meetProvider.searchMeets(query);
                  },
                ),
              ),
            Expanded(
              child: meetProvider.state == MeetState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : meetProvider.meetList.isEmpty
                      ? const Center(child: Text('No upcoming meetings available'))
                      : RefreshIndicator(
                          onRefresh: () => meetProvider.fetchUpcomingMeetings(forceRefresh: true),
                          child: ListView.builder(
                            itemCount: meetProvider.meetList.length,
                            itemBuilder: (context, index) {
                              final meeting = meetProvider.meetList[index];
                              return FutureBuilder<String?>(
                                future: _secureStorage.getEmployeeId(),
                                builder: (context, snapshot) {
                                  final currentUserId = snapshot.data;
                                  return MeetWidget(
                                    meeting: meeting,
                                    showButtons:
                                        currentUserId != null &&
                                        meeting.createdBy['employeeId'] == currentUserId,
                                    onUpdate: () => _showUpdateDialog(context, meeting.id!),
                                    onDelete: () => meetProvider.deleteMeeting(meeting.id!),
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 6,
          onPressed: () => context.pushNamed(AppRoutes.scheduleMeetScreen),
          icon: const Icon(Icons.add, color: Colors.white, size: 22),
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Schedule Meet',
              style: AppTextStyles.black12_400.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String id) {
    final meetProvider = Provider.of<MeetProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Meeting Time'),
        content: const Text('Select a new date and time for this meeting.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null && context.mounted) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  final DateTime combined = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  if (combined.isBefore(DateTime.now())) {
                    if (context.mounted) {
                      AlertHelper.snackBarError(context, "Selected time cannot be in the past.");
                    }
                    return;
                  }

                  final success = await meetProvider.updateMeeting(
                    id: id,
                    time: combined.toIso8601String(),
                  );
                  if (success && context.mounted) {
                    AlertHelper.snackBarSuccess(context, "Meeting updated successfully!");
                    Navigator.pop(context);
                  }
                }
              }
            },
            child: const Text('Select Time & Update'),
          ),
        ],
      ),
    );
  }
}
