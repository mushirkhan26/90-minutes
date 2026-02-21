import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/employee_benefits/provider/benefits_provider.dart';
import 'package:hrtz_hrms/core/models/benefits_claim_model.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewClaimScreen extends StatefulWidget {
  final String benefitName;
  const NewClaimScreen({super.key, required this.benefitName});

  @override
  State<NewClaimScreen> createState() => _NewClaimScreenState();
}

class _NewClaimScreenState extends State<NewClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final SecureStorageService _secure = SecureStorageService();
  final FileUploadService _fileUploadService = FileUploadService();

  // Controllers
  final _employeeId = TextEditingController();
  final _beneficiary = TextEditingController();
  final _email = TextEditingController();
  final _expenseDate = TextEditingController();
  final _expenseDesc = TextEditingController();
  final _expenseAmount = TextEditingController();
  final _claimAmount = TextEditingController();
  final _bankName = TextEditingController();
  final _accountHolder = TextEditingController();
  final _ifsc = TextEditingController();
  final _accountNumber = TextEditingController();

  String _relation = "Self";
  String _accountType = "Savings";

  File? _selectedFile;
  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  Future<void> _loadEmployeeId() async {
    final id = await _secure.getEmployeeId();
    if (mounted && id != null) {
      _employeeId.text = id;
    }
  }

  // ================= FILE PICK =================

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);

      if (await file.length() > 5 * 1024 * 1024) {
        _showSnack("File size must be less than 5MB");
        return;
      }

      setState(() => _selectedFile = file);
    }
  }

  Future<bool> _uploadFile() async {
    if (_selectedFile == null) return false;

    final url = await _fileUploadService.uploadFile(_selectedFile!);

    if (url != null) {
      _uploadedFileUrl = url;
      return true;
    } else {
      _showSnack("File upload failed");
      return false;
    }
  }

  // ================= DATE =================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      _expenseDate.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      _showSnack("Receipt required");
      return;
    }
    final provider = Provider.of<BenefitsProvider>(context, listen: false);

    final uploaded = await _uploadFile();
    if (!uploaded) return;
    if(!mounted) return;

    

    final model = BenefitsClaimModel(
      id: "",
      employeeId: _employeeId.text,
      beneficiaryName: _beneficiary.text,
      relationWithEmployee: _relation,
      email: _email.text,
      expenseDescription: _expenseDesc.text,
      expenseDate: _expenseDate.text,
      expenseAmount: _expenseAmount.text,
      claimAmount: _claimAmount.text,
      billAmount: _claimAmount.text,
      benefitName: widget.benefitName,
      claimStatus: "Pending",
      receipt: _uploadedFileUrl,
      bankDetails: [
        BankDetails(
          bankName: _bankName.text,
          accountHolderName: _accountHolder.text,
          ifscCode: _ifsc.text,
          accountNumber: _accountNumber.text,
          accountType: _accountType,
        ),
      ],
    );

    final success = await provider.addClaim(model);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Claim submitted successfully",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if(!mounted) return;

      Navigator.pop(context);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          "Apply ${widget.benefitName}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Claim Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildField("Employee ID", _employeeId, readOnly: true),
              _buildField("Beneficiary Name", _beneficiary),
              _buildDropdown(
                "Relation With Employee",
                _relation,
                _selectRelation,
              ),
              _buildField(
                "Email",
                _email,
                validator: (v) =>
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(v!)
                    ? null
                    : "Invalid email",
              ),
              _buildDisabled("Benefit Type", widget.benefitName),
              _buildDate(),
              _buildField("Expense Description", _expenseDesc, maxLines: 3),
              _buildNumberField("Expense Amount", _expenseAmount),
              _buildNumberField("Claim Amount", _claimAmount),
              _buildDisabled("Claim Status", "Pending"),

              const SizedBox(height: 15),
              _buildReceipt(),

              const SizedBox(height: 30),
              const Text(
                "Bank Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildField("Bank Name", _bankName),
              // _buildField("Account Holder Name", _accountHolder),
              _buildField(
                "Account Holder Name",
                _accountHolder,
                validator: (v) {
                  if (v == null || v.trim().isEmpty){
                    return "Account Holder Name required";
                  }
                    
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) {
                    return "Only letters allowed";
                  }
                  return null;
                },
              ),
              _buildAccountNumber(),
              _buildIFSCField(),

              _buildDropdown("Account Type", _accountType, _selectAccountType),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        foregroundColor: Colors.white,
                      ),

                      child: const Text("Submit Claim"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMMON WIDGETS =================

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label *"),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            textCapitalization: capitalization,
            validator:
                validator ??
                (v) => v == null || v.isEmpty ? "$label required" : null,
            decoration: InputDecoration(
              hintText: "Enter $label",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label *"),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null
                ? "Enter valid amount"
                : null,
            decoration: InputDecoration(
              hintText: "Enter $label",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountNumber() {
    return _buildField(
      "Account Number",
      _accountNumber,
      validator: (v) => v != null && RegExp(r'^\d{9,18}$').hasMatch(v)
          ? null
          : "9-18 digits required",
    );
  }

  Widget _buildDisabled(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label *"),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Expense Date *"),
          const SizedBox(height: 6),
          TextFormField(
            controller: _expenseDate,
            readOnly: true,
            onTap: _pickDate,
            validator: (v) =>
                v == null || v.isEmpty ? "Expense Date required" : null,
            decoration: InputDecoration(
              hintText: "Select Date",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIFSCField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("IFSC Code *"),
          const SizedBox(height: 6),
          TextFormField(
            controller: _ifsc,
            textCapitalization: TextCapitalization.characters,
            validator: (v) =>
                RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v ?? "")
                ? null
                : "Format: 4 letters + 0 + 6 alphanumeric (e.g. SBIN0123456)",
            decoration: InputDecoration(
              hintText: "Enter IFSC Code (e.g. SBIN0123456)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Format: 4 letters + 0 + 6 alphanumeric",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label *"),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(value), const Icon(Icons.keyboard_arrow_down)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceipt() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Receipt *"),
          const SizedBox(height: 8),

          // Choose File Button (Web Style)
          InkWell(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F1), // light green background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1BAA9C)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.cloud_upload_outlined, color: Color(0xFF1BAA9C)),
                  SizedBox(width: 10),
                  Text(
                    "Choose File",
                    style: TextStyle(
                      color: Color(0xFF1BAA9C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Selected File Container
          if (_selectedFile != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Selected file: ${_selectedFile!.path.split('/').last}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _viewSelectedFile,
                    icon: const Icon(Icons.remove_red_eye, size: 16),
                    label: const Text("View"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BAA9C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          const Text(
            "Allowed file types: PDF, JPG, JPEG, PNG (Max size: 5MB)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _selectRelation() {
    _showDialog("Select Relation", [
      "Self",
      "Spouse",
      "Child",
      "Parent",
      "Other",
    ], (val) => setState(() => _relation = val));
  }

  void _selectAccountType() {
    _showDialog("Select Account Type", [
      "Savings",
      "Current",
      "Salary",
    ], (val) => setState(() => _accountType = val));
  }

 void _showDialog(
  String title,
  List<String> options,
  Function(String) onChanged,
) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      String selectedValue = title.contains("Relation")
          ? _relation
          : _accountType;

      return Dialog(
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...options.map((e) {
                  return RadioGroup<String>(
                    groupValue: selectedValue,
                    onChanged: (val) {
                      if (val == null) return;

                      setDialogState(() {
                        selectedValue = val;
                      });

                      onChanged(val);

                      if (mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: RadioListTile<String>(
                      title: Text(e),
                      value: e,
                    ),
                  );
                }
                )
              ],
            );
          },
        ),
      );
    },
  );
}
  void _viewSelectedFile() async {
    if (_selectedFile == null) return;

    final path = _selectedFile!.path.toLowerCase();

    // Image preview
    if (path.endsWith(".jpg") ||
        path.endsWith(".jpeg") ||
        path.endsWith(".png")) {
      showDialog(
        context: context,
        builder: (_) =>
            Dialog(child: InteractiveViewer(child: Image.file(_selectedFile!))),
      );
    }
    // PDF open externally
    else if (path.endsWith(".pdf")) {
      final uri = Uri.file(_selectedFile!.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnack("Cannot open file");
      }
    } else {
      _showSnack("Unsupported file format");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
