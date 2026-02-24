import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/hr_employee_task/providers/compliance_provider.dart';
import 'package:hrtz_hrms/features/hr_employee_task/widgets/create_task_dailog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/compliance_model.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/file_upload_service.dart';

class ComplianceCard extends StatefulWidget {
  final Compliance compliance;
  final Function(List<String>) onSubmit;
  final bool isAdmin;

  const ComplianceCard({
    super.key,
    required this.compliance,
    required this.onSubmit,
    this.isAdmin = false,
  });

  @override
  State<ComplianceCard> createState() => _ComplianceCardState();
}

class _ComplianceCardState extends State<ComplianceCard> {
  bool _isExpanded = false;
  bool _isUploading = false;
  final List<String> _uploadedUrls = [];
  final FileUploadService _fileUploadService = FileUploadService();

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Could not launch $url');
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        File file = File(result.files.single.path!);
        String? url = await _fileUploadService.uploadFile(file);

        if (url != null) {
          setState(() => _uploadedUrls.add(url));
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully')));
        }
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.compliance.status.toLowerCase();
    final isCompleted = status == 'completed' || status == 'submitted';
    final hasRequiredDocs = widget.compliance.requiredDocuments.isNotEmpty;
    final hasUploaded = _uploadedUrls.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedSection(isCompleted),
          if (!widget.isAdmin) _buildSubmitButton(isCompleted, hasRequiredDocs, hasUploaded),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isCompleted = widget.compliance.status.toLowerCase() == 'completed' || widget.compliance.status.toLowerCase() == 'submitted';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(label: widget.compliance.complianceType, bgColor: const Color(0xFFDBEAFE), textColor: const Color(0xFF1E40AF)),
                    _StatusChip(
                      label: widget.compliance.status,
                      bgColor: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      textColor: isCompleted ? const Color(0xFF166534) : const Color(0xFF92400E),
                      icon: isCompleted ? Icons.check_circle_outline : Icons.access_time,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF334155)),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.compliance.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(widget.compliance.description, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
          if (widget.isAdmin) ...[
            const SizedBox(height: 6),
            Text("Employee ID: ${widget.compliance.employeeId ?? '_'}", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 16),
          _DueDateBadge(dueDate: widget.compliance.dueDate),
        ],
      ),
    );
  }

  Widget _buildExpandedSection(bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          if (widget.compliance.requiredDocuments.isNotEmpty) _buildDocSection(isCompleted),
          if (widget.compliance.actionLinks.isNotEmpty) _buildLinksSection(),
          if (widget.compliance.submittedDocuments.isNotEmpty) _buildSubmittedSection(),
          if (widget.isAdmin) _buildAdminActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDocSection(bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.description_outlined, title: 'Required Documents'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
          child: Column(
            children: widget.compliance.requiredDocuments.map((doc) => _DocRow(
              name: doc.name,
              isAdmin: widget.isAdmin,
              isCompleted: isCompleted,
              isUploading: _isUploading,
              onUpload: _pickAndUploadFile,
            )).toList(),
          ),
        ),
        if (_uploadedUrls.isNotEmpty) _UploadedCounter(count: _uploadedUrls.length),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Action Links:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.compliance.actionLinks.map((link) => CustomButton(
            text: link.title,
            icon: Icons.open_in_new,
            width: 150,
            height: 40,
            backgroundColor: const Color(0xFF2563EB),
            borderColor: const Color(0xFF2563EB),
            onPressed: () => _launchUrl(link.url),
          )).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSubmittedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.check_circle_outline, title: 'Submitted Documents'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
          child: Column(
            children: widget.compliance.submittedDocuments.map((doc) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(doc.name, style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                if (widget.isAdmin) Row(children: [
                  IconButton(icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 20), onPressed: () => _launchUrl(doc.url)),
                  IconButton(icon: const Icon(Icons.download_outlined, color: Colors.green, size: 20), onPressed: () => _launchUrl(doc.url)),
                ]),
              ],
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
          onPressed: () => showDialog(context: context, builder: (_) => CreateTaskDialog(isEdit: true, existingCompliance: widget.compliance)),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          onPressed: () async {
            final provider = context.read<ComplianceProvider>();
            final success = await provider.deleteCompliance(widget.compliance.id);
            if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compliance deleted")));
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isCompleted, bool hasRequiredDocs, bool hasUploaded) {
    final canSubmit = !isCompleted && (!hasRequiredDocs || hasUploaded);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: CustomButton(
        text: isCompleted ? 'Documents Submitted' : 'Submit Documents',
        onPressed: canSubmit ? () {
          final finalUrls = [...widget.compliance.submittedDocuments.map((e) => e.url), ..._uploadedUrls];
          widget.onSubmit(finalUrls);
        } : null,
        backgroundColor: isCompleted ? const Color(0xFF059669).withValues(alpha: 0.6) : const Color(0xFF26A69A),
        borderColor: Colors.transparent,
      ),
    );
  }
}

// ----------------- Helper Widgets -----------------

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _StatusChip({required this.label, required this.bgColor, required this.textColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 6)],
          Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  const _DueDateBadge({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text('Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E40AF)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), fontSize: 16)),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  final String name;
  final bool isAdmin;
  final bool isCompleted;
  final bool isUploading;
  final VoidCallback onUpload;

  const _DocRow({required this.name, required this.isAdmin, required this.isCompleted, required this.isUploading, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          if (!isAdmin && !isCompleted)
            isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) :
            TextButton.icon(onPressed: onUpload, icon: const Icon(Icons.upload_outlined, size: 18, color: Color(0xFF2563EB)), label: const Text('Upload', style: TextStyle(color: Color(0xFF2563EB)))),
        ],
      ),
    );
  }
}

class _UploadedCounter extends StatelessWidget {
  final int count;
  const _UploadedCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text("$count file${count > 1 ? 's' : ''} uploaded", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
