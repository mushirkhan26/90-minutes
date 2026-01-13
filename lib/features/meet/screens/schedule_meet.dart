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

class ScheduleMeet extends StatefulWidget {
  const ScheduleMeet({super.key});

  @override
  State<ScheduleMeet> createState() => _ScheduleMeetState();
}

class _ScheduleMeetState extends State<ScheduleMeet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final List<EmployeeModel> _selectedParticipants = [];
  bool _showDropdown = false;

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
          .where(
            (e) =>
                e.name.toLowerCase().contains(query.toLowerCase()) ||
                e.employeeID.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

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
        
        if (combined.isBefore(DateTime.now())) {
          if (mounted) {
            AlertHelper.snackBarError(context, "Selected time cannot be in the past.");
          }
          return;
        }
        
        _startTimeController.text = combined.toIso8601String();
      }
    }
  }

  bool _validateFields() {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _linkController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select at least one participant!"),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _scheduleMeeting() async {
    if (!_validateFields()) return;
    final meetProvider = Provider.of<MeetProvider>(context, listen: false);
    final success = await meetProvider.addMeeting(
      meetLink: _linkController.text,
      description: _titleController.text,
      time: _startTimeController.text,
      participants: _selectedParticipants
          .map((e) => {"employeeId": e.employeeID, "name": e.name})
          .toList(),
    );
    if (success) {
      if (mounted) {
        AlertHelper.snackBarSuccess(context, "Meeting scheduled successfully!");
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        AlertHelper.snackBarError(context, "Failed to schedule meeting.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasParticipants = _selectedParticipants.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Schedule Meeting"),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Card(
            color: Colors.white,
            elevation: 10,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text("Title"),
                    CustomTextField(
                      controller: _titleController,
                      hintText: "Enter title",
                      prefixIcon: const Icon(Icons.title),
                    ),
                    const SizedBox(height: 10),
                    const Text("Platform"),
                    CustomTextField(
                      controller: _locationController,
                      hintText: "Platform (Zoom, Meet, Teams)",
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    const SizedBox(height: 10),
                    const Text("Link"),
                    CustomTextField(
                      controller: _linkController,
                      hintText: "Enter link",
                      prefixIcon: const Icon(Icons.link),
                    ),
                    const SizedBox(height: 10),
                    const Text("Participants"),
                    GestureDetector(
                      onTap: () => setState(() => _showDropdown = !_showDropdown),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!hasParticipants)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select Participants',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                ],
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  ..._selectedParticipants.map(
                                    (emp) => Chip(
                                      label: Text(emp.name),
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(emp.name.substring(0, 1).toUpperCase()),
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedParticipants.remove(emp);
                                        });
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _showDropdown = !_showDropdown),
                                    child: const Icon(Icons.add_circle_outline, size: 22),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showDropdown ? 300 : 0,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: .15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _showDropdown
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(Icons.search, size: 20),
                                            hintText: 'Search employee...',
                                            border: InputBorder.none,
                                          ),
                                          onChanged: _filterEmployees,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _showDropdown = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _filteredEmployees.length,
                                    itemBuilder: (context, index) {
                                      final emp = _filteredEmployees[index];
                                      final isSelected = _selectedParticipants.contains(emp);
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(emp.name.substring(0, 1).toUpperCase()),
                                        ),
                                        title: Text(emp.name),
                                        subtitle: Text('ID: ${emp.employeeID}'),
                                        trailing: Icon(
                                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                                          color: isSelected ? Colors.green : Colors.grey,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedParticipants.remove(emp);
                                            } else {
                                              _selectedParticipants.add(emp);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    const Text("Start Time"),
                    CustomTextField(
                      controller: _startTimeController,
                      hintText: "Select start time",
                      prefixIcon: const Icon(Icons.calendar_today),
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
    );
  }
}
