import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';

class ScheduleMeet extends StatefulWidget {
  const ScheduleMeet({super.key});

  @override
  State<ScheduleMeet> createState() => _ScheduleMeetState();
}

class _ScheduleMeetState extends State<ScheduleMeet> {
  // From here...........................................................................
  Future<void> _selectDateTime(BuildContext context) async {
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
        _startTimeController.text = combined.toIso8601String();
      }
    }
  }

  Future<void> _scheduleMeeting() async {
    // if (!_validateFields()) return;

    // final meetingManagement = Provider.of<MeetingManagement>(context, listen: false);
    // final success = await meetingManagement.createMeeting(
    // title: _titleController.text,
    // location: _locationController.text,
    // link: _linkController.text,
    // startTime: _startTimeController.text,
    // );

    // if (success) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Meeting scheduled successfully!")),
    //     );
    //     Navigator.pop(context);
    //   }
    // } else {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Failed to schedule meeting.")),
    //     );
    //   }
    // }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();

  //  To here...................................................................................
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Schedule Meeting"),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        ),
        body:
            // meetingManagement.isLoading
            //     ? const Center(child: CircularProgressIndicator())
            //     :
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      // key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text("Title"),
                          CustomTextField(
                            controller: _titleController,
                            hintText: "Enter title",
                            prefixIcon: const Icon(Icons.title),
                            // errorText: _titleError,
                          ),
                          const SizedBox(height: 10),
                          const Text("Platform"),
                          CustomTextField(
                            controller: _locationController,
                            hintText: "Platform(Zoom, meet, teams) ",
                            prefixIcon: const Icon(Icons.location_on),
                            // errorText: _locationError,
                          ),
                          const SizedBox(height: 10),
                          const Text("Link"),
                          CustomTextField(
                            controller: _linkController,
                            hintText: "Enter link",
                            prefixIcon: const Icon(Icons.link),
                            // errorText: _linkError,
                          ),
                          const SizedBox(height: 10),
                          const Text("Start Time"),
                          CustomTextField(
                            controller: _startTimeController,
                            hintText: "Select start time",
                            prefixIcon: const Icon(Icons.calendar_today),
                            // errorText: _startTimeError,
                            readOnly: true,
                            onTap: () => _selectDateTime(context),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: _scheduleMeeting,
                            fontSize: 18,
                            backgroundColor: AppColors.primary,
                            text: "Schedule Meeting",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
