import 'package:flutter/material.dart';

class CancelMeetingDialog extends StatefulWidget {
  final VoidCallback onConfirm; // 🚀 Required callback for logic

  const CancelMeetingDialog({super.key, required this.onConfirm});

  @override
  State<CancelMeetingDialog> createState() => _CancelMeetingDialogState();
}

class _CancelMeetingDialogState extends State<CancelMeetingDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // 🚀 Logic to enable button only when reason is typed
    _reasonController.addListener(() {
      final isNotEmpty = _reasonController.text.trim().isNotEmpty;
      if (mounted && _isButtonEnabled != isNotEmpty) {
        setState(() => _isButtonEnabled = isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cancel Meeting?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This will notify all participants that the meeting has been cancelled. Please provide a reason.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cancellation Reason *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Emergency - CEO requested urgent meeting',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Keep Meeting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled 
                        ? () {
                            widget.onConfirm();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? const Color(0xFFBDC3C7) : Colors.grey.shade300,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel Meeting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
