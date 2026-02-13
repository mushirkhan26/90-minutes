import 'package:flutter/material.dart';

class AddSubDepartmentDialog extends StatefulWidget {
  final String department;

  const AddSubDepartmentDialog({
    super.key,
    required this.department,
  });

  @override
  State<AddSubDepartmentDialog> createState() =>
      _AddSubDepartmentDialogState();
}

class _AddSubDepartmentDialogState
    extends State<AddSubDepartmentDialog> {
  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _descController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Subdepartment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26A69A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _label('Subdepartment Name *'),
            _input(
              'e.g. Backend Development',
              controller: _nameController,
            ),

            _label('Description (Optional)'),
            _input(
              'Brief description of this subdepartment',
              maxLines: 3,
              controller: _descController,
            ),

            _label('Department'),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: widget.department,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) {
                      return;
                    }

                
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _input(
    String hint, {
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isDense: true,
      ),
    );
  }
}