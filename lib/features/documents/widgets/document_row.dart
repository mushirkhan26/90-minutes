import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/document_model.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/core/utils/url_launcher_helper.dart';

class DocumentRow extends StatelessWidget {
  final Document doc;

  const DocumentRow({super.key, required this.doc});

  Future<void> _handleDocumentAction(BuildContext context, String url) async {
    if (url.isEmpty) {
      AlertHelper.snackBarError(context, 'Document URL is not available');
      return;
    }

    try {
      await UrlLauncherHelper.launchUrlString(url);
    } catch (e) {
      if (context.mounted) {
        AlertHelper.snackBarError(context, 'Could not open document');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 20, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doc.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  doc.status.toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                doc.type.toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _handleDocumentAction(context, doc.url),
                  child: const Icon(Icons.remove_red_eye_outlined,
                      size: 20, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _handleDocumentAction(context, doc.url),
                  child: const Icon(Icons.download_outlined,
                      size: 20, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
