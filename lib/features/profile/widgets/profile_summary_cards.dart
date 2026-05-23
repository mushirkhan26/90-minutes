import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ProfileSummaryCards extends StatelessWidget {
  const ProfileSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(child: SummaryCard(value: '12', label: 'Total orders')),
            SizedBox(width: 12),
            Expanded(child: SummaryCard(value: '₹42K', label: 'Total spent')),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const SummaryCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black121212)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey707070)),
        ],
      ),
    );
  }
}
