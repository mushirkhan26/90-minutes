import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AssignVideoDialog extends StatefulWidget {
  final String subDepartment;

  const AssignVideoDialog({
    super.key,
    required this.subDepartment,
  });

  @override
  State<AssignVideoDialog> createState() => _AssignVideoDialogState();
}

class _AssignVideoDialogState extends State<AssignVideoDialog> {
  final TextEditingController _employeeNameController =
      TextEditingController();
  final TextEditingController _employeeIdController =
      TextEditingController();

  EmployeeModel? selectedEmployee;
  Map<String, dynamic>? selectedCourse;
  DateTime? selectedStartDate;

  @override
  Widget build(BuildContext context) {
    final learningProvider = context.watch<LearningStudioProvider>();
    final authProvider = context.watch<AuthProvider>();

    final courses =
        learningProvider.getCourses(widget.subDepartment);
    final employees = authProvider.employeeList ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assign Video to Employee',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26A69A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 16),

            // ===== EMPLOYEE NAME =====
            const Text('Employee Name *'),
            const SizedBox(height: 6),
            DropdownButtonFormField2<EmployeeModel>(
              isExpanded: true,
              hint: const Text('Select employee'),
              value: selectedEmployee,
              items: employees.map((emp) {
                return DropdownMenuItem<EmployeeModel>(
                  value: emp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emp.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                        'ID: ${emp.employeeID}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return employees.map((emp) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(emp.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  );
                }).toList();
              },
              onChanged: (emp) {
                setState(() {
                  selectedEmployee = emp;
                  _employeeNameController.text = emp!.name;
                  _employeeIdController.text = emp.employeeID;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 260,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // ===== COURSE NAME =====
            const Text('Course Name *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: selectedCourse,
              hint: const Text('Select a course'),
              items: courses.map((course) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: course,
                  child: Text(course['courseName'] ?? ''),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedCourse = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ===== EMPLOYEE ID =====
            const Text('Employee ID *'),
            const SizedBox(height: 6),
            TextField(
              controller: _employeeIdController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Auto-filled',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ===== COURSE STATUS =====
            const Text('Course Status *'),
            const SizedBox(height: 6),
            TextField(
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                hintText: 'NotStarted',
              ),
            ),

            const SizedBox(height: 12),

            // ===== START DATE + TIME  =====
            const Text('Start Date *'),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
          
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2035),
                );
          

                if ( !context.mounted || pickedDate == null) return;
                

                final pickedTime = await showTimePicker(
                  
                
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if ( pickedTime == null) return;
                if(!mounted) return;

                setState(() {
                  selectedStartDate = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  selectedStartDate == null
                      ? 'Select start date'
                      : "${selectedStartDate!.day.toString().padLeft(2, '0')}-"
                        "${selectedStartDate!.month.toString().padLeft(2, '0')}-"
                        "${selectedStartDate!.year} "
                        "${selectedStartDate!.hour.toString().padLeft(2, '0')}:"
                        "${selectedStartDate!.minute.toString().padLeft(2, '0')}",
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== ACTION BUTTONS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                  ),
                  onPressed: _canAssign()
                      ? () async {
                      
                        final provider = context.read<LearningStudioProvider>();
                          final success =
                              await provider.assignCourseToEmployee(
                                  
                            name: _employeeNameController.text,
                            courseName:
                                selectedCourse!['courseName'],
                            courseId:
                                selectedCourse!['courseId'],
                            employeeId:
                                _employeeIdController.text,
                            startDate: selectedStartDate,
                          );
                          if(!context.mounted) return;

                          if (success) {
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text(
                    'Assign',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canAssign() {
    return selectedEmployee != null &&
        selectedCourse != null &&
        selectedStartDate != null;
  }

  @override
  void dispose(){
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }
}