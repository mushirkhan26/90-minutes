import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String selectedSize;
  final ValueChanged<String> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: sizes.map((s) {
            bool isSelected = selectedSize == s;
            return GestureDetector(
              onTap: () => onSizeSelected(s),
              child: Container(
                width: 50,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightGreenBadge : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : AppColors.greyOutline.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(s, style: TextStyle(color: isSelected ? AppColors.primaryDarkGreen : AppColors.grey707070, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.straighten, size: 16, color: AppColors.primaryDarkGreen),
              SizedBox(width: 6),
              Text('Size guide dekhein', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ],
    );
  }
}
