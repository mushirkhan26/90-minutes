import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color countColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // Removed fixed height to prevent overflow, using padding instead
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 11, // Reduced font size for mobile compatibility
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22, // Reduced font size for mobile compatibility
                fontWeight: FontWeight.bold,
                color: countColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
