import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/resignation_provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class ResignationScreen extends StatefulWidget {
  const ResignationScreen({super.key});

  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reasonController = TextEditingController();

  DateTime? resignationDate;
  DateTime? lastWorkingDate;

  final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat uiDateFormat = DateFormat('dd/MM/yyyy');

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (resignationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select resignation date')),
      );
      return;
    }

    final provider = context.read<ResignationProvider>();

    final success = await provider.submitResignation(
      resignationDate: apiDateFormat.format(resignationDate!),
      reason: reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resignation submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            filled: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resignationProvider = context.watch<ResignationProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resignation'),
        backgroundColor: const Color(0xFF2F9E9E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

                /// ✅ AUTO-FILL FROM LOGIN (NO STATIC VALUES)
                _readOnlyField(
                  'Employee ID',
                  authProvider.userData?['employeeId'] ?? '-',
                ),

                _readOnlyField(
                  'Name',
                  authProvider.userData?['username'] ?? '-',
                ),

                /// 📅 Resignation Date
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
                          : uiDateFormat.format(resignationDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// 📆 Last Working Date
                const Text(
                  'Last Working Date *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    border: const OutlineInputBorder(),
                    hintText: lastWorkingDate == null
                        ? ''
                        : apiDateFormat.format(lastWorkingDate!),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Calculated as 90 days from resignation date',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                /// ✍️ Reason
                const Text(
                  'Reason *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: reasonController,
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.trim().length < 5
                          ? 'Minimum 5 characters required'
                          : null,
                  decoration: const InputDecoration(
                    hintText:
                        'Brief reason for resignation (minimum 5 characters)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                /// 🚀 Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        resignationProvider.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F9E9E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: resignationProvider.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Resignation',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ℹ️ Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
      ),
    );
  }
}