import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/complaint/provider/complaint_provider.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();


}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<ComplaintProvider>().loadLoginUser();
    });
  }




  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();


    if (!provider.isUserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    print("SCREEN BUILD CALLED");



    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              /// HEADER
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Text(
                      "New Complaint",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              /// FORM
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Your Name *"),
                        _readonly(provider.nameController),

                        const SizedBox(height: 12),

                        _label("Employee ID *"),
                        _readonly(provider.employeeIdController),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _dropdown(
                                label: "Category *",
                                value: provider.selectedCategory,
                                items: provider.categories,
                                onChanged: (v) => provider.setCategory(v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dropdown(
                                label: "Mention Complaining People",
                                value: provider.selectedPerson,
                                items: provider.mentionPeople,
                                onChanged: (v) => provider.setPerson(v),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _label("Additional Info"),
                        _multiline(
                          provider.additionalInfoController,
                          4,
                          onChanged: (_) => provider.onFieldChanged(),
                        ),

                        const SizedBox(height: 16),

                        _label("Attach Here"),
                        GestureDetector(
                          onTap: () {
                            // TEMP TEST URL
                            provider.addAttachment(
                              "https://task-m.s3.us-east-1.amazonaws.com/sample-test.jpg",
                            );
                          },
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 36,
                                    color: Color(0xFF55B6A9),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Drop files here"),
                                  const Text("OR"),
                                  const Text(
                                    "Browse Files",
                                    style: TextStyle(
                                      color: Color(0xFF55B6A9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (provider.attachments.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "${provider.attachments.length} file selected",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _label("Title of Complaint *"),
                        _textfield(
                          provider.titleController,
                          onChanged: (_) => provider.onFieldChanged(),
                        ),

                        const SizedBox(height: 16),

                        _label("Description *"),
                        _multiline(
                          provider.descriptionController,
                          5,
                          onChanged: (_) => provider.onFieldChanged(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// FOOTER BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF55B6A9),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                final ok = await provider.addComplaint();
                                if (!context.mounted) return;
                                if (ok) {
                                  Navigator.pop(context);
                                }
                              },
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Submit"),
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

  /// ---------- HELPERS ----------
  Widget _label(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t));

  Widget _readonly(TextEditingController controller) =>
      TextFormField(
        controller: controller,
        // initialValue: text,
        // enabled: false,
        readOnly: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          fillColor: Color(0xFFF5F5F5),
          filled: true,
        ),
      );

  Widget _textfield(TextEditingController c, {Function(String)? onChanged}) =>
      TextFormField(
        controller: c,
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      );

  Widget _multiline(
    TextEditingController c,
    int lines, {
    Function(String)? onChanged,
  }) => TextFormField(
    controller: c,
    maxLines: lines,
    onChanged: onChanged,
    validator: lines > 4
        ? (v) => v == null || v.isEmpty ? "Required" : null
        : null,
    decoration: const InputDecoration(border: OutlineInputBorder()),
  );

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: label.contains("*")
            ? (v) => v == null ? "Required" : null
            : null,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    ],
  );
}
