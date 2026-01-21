import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class OnboardingFormScreen extends StatefulWidget {
  const OnboardingFormScreen({super.key});

  @override
  State<OnboardingFormScreen> createState() => _OnboardingFormScreenState();
}

class _OnboardingFormScreenState extends State<OnboardingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Academic Details
  final _tenthPercentController = TextEditingController();
  final _twelfthPercentController = TextEditingController();
  final _ugPercentController = TextEditingController();
  final _pgPercentController = TextEditingController();

  // Work Details
  String _modeOfWork = 'Onsite';

  // Document Uploads (File names)
  String? _ugMarksheetName;
  String? _photoName;
  String? _resumeName;

  @override
  void dispose() {
    _tenthPercentController.dispose();
    _twelfthPercentController.dispose();
    _ugPercentController.dispose();
    _pgPercentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        if (type == 'ug') _ugMarksheetName = result.files.single.name;
        if (type == 'photo') _photoName = result.files.single.name;
        if (type == 'resume') _resumeName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Onboarding Form', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF26A69A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Details Section
              const Text("Academic Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              _buildLabelTextField("10th Percentage *", _tenthPercentController, "Enter percentage"),
              const SizedBox(height: 15),
              _buildLabelTextField("12th Percentage *", _twelfthPercentController, "Enter percentage"),
              const SizedBox(height: 15),
              _buildLabelTextField("UG Percentage", _ugPercentController, "Enter percentage"),
              const SizedBox(height: 15),
              _buildLabelTextField("PG Percentage", _pgPercentController, "Enter percentage"),

              const SizedBox(height: 25),
              // Work Details Section
              const Text("Work Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              const Text("Mode of Work *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _modeOfWork,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['Onsite', 'Remote', 'Hybrid'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _modeOfWork = newValue!;
                  });
                },
              ),

              const SizedBox(height: 25),
              // Document Uploads Section
              const Text("Document Uploads", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              _buildFileUploadTile("UG Marksheet", _ugMarksheetName, () => _pickFile('ug')),
              const SizedBox(height: 15),
              _buildFileUploadTile("Photo *", _photoName, () => _pickFile('photo')),
              const SizedBox(height: 15),
              _buildFileUploadTile("Resume *", _resumeName, () => _pickFile('resume')),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Submit Onboarding",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_photoName == null || _resumeName == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please upload required documents (Photo & Resume)")),
                        );
                        return;
                      }
                      await authProvider.updateOnboardingStatus(true);
                      if (context.mounted) {
                        context.go(AppRoutes.homeRoute);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hint,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFileUploadTile(String label, String? fileName, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF26A69A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.file_upload, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName ?? "No file selected",
                    style: TextStyle(color: fileName == null ? Colors.grey : Colors.black, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
