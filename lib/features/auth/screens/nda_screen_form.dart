import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/auth/providers/nda_provider.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class NdaScreen extends StatefulWidget {
  const NdaScreen({super.key});

  @override
  State<NdaScreen> createState() => _NdaScreenState();
}

class _NdaScreenState extends State<NdaScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ndaProvider = Provider.of<NdaProvider>(context);

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
              _buildLabelTextField("Full Name *", ndaProvider.fullNameController, "Full Name", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Employee ID *", ndaProvider.employeeIdController, "Employee ID", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Email *", ndaProvider.emailController, "Email", enabled: false),
              const SizedBox(height: 15),
              _buildLabelTextField("Position *", ndaProvider.positionController, "Position", onChanged: (_) => ndaProvider.onFieldChanged()),
              const SizedBox(height: 15),
              _buildLabelTextField("Department *", ndaProvider.departmentController, "Department", onChanged: (_) => ndaProvider.onFieldChanged()),
              const SizedBox(height: 15),
              _buildDatePickerField(context, "Date of Joining *", ndaProvider.joiningDateController, onDatePicked: (date) => ndaProvider.updateJoiningDate(date)),

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
              _buildSignatureUploadField(ndaProvider),
              const SizedBox(height: 15),
              _buildLabelTextField("Employee Signature Date *", ndaProvider.signatureDateController, "DD-MM-YYYY", enabled: false),
              const SizedBox(height: 8),
              const Text(
                "Instructions: Sign on a white sheet using a dark pen. Scan or photograph the signature ensuring the background is clean and well-lit. Avoid shadows; crop tightly around the signature.",
                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: ndaProvider.isAccepted,
                    onChanged: (value) => ndaProvider.setAccepted(value ?? false),
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
                  text: ndaProvider.isLoading ? "Submitting..." : "Submit NDA",
                  onPressed: (ndaProvider.isAccepted && !ndaProvider.isLoading)
    ? () async {
        final router = GoRouter.of(context);
        final messenger = ScaffoldMessenger.of(context);

        if (_formKey.currentState!.validate()) {

          final success = await ndaProvider.submitNda(authProvider);

          if (!mounted) return;

          if (success) {
            if (!authProvider.onboardingCompleted) {
              router.go(AppRoutes.onboardingRoute);
            } else {
              router.go(AppRoutes.homeRoute);
            }
          } else if (ndaProvider.signatureFileName == null) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text("Please upload your signature"),
              ),
            );
          }
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

  Widget _buildLabelTextField(String label, TextEditingController controller, String hint, {bool enabled = true, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hint,
          enabled: enabled,
          onChanged: onChanged,
          backgroundColor: enabled ? Colors.white : Colors.grey.shade100,
          validator: (value) {
            if (!enabled) return null;
            return (value == null || value.isEmpty) ? 'Required' : null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, TextEditingController controller, {required Function(DateTime) onDatePicked, bool enabled = true}) {
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
              onDatePicked(pickedDate);
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

  Widget _buildSignatureUploadField(NdaProvider ndaProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Employee Signature *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: ndaProvider.pickSignature,
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
                    ndaProvider.signatureFileName ?? "No file chosen",
                    style: TextStyle(color: ndaProvider.signatureFileName == null ? Colors.grey : Colors.black, fontSize: 12),
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
