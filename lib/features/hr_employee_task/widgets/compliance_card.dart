import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/compliance_model.dart';
import '../../../core/services/file_upload_service.dart';

class ComplianceCard extends StatefulWidget {
  final Compliance compliance;
  final Function(List<String>) onSubmit;

  const ComplianceCard({super.key, required this.compliance, required this.onSubmit});

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
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
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
          setState(() {
            _uploadedUrls.add(url);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File uploaded successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload file')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking/uploading file: $e");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.compliance.status.toLowerCase();
    final isCompleted = status == 'completed' || status == 'submitted';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
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
                          _buildStatusChip(
                            widget.compliance.title.toUpperCase(),
                            const Color(0xFFDBEAFE),
                            const Color(0xFF1E40AF),
                          ),
                          _buildStatusChip(
                            widget.compliance.status,
                            isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            isCompleted ? const Color(0xFF166534) : const Color(0xFF92400E),
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
                Text(
                  widget.compliance.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.compliance.description,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${DateFormat('yyyy-MM-dd').format(widget.compliance.dueDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),
                  if (widget.compliance.note != null && widget.compliance.note!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 4)),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Note: ${widget.compliance.note}',
                        style: const TextStyle(color: Color(0xFF92400E)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.compliance.requiredDocuments.isNotEmpty) ...[
                    _buildSectionTitle(Icons.description_outlined, 'Required Documents'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        children: widget.compliance.requiredDocuments.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  doc.name,
                                  style: const TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isCompleted)
                              _isUploading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : TextButton.icon(
                                onPressed: _pickAndUploadFile,
                                icon: const Icon(Icons.upload_outlined, size: 18, color: Color(0xFF2563EB)),
                                label: const Text('Upload', style: TextStyle(color: Color(0xFF2563EB))),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    if (_uploadedUrls.isNotEmpty) ...[
                       const SizedBox(height: 12),
                       const Text("Files to be submitted:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                       ..._uploadedUrls.map((url) => Padding(
                         padding: const EdgeInsets.symmetric(vertical: 4),
                         child: Row(
                           children: [
                             const Icon(Icons.attach_file, size: 14, color: Colors.green),
                             const SizedBox(width: 4),
                             Expanded(child: Text(url.split('/').last, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                             IconButton(
                               icon: const Icon(Icons.close, size: 14, color: Colors.red),
                               onPressed: () => setState(() => _uploadedUrls.remove(url)),
                               padding: EdgeInsets.zero,
                               constraints: const BoxConstraints(),
                             )
                           ],
                         ),
                       ))
                    ],
                    const SizedBox(height: 20),
                  ],
                  if (widget.compliance.actionLinks.isNotEmpty) ...[
                    const Text(
                      'Action Links:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.compliance.actionLinks.map((link) => ElevatedButton.icon(
                        onPressed: () => _launchUrl(link.url),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(link.title),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.compliance.submittedDocuments.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF166534), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Submitted Documents:',
                                style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...widget.compliance.submittedDocuments.map((doc) => Padding(
                            padding: const EdgeInsets.only(left: 28, bottom: 8),
                            child: InkWell(
                              onTap: () => _launchUrl(doc.url),
                              child: Row(
                                children: [
                                  const Icon(Icons.insert_drive_file_outlined, size: 16, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doc.name,
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted ? null : () {
                  if (_uploadedUrls.isEmpty && widget.compliance.requiredDocuments.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please upload required documents first')),
                    );
                    return;
                  }
                  widget.onSubmit(_uploadedUrls);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color(0xFF059669) : const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF059669).withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isCompleted ? 'Documents Submitted' : 'Submit Documents',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E40AF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
