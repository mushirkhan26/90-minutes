import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class ScheduleMeet extends StatefulWidget {
  const ScheduleMeet({super.key});

  @override
  State<ScheduleMeet> createState() => _ScheduleMeetState();
}

class _ScheduleMeetState extends State<ScheduleMeet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '30');
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _agendaController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _recurrence = 'One-time meeting';
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final List<EmployeeModel> _selectedParticipants = [];
  bool _showParticipantList = false;
  List<File> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
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
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()) || 
                        e.employeeID.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
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

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  Future<void> _scheduleMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      AlertHelper.snackBarWarning(context, "Please select both Date and Time");
      return;
    }
    if (_selectedParticipants.isEmpty) {
      AlertHelper.snackBarWarning(context, "Please add at least one participant");
      return;
    }

    // 🕒 Fix: Create DateTime and convert to UTC for consistent display across zones
    final DateTime localDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    final meetProvider = Provider.of<MeetProvider>(context, listen: false);
    final success = await meetProvider.addMeeting(
      meetLink: _linkController.text,
      description: _titleController.text,
      time: localDateTime.toUtc().toIso8601String(), // ✅ Sending as UTC
      participants: _selectedParticipants
          .map((e) => {"employeeId": e.employeeID, "name": e.name})
          .toList(),
    );

    if (success && mounted) {
      AlertHelper.snackBarSuccess(context, "Meeting scheduled successfully!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create New Meeting", style: TextStyle(color: Colors.white, fontSize: 16)),
            Text("Schedule and organize your meeting", style: TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Meeting Title *", Icons.description_outlined),
              CustomTextField(controller: _titleController, hintText: "Enter meeting title"),
              const SizedBox(height: 15),
              
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
              const SizedBox(height: 15),

              _buildLabel("Duration (min) *", Icons.timer_outlined),
              CustomTextField(controller: _durationController, hintText: "30", keyboardType: TextInputType.number),
              const SizedBox(height: 15),

              _buildLabel("Recurrence", Icons.bookmark_border),
              DropdownButtonFormField<String>(
                value: _recurrence,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['One-time meeting', 'Daily', 'Weekly'].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (val) => setState(() => _recurrence = val!),
              ),
              const SizedBox(height: 15),

              _buildLabel("Participants *", Icons.people_outline),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedParticipants.isEmpty ? "No participants selected" : "${_selectedParticipants.length} selected", 
                             style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ElevatedButton(
                          onPressed: () => setState(() => _showParticipantList = !_showParticipantList),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                          child: const Text("+ Add"),
                        ),
                      ],
                    ),
                    if (_showParticipantList) ...[
                      const Divider(),
                      TextField(
                        decoration: const InputDecoration(hintText: "Search employee...", prefixIcon: Icon(Icons.search, size: 18), border: InputBorder.none),
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
                              title: Text(emp.name, style: const TextStyle(fontSize: 13)),
                              value: isSel,
                              onChanged: (v) => setState(() => v! ? _selectedParticipants.add(emp) : _selectedParticipants.remove(emp)),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15),

              _buildLabel("Meeting Link *", Icons.link),
              CustomTextField(controller: _linkController, hintText: "https://meet.google.com/..."),
              const SizedBox(height: 15),

              _buildLabel("Agenda / Summary *", Icons.notes),
              CustomTextField(controller: _agendaController, hintText: "Enter meeting agenda or summary...", maxLines: 3),
              const SizedBox(height: 15),

              _buildLabel("Attachments", Icons.upload_file),
              const Text("Allowed: PDF, DOC, PPT, XLS, TXT, Images (Max 8MB, 5 files)", style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickFiles,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
                      const Text("Click to upload files", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text("Files will be uploaded immediately", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      if (_attachments.isNotEmpty) Text("${_attachments.length} files selected", style: const TextStyle(fontSize: 10, color: AppColors.primary)),
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
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
