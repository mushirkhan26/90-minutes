import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import 'product_badge.dart';

class ProductHeaderSection extends StatelessWidget {
  const ProductHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Jodhpur Couture', style: TextStyle(color: AppColors.grey707070, fontSize: 13)),
            ProductBadge(label: '★ 4.8 · 342 reviews', bgColor: AppColors.lightGreenBadge, textColor: AppColors.primaryDarkGreen),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Bandhani Silk Kurta Set',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black121212),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('₹2,499', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black121212)),
            const SizedBox(width: 10),
            const Text('₹3,299', style: TextStyle(fontSize: 15, color: AppColors.grey707070, decoration: TextDecoration.lineThrough)),
            const SizedBox(width: 10),
            ProductBadge(label: '24% off', bgColor: AppColors.lightGreenBadge, textColor: AppColors.successColor),
          ],
        ),
      ],
    );
  }
}
