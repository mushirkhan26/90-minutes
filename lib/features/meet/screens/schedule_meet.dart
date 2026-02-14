import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/meet/providers/meet_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class ScheduleMeet extends StatefulWidget {
  const ScheduleMeet({super.key});

  @override
  State<ScheduleMeet> createState() => _ScheduleMeetState();
}

class _ScheduleMeetState extends State<ScheduleMeet> {
  bool _isSunday(DateTime date) {
    return date.weekday == DateTime.sunday;
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(
    text: '30',
  );
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _agendaController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _selectedTime;
  String _recurrence = 'One-time meeting';
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final List<EmployeeModel> _selectedParticipants = [];
  bool _showParticipantList = false;
  final List<File> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    context.read<MeetProvider>().fetchUpcomingMeetings(forceRefresh: true);
  }

  Future<void> _loadEmployees() async {
    final employees = await LocalStorageService().getEmployeeList();
    if (employees != null) {
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
      });
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where(
            (e) =>
                e.name.toLowerCase().contains(query.toLowerCase()) ||
                e.employeeID.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  ///  COMBINED DATE + TIME
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// 🔥 VALIDATION: BLOCK PAST TIME (AM/PM BUG FIX)
  bool _isPastDateTime(DateTime selected) {
    return selected.isBefore(DateTime.now());
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (_isSunday(picked)) {
        AlertHelper.snackBarWarning(
          context,
          "Meetings cannot be scheduled on Sundays",
        );
        return;
      }

      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (_isSunday(picked)) {
        AlertHelper.snackBarWarning(
          context,
          "Meetings cannot start on Sundays",
        );
        return;
      }
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      AlertHelper.snackBarWarning(context, "Please select Start Date first");
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (_isSunday(picked)) {
        AlertHelper.snackBarWarning(context, "Meetings cannot end on Sundays");
        return;
      }
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  // Future<void> _pickFiles() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
  //   if (result != null) {
  //     setState(() {
  //       _attachments.addAll(result.paths.map((path) => File(path!)).toList());
  //     });
  //   }
  // }

  // Future<void> _pickFiles() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
  //   if (result != null) {
  //     setState(() {
  //       _attachments.addAll(result.paths.map((path) => File(path!)).toList());
  //     });
  //   }
  // }

  Future<void> _pickFiles() async {
  if (_attachments.length >= 5) {
    AlertHelper.snackBarWarning(
      context,
      "You can upload maximum 5 files only",
    );
    return;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );

  if (result == null) return;

  final pickedFiles = result.paths
      .where((p) => p != null)
      .map((p) => File(p!))
      .toList();

  if (_attachments.length + pickedFiles.length > 5) {
    AlertHelper.snackBarWarning(
      context,
      "You can upload maximum 5 files only",
    );
    return;
  }

  setState(() {
    _attachments.addAll(pickedFiles);
  });
}

  List<DateTime> _calculateRecurrenceDates() {
    List<DateTime> dates = [];
    if (_selectedTime == null) return dates;

    if (_recurrence == 'One-time meeting') {
      if (_selectedDate != null && !_isSunday(_selectedDate!)) {
        dates.add(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          ),
        );
      }
    } else {
      if (_startDate != null && _endDate != null) {
        DateTime current = _startDate!;
        while (current.isBefore(_endDate!) ||
            current.isAtSameMomentAs(_endDate!)) {
          if (!_isSunday(current)) {
            dates.add(
              DateTime(
                current.year,
                current.month,
                current.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              ),
            );
            if (_recurrence == 'Daily') {
              current = current.add(const Duration(days: 1));
            } else if (_recurrence == 'Weekly') {
              current = current.add(const Duration(days: 7));
            } else {
              break;
            }
          }
        }
      }
    }
    return dates;
  }

  Future<void> _scheduleMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_recurrence == 'One-time meeting') {
      if (_selectedDate == null) {
        AlertHelper.snackBarWarning(context, "Please select Date");
        return;
      }
    } else {
      if (_startDate == null || _endDate == null) {
        AlertHelper.snackBarWarning(
          context,
          "Please select both Start and End Date",
        );
        return;
      }
    }

    if (_selectedTime == null) {
      AlertHelper.snackBarWarning(context, "Please select Time");
      return;
    }
    if (_selectedParticipants.isEmpty) {
      AlertHelper.snackBarWarning(
        context,
        "Please add at least one participant",
      );
      return;
    }

    final List<DateTime> scheduledDates = _calculateRecurrenceDates();
    if (scheduledDates.isEmpty) {
      AlertHelper.snackBarWarning(context, "No valid dates to schedule");
      return;
    }

    /// 🔥 AM/PM COMPLETED TIME BLOCK
    for (final date in scheduledDates) {
      if (_isPastDateTime(date)) {
        AlertHelper.snackBarWarning(
          context,
          "Selected time is already completed. Please choose a future time.",
        );
        return;
      }
    }
    final meetProvider = Provider.of<MeetProvider>(context, listen: false);

    // Show loading
    bool allSuccess = true;
    for (var date in scheduledDates) {
      final success = await meetProvider.addMeeting(
        meetLink: _linkController.text,
        description: _titleController.text,
        time: date.toUtc().toIso8601String(), // ✅ Sending as UTC
        participants: _selectedParticipants
            .map((e) => {"employeeId": e.employeeID, "name": e.name})
            .toList(),
        agenda: _agendaController.text,
        duration: int.tryParse(_durationController.text) ?? 30,
      );
      if (!success) allSuccess = false;
    }
    if (allSuccess && mounted) {
      final meetProvider = Provider.of<MeetProvider>(context, listen: false);

      await meetProvider.fetchUpcomingMeetings(forceRefresh: true);

      AlertHelper.snackBarSuccess(
        context,
        "Meeting(s) scheduled successfully!",
      );
      Navigator.pop(context);
    } else if (mounted) {
      AlertHelper.snackBarError(context, "Some meetings failed to schedule.");
    }
  }

  //   if (allSuccess && mounted) {
  //     AlertHelper.snackBarSuccess(
  //       context,
  //       "Meeting(s) scheduled successfully!",
  //     );
  //     Navigator.pop(context);
  //   } else if (mounted) {
  //     AlertHelper.snackBarError(context, "Some meetings failed to schedule.");
  //   }
  // }

  //   if (allSuccess && mounted) {
  //     AlertHelper.snackBarSuccess(
  //       context,
  //       "Meeting(s) scheduled successfully!",
  //     );
  //     Navigator.pop(context);
  //   } else if (mounted) {
  //     AlertHelper.snackBarError(context, "Some meetings failed to schedule.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create New Meeting",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              "Schedule and organize your meeting",
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildLabel("Meeting Title *", Icons.description_outlined),
              // CustomTextField(
              //   controller: _titleController,
              //   hintText: "Enter meeting title",
              // ),
              // _buildLabel("Meeting Title *", Icons.description_outlined),
              // CustomTextField(
              //   controller: _titleController,
              //   hintText: "Enter meeting title",
              // ),
              _buildLabel("Meeting Title *", Icons.description_outlined),
              CustomTextField(
                controller: _titleController,
                hintText: "Enter meeting title",
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Meeting title is required";
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                    return "Only letters are allowed";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildLabel("Recurrence", Icons.bookmark_border),
              DropdownButtonFormField<String>(
                initialValue: _recurrence,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['One-time meeting', 'Daily', 'Weekly'].map((
                  String val,
                ) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(val, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _recurrence = val!;
                  // Reset dates when recurrence changes
                  _selectedDate = null;
                  _startDate = null;
                  _endDate = null;
                  _dateController.clear();
                  _startDateController.clear();
                  _endDateController.clear();
                }),
              ),
              const SizedBox(height: 15),

              if (_recurrence == 'One-time meeting') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Date *", Icons.calendar_today_outlined),
                          CustomTextField(
                            controller: _dateController,
                            hintText: "Select date",
                            readOnly: true,
                            onTap: _pickDate,
                            suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Time *", Icons.access_time),
                          CustomTextField(
                            controller: _timeController,
                            hintText: "Select time",
                            readOnly: true,
                            onTap: _pickTime,
                            suffixIcon: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),

                          const SizedBox(width: 8),
                          Text(
                            "Recurrence Period",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Start Date *",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                CustomTextField(
                                  controller: _startDateController,
                                  hintText: "dd-mm-yyyy",
                                  readOnly: true,
                                  onTap: _pickStartDate,
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "End Date *",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                CustomTextField(
                                  controller: _endDateController,
                                  hintText: "dd-mm-yyyy",
                                  readOnly: true,
                                  onTap: _pickEndDate,
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _buildLabel("Time *", Icons.access_time),
                CustomTextField(
                  controller: _timeController,
                  hintText: "Select time",
                  readOnly: true,
                  onTap: _pickTime,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down),
                ),
              ],

              const SizedBox(height: 15),

              _buildLabel("Duration (min) *", Icons.timer_outlined),
              CustomTextField(
                controller: _durationController,
                hintText: "30",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              if (_calculateRecurrenceDates().length > 1) ...[
                const Text(
                  "Scheduled Instances Preview:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _calculateRecurrenceDates().length,
                    itemBuilder: (context, index) {
                      final date = _calculateRecurrenceDates()[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('MMM dd').format(date),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              DateFormat('EEE').format(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
              ],

              _buildLabel("Participants *", Icons.people_outline),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedParticipants.isEmpty
                              ? "No participants selected"
                              : "${_selectedParticipants.length} selected",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () => setState(
                            () => _showParticipantList = !_showParticipantList,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text("+ Add"),
                        ),
                      ],
                    ),
                    if (_showParticipantList) ...[
                      const Divider(),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Search employee...",
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: InputBorder.none,
                        ),
                        onChanged: _filterEmployees,
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (ctx, i) {
                            final emp = _filteredEmployees[i];
                            final isSel = _selectedParticipants.contains(emp);
                            return CheckboxListTile(
                              title: Text(
                                emp.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              value: isSel,
                              onChanged: (v) => setState(
                                () => v!
                                    ? _selectedParticipants.add(emp)
                                    : _selectedParticipants.remove(emp),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // _buildLabel("Meeting Link *", Icons.link),
              // CustomTextField(
              //   controller: _linkController,
              //   hintText: "https://meet.google.com/...",
              // _buildLabel("Meeting Link *", Icons.link),
              // CustomTextField(
              //   controller: _linkController,
              //   hintText: "https://meet.google.com/...",
              _buildLabel("Meeting Link *", Icons.link),
              CustomTextField(
                controller: _linkController,
                hintText: "https://meet.google.com/...",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Meeting link is required";
                  }
                  if (!_isValidUrl(value.trim())) {
                    return "Please enter a valid meeting URL";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              _buildLabel("Agenda / Summary *", Icons.notes),
              CustomTextField(
                controller: _agendaController,
                hintText: "Enter meeting agenda or summary...",
                maxLines: 3,
              ),
              const SizedBox(height: 15),

              _buildLabel("Attachments", Icons.upload_file),
              const Text(
                "Allowed: PDF, DOC, PPT, XLS, TXT, Images (Max 8MB, 5 files)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _attachments.length >= 5 ? null : _pickFiles,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.grey,
                      ),
                      const Text(
                        "Click to upload files",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Files will be uploaded immediately",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      if (_attachments.isNotEmpty)
                        Text(
                          "${_attachments.length} files selected",
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      if (_attachments.length >= 5)
                        const Text(
                          "Maximum file limit reached",
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Create Meeting",
                  onPressed: _scheduleMeeting,
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
