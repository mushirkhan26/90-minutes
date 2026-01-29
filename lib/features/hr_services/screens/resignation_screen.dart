import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResignationScreen extends StatefulWidget {
  const ResignationScreen({super.key});

  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dummy user data (later API nundi vastadi)
  final String employeeId = '26010005';
  final String employeeName = 'VISHNU VARDHAN';
  final String reportingManager = 'Mukilan K';
  final String managerId = '26010001';

  DateTime? resignationDate;
  DateTime? lastWorkingDate;

  final TextEditingController reasonController = TextEditingController();

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  void _pickResignationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        resignationDate = picked;
        lastWorkingDate = picked.add(const Duration(days: 90));
      });
    }
  }

  void _submitResignation() {
    if (!_formKey.currentState!.validate()) return;

    if (resignationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select resignation date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔸 Dummy submit (API later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resignation submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resignation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply Resignation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _readOnlyField('Employee ID', employeeId),
              _readOnlyField('Name', employeeName),
              _readOnlyField('Reporting Manager', reportingManager),
              _readOnlyField('Manager ID', managerId),

              // Resignation Date
              const Text(
                'Resignation Date *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickResignationDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    resignationDate == null
                        ? 'Select date'
                        : dateFormat.format(resignationDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Last Working Date
              const Text(
                'Last Working Date *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  hintText: lastWorkingDate == null
                      ? ''
                      : dateFormat.format(lastWorkingDate!),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Calculated as 90 days from resignation date',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Reason
              const Text(
                'Reason *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: reasonController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Minimum 5 characters required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Brief reason for resignation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitResignation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Submit Resignation',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Experience Letter Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.description_outlined, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your experience letter will be available for download on your last working day after your resignation is accepted.',
                        style: TextStyle(fontSize: 13),
                      ),
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