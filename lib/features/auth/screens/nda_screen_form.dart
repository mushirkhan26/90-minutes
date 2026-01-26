import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class NdaScreen extends StatefulWidget {
  const NdaScreen({super.key});

  @override
  State<NdaScreen> createState() => _NdaScreenState();
}

class _NdaScreenState extends State<NdaScreen> {
  bool _isAccepted = false;
  final _formKey = GlobalKey<FormState>();

  // Employee Details Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _employeeIdController;
  late TextEditingController _emailController;
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _signatureDateController = TextEditingController();

  String? _signatureFileName;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;

    _fullNameController = TextEditingController(text: userData?['username'] ?? '');
    _employeeIdController = TextEditingController(text: userData?['employeeId'] ?? '');
    _emailController = TextEditingController(text: userData?['email'] ?? '');

    // Prefill signature date with today's date
    final now = DateTime.now();
    _signatureDateController.text = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _joiningDateController.dispose();
    _signatureDateController.dispose();
    super.dispose();
  }

  Future<void> _pickSignature() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _signatureFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NON-DISCLOSURE AGREEMENT (NDA)', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "HRZWORKZ PRIVATE LIMITED",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 15),
              _buildNdaText(),
              const SizedBox(height: 25),

              // Employee Details Section
              const Text("Employee Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 15),
              _buildLabelTextField("Full Name *", _fullNameController, "Full Name", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Employee ID *", _employeeIdController, "Employee ID", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Email *", _emailController, "Email", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Position *", _positionController, "Position"),
              const SizedBox(height: 15),
              _buildLabelTextField("Department *", _departmentController, "Department"),
              const SizedBox(height: 15),
              _buildDatePickerField("Date of Joining *", _joiningDateController),

              const SizedBox(height: 30),
              // NDA Acknowledgement Section
              const Text("NDA Acknowledgement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "By signing below, you confirm that you have read, understood, and agreed to all terms and conditions outlined in the Non-Disclosure Agreement above.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildSignatureUploadField(),
              const SizedBox(height: 15),
              _buildDatePickerField("Employee Signature Date *", _signatureDateController, enabled: false),
              const SizedBox(height: 8),
              const Text(
                "Instructions: Sign on a white sheet using a dark pen. Scan or photograph the signature ensuring the background is clean and well-lit. Avoid shadows; crop tightly around the signature.",
                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isAccepted,
                    onChanged: (value) => setState(() => _isAccepted = value ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      "I have carefully read the above NDA and agree to abide by its terms regarding confidentiality, employment commitment, and prohibition of disclosure.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Submit NDA",
                  onPressed: _isAccepted
                      ? () async {
                    if (_formKey.currentState!.validate() && _signatureFileName != null) {
                      await authProvider.updateNdaStatus(true);
                      if (context.mounted) {
                        if (!authProvider.onboardingCompleted) {
                          context.go(AppRoutes.onboardingRoute);
                        } else {
                          context.go(AppRoutes.homeRoute);
                        }
                      }
                    } else if (_signatureFileName == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please upload your signature")),
                      );
                    }
                  }
                      : null,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNdaText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _NdaPoint(title: "1. Confidential Information", content: "The Employee agrees to maintain the confidentiality of all proprietary, client-related, and sensitive information encountered during their employment. Confidential information includes, but is not limited to, trade secrets, business plans, client details, technical data, and internal processes."),
        SizedBox(height: 10),
        _NdaPoint(title: "2. Employment Commitment", content: "The Employee agrees to provide a two-month notice period before resigning from their position. This notice period is required to ensure proper knowledge transfer and facilitate the hiring or training of a suitable replacement for the role."),
        SizedBox(height: 10),
        _NdaPoint(title: "3. Prohibition of Disclosure", content: "The Employee shall not share any confidential information with unauthorized parties during or after their employment."),
        SizedBox(height: 10),
        _NdaPoint(title: "4. Intellectual Property", content: "All intellectual property created during the Employee's tenure, including but not limited to software, applications, and designs, is the sole property of Hrzworkz Private Limited."),
        SizedBox(height: 10),
        _NdaPoint(title: "5. Legal Compliance", content: "Any breach of this Agreement may result in disciplinary action, including but not limited to termination of employment and legal proceedings."),
      ],
    );
  }

  Widget _buildLabelTextField(String label, TextEditingController controller, String hint, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hint,
          enabled: enabled,
          backgroundColor: enabled ? Colors.white : Colors.grey.shade100,
          validator: (value) {
            if (!enabled) return null;
            return (value == null || value.isEmpty) ? 'Required' : null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: "DD-MM-YYYY",
          readOnly: true,
          enabled: enabled,
          backgroundColor: enabled ? Colors.white : Colors.grey.shade100,
          suffixIcon: enabled ? const Icon(Icons.calendar_today, size: 18) : null,
          onTap: enabled ? () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
              });
            }
          } : null,
          validator: (value) {
            if (!enabled) return null;
            return (value == null || value.isEmpty) ? 'Required' : null;
          },
        ),
      ],
    );
  }

  Widget _buildSignatureUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Employee Signature *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickSignature,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Text("Choose file", style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _signatureFileName ?? "No file chosen",
                    style: TextStyle(color: _signatureFileName == null ? Colors.grey : Colors.black, fontSize: 12),
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

class _NdaPoint extends StatelessWidget {
  final String title;
  final String content;
  const _NdaPoint({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
