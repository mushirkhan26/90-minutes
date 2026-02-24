import 'package:flutter/material.dart';

class ComplianceTabBar extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  const ComplianceTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab("All"),
        const SizedBox(width: 8),
        _buildTab("Assigned"),
        const SizedBox(width: 8),
        _buildTab("Submitted"),
      ],
    );
  }

  Widget _buildTab(String title) {
    final isSelected = selectedTab == title;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF26A69A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
