import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class OrderFilterTabs extends StatelessWidget {
  const OrderFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _filterChip('All orders', true),
            _filterChip('Delivered', false),
            _filterChip('Active', false),
            _filterChip('Returned', false),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightGreenBadge : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : AppColors.greyOutline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryDarkGreen : AppColors.grey707070,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
