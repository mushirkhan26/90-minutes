// 📁 lib/features/mail/widgets/recipient_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';

class RecipientSelector extends StatelessWidget {
  final bool showDropdown;
  final List<EmployeeModel> employees;
  final List<EmployeeModel> selectedReceivers;
  final VoidCallback onToggleDropdown;
  final ValueChanged<String> onFilter;

  const RecipientSelector({
    super.key,
    required this.showDropdown,
    required this.employees,
    required this.selectedReceivers,
    required this.onToggleDropdown,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecipients = selectedReceivers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 📬 TO field with selected chips
        GestureDetector(
          onTap: onToggleDropdown,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasRecipients)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('To', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
                    ],
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ...selectedReceivers.map(
                        (emp) => Chip(
                          label: Text(emp.name),
                          avatar: Initicon(text: emp.name, size: 22),
                          onDeleted: () => selectedReceivers.remove(emp),
                        ),
                      ),
                      GestureDetector(
                        onTap: onToggleDropdown,
                        child: const Icon(Icons.add_circle_outline, size: 22),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        /// 📜 Dropdown employee selector
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: showDropdown ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _buildEmployeeDropdown(context),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Search employee...',
                border: InputBorder.none,
              ),
              onChanged: onFilter,
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                final isSelected = selectedReceivers.contains(emp);

                return ListTile(
                  leading: Initicon(text: emp.name),
                  title: Text(emp.name),
                  subtitle: Text('ID: ${emp.employeeID}'),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    if (isSelected) {
                      selectedReceivers.remove(emp);
                    } else {
                      selectedReceivers.add(emp);
                    }
                    (context as Element).markNeedsBuild(); // quick rebuild
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
