// 📁 lib/features/mail/widgets/recipient_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';

class RecipientSelector extends StatelessWidget {
  final String label;
  final bool showDropdown;
  final List<EmployeeModel> employees;
  final List<EmployeeModel> selectedReceivers;
  final VoidCallback onToggleDropdown;
  final ValueChanged<EmployeeModel> onAdd;
  final ValueChanged<EmployeeModel> onRemove;
  final ValueChanged<String> onFilter;

  const RecipientSelector({
    super.key,
    required this.label,
    required this.showDropdown,
    required this.employees,
    required this.selectedReceivers,
    required this.onToggleDropdown,
    required this.onAdd,
    required this.onRemove,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecipients = selectedReceivers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: showDropdown ? null : onToggleDropdown,
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
                // Label display logic
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: hasRecipients ? 12 : 16,
                      ),
                    ),
                    if (!hasRecipients)
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
                  ],
                ),

                if (hasRecipients) ...[
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: -5,
                    children: [
                      ...selectedReceivers.map(
                            (emp) => Chip(
                          label: Text(emp.name),
                          avatar: Initicon(text: emp.name, size: 22),
                          onDeleted: () => onRemove(emp),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

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
        mainAxisSize: MainAxisSize.min,
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
              padding: EdgeInsets.zero,
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
                  onTap: () => isSelected ? onRemove(emp) : onAdd(emp),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onToggleDropdown,
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}