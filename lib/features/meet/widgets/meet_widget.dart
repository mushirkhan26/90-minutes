import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/models/meet_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

class MeetWidget extends StatefulWidget {
  final Meet meeting;
  final bool showButtons;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const MeetWidget({
    super.key,
    required this.meeting,
    this.showButtons = false,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<MeetWidget> createState() => _MeetWidgetState();
}

class _MeetWidgetState extends State<MeetWidget> {
  bool _isExpanded = false;

  String _formatDateTime(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

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
                    widget.meeting.description,
                    style: AppTextStyles.black16_700.copyWith(color: AppColors.grey5C5C5C),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.meeting.time),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(widget.meeting.time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Created By
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Created by: ${widget.meeting.createdBy['name']}",
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
                    "Starts at: ${_formatDateTime(widget.meeting.time)}",
                    style: AppTextStyles.grey12_600.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Meeting Link (Clickable)
              GestureDetector(
                onTap: () => _launchUrl(widget.meeting.meetLink),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.meeting.meetLink,
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
              // Participants Dropdown Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Participants (${widget.meeting.participants.length})",
                      style: AppTextStyles.black14_600,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              // Expanded Participants List
              if (_isExpanded)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      ...widget.meeting.participants.map(
                        (participant) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  participant['name']!.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(participant['name']!, style: AppTextStyles.black12_400),
                              const SizedBox(width: 8),
                              Text(
                                "(${participant['employeeId']})",
                                style: AppTextStyles.greyAAAAAA_10_400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Actions (Update, Delete)
              if (widget.showButtons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: widget.onUpdate,
                      child: Image.asset(AppConstants.updateIcon, height: 40, width: 40),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Meeting"),
                            content: const Text("Are you sure you want to delete this meeting?"),
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
                        if (confirmed == true && widget.onDelete != null) {
                          widget.onDelete!();
                        }
                      },
                      child: Image.asset(AppConstants.deleteIcon, height: 40, width: 40),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      return AppColors.activeGreen; // Completed
    } else {
      return Colors.amber; // Scheduled
    }
  }

  String _getStatusText(String isoDateTime) {
    final dateTime = DateTime.parse(isoDateTime);
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      return "Completed";
    } else {
      return "Scheduled";
    }
  }
}
