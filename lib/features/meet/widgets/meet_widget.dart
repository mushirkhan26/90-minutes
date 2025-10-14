import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MeetWidget extends StatelessWidget {
  const MeetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meeting Title',
                    // meeting.title,
                    style: AppTextStyles.black16_700.copyWith(
                      color: AppColors.grey5C5C5C,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // color: meeting.status == "cancelled"
                      //     ? AppColors.errorRed.withOpacity(0.8)
                      //     : meeting.status == "completed"
                      //         ? AppColors.activeGreen
                      //         : meeting.status == "scheduled"
                      //             ? Colors.amber
                      //             : Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Meeting Status',
                      // meeting.status,
                      style: TextStyle(
                        fontSize: 12,
                        // color: meeting.status == meeting.status
                        //     ? Colors.white
                        //     : Colors.white70.withOpacity(1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location and Platform
              Row(
                children: [
                  const Icon(
                    Icons.location_searching_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Meeting Location',
                    // meeting.location
                    style: AppTextStyles.black14_600,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Start Time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    ' Meet Starting Time',
                    // "Starts at: ${_formatDateTime(meeting.startTime)}",
                    style: AppTextStyles.grey12_600.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Scheduled By
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Meet Sceduled by',
                    // "Scheduled by: ${meeting.scheduledPerson.name}",
                    style: AppTextStyles.black12_700,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Meeting Link (Clickable)
              GestureDetector(
                // onTap: () => _launchUrl(meeting.link),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Meet Link",
                        // meeting.link,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.blue00ABE9,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Participants
              // Row(
              //   children: [
              //     const Icon(Icons.people, size: 16, color: Colors.grey),
              //     const SizedBox(width: 4),
              //     Text(
              //       "Participants: ${meeting.participants.length}",
              //       style: AppTextStyles.black10_500,
              //     ),
              //   ],
              // ),

              // Actions (Update, Delete)
              Visibility(
                // visible: showButtons,
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to update screen or show update dialog
                        // _showUpdateDialog(context, meetingManagement, meeting);
                      },
                      child: Image.asset(
                        AppConstants.updateIcon,
                        height: 40,
                        width: 40,
                      ),
                      // CustomButton(
                      //   height: 40,
                      //   image: Image.asset('assets/icons/updated.png'),
                      //   text: "",
                      //   backgroundColor: Colors.white,
                      //   textColor: AppColors.activeGreen.withValues(alpha: 0.3),
                      //   borderColor: AppColors.greyD9D9D9,
                      //   onPressed: () {
                      //     // Navigate to update screen or show update dialog
                      //     _showUpdateDialog(context, meetingManagement, meeting);
                      //   },
                      // ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Meeting"),
                            content: const Text(
                              "Are you sure you want to delete this meeting?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        // if (confirmed == true) {
                        //   await meetingManagement.deleteMeeting(meeting.id);
                        // }
                      },
                      child: Image.asset(
                        AppConstants.deleteIcon,
                        height: 40,
                        width: 40,
                      ),
                      // child: CustomButton(
                      //   height: 40,
                      //   text: "Delete",
                      //   backgroundColor: Colors.white,
                      //   borderColor: AppColors.redF11515,
                      //   textColor: AppColors.redF11515,
                      // onPressed: () async {
                      //   final confirmed = await showDialog<bool>(
                      //     context: context,
                      //     builder: (context) => AlertDialog(
                      //       title: const Text("Delete Meeting"),
                      //       content: const Text(
                      //           "Are you sure you want to delete this meeting?"),
                      //       actions: [
                      //         TextButton(
                      //           onPressed: () => Navigator.pop(context, false),
                      //           child: const Text("Cancel"),
                      //         ),
                      //         TextButton(
                      //           onPressed: () => Navigator.pop(context, true),
                      //           child: const Text("Delete"),
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      //   if (confirmed == true) {
                      //     await meetingManagement.deleteMeeting(meeting.id);
                      //   }
                      // },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
