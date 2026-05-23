import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ProductDetailsInfo extends StatelessWidget {
  const ProductDetailsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.black121212)),
        const SizedBox(height: 12),
        const Text(
          'Authentic Bandhani silk kurta set, handcrafted by local Jodhpur artisans. Traditional tie-dye technique with 100% pure silk fabric. Includes kurta, dupatta, aur palazzo pants. Machine washable.',
          style: TextStyle(fontSize: 14, color: AppColors.grey707070, height: 1.6),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _tag('100% Silk'),
            _tag('Handcrafted'),
            _tag('Machine wash'),
            _tag('Jodhpur made'),
            _tag('Festive wear'),
          ],
        ),
      ],
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.exploreBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey707070, fontWeight: FontWeight.w500)),
    );
  }
}
