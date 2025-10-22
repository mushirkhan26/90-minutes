import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class ComposeMailScreen extends StatefulWidget {
  const ComposeMailScreen({super.key});

  @override
  State<ComposeMailScreen> createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final List<String> employeeSuggestions = [];

  bool showCc = false;
  bool showBcc = false;
  bool _isSending = false;

  List<String> attachments = [];

  void _addAttachmentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Attachment URL"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "https://example.com/file.pdf"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  attachments.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _sendMail() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    // final temp = {
    //   "sender": "25060018",
    //   "senderName": "John Doe",
    //   "senderProfileUrl": "https://example.com/profiles/25060018.png",
    //   "receiver": ["25060019", "25060020"],
    //   "receiverName": ["Jane Smith", "Mark Lee"],
    //   "cc": ["25060021"],
    //   "bcc": [],
    //   "subject": "Project Kickoff Meeting",
    //   "body": "Hi team, please find the meeting schedule attached.",
    //   "attachmentUrls": ["https://example.com/docs/meeting-schedule.pdf"],
    // };
    final mailData = {
      "sender": _fromController.text,
      "to": _toController.text.split(',').map((e) => e.trim()).toList(),
      "cc": _ccController.text.split(',').map((e) => e.trim()).toList(),
      "bcc": _bccController.text.split(',').map((e) => e.trim()).toList(),
      "subject": _subjectController.text,
      "body": _bodyController.text,
      "attachments": attachments,
    };

    debugPrint("Mail Data: $mailData");

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Mail sent successfully!")));
        Navigator.pop(context);
      }
    });
  }

  Widget _buildRecipientField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    final filtered = employeeSuggestions
        .where(
          (s) =>
              controller.text.isNotEmpty && s.toLowerCase().contains(controller.text.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.0),
            ),
          ),
          onChanged: onChanged,
          validator: (v) {
            if (label == "To" && (v == null || v.isEmpty)) {
              return "At least one recipient is required";
            }
            return null;
          },
        ),
        if (filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4, left: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: filtered.map((s) {
                return ListTile(
                  title: Text(s),
                  onTap: () {
                    final currentText = controller.text.trim();
                    final updatedText = currentText.isEmpty
                        ? s
                        : "$currentText, $s"; // Add with comma separation
                    setState(() {
                      controller.text = updatedText;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getEmployees();
  }

  getEmployees() async {
    final data = await SecureStorageService().getUserData();
    _fromController.text = '${data?['employeeId'] ?? ''} - ${data?['username'] ?? ''}';
    employeeSuggestions.addAll(
      (await LocalStorageService().getEmployeeList())
              ?.map((e) => '${e.employeeID} - ${e.name}')
              .toList() ??
          [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Compose Mail"),
          actions: [
            IconButton(icon: const Icon(Icons.attach_file), onPressed: _addAttachmentDialog),
            IconButton(icon: const Icon(Icons.send), onPressed: _sendMail),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _fromController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "From",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildRecipientField(
                        label: "To",
                        controller: _toController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showCc = !showCc;
                        });
                      },
                      child: Text(
                        "Cc",
                        style: TextStyle(
                          color: showCc ? AppColors.primary : Colors.grey[600],
                          fontWeight: showCc ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showBcc = !showBcc;
                        });
                      },
                      child: Text(
                        "Bcc",
                        style: TextStyle(
                          color: showBcc ? AppColors.primary : Colors.grey[600],
                          fontWeight: showBcc ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                if (showCc)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildRecipientField(
                      label: "CC",
                      controller: _ccController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                if (showBcc)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildRecipientField(
                      label: "BCC",
                      controller: _bccController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Subject required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Message",
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Message body required" : null,
                ),
                const SizedBox(height: 20),
                if (attachments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...attachments.map(
                        (url) => ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(url, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => attachments.remove(url)),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_isSending)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
