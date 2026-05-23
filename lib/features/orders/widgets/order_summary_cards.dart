import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class OrderSummaryCards extends StatelessWidget {
  const OrderSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard('12', 'Total orders'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard('₹42K', 'Total spent'),
        ),
      ],
    );
  }

  Widget _summaryCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBadge.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey707070)),
        ],
      ),
    );
  }
}
