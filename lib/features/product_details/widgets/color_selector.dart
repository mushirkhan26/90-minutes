import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ColorSelector extends StatelessWidget {
  final List<Map<String, dynamic>> colors;
  final String selectedColorName;
  final ValueChanged<String> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColorName,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: colors.map((c) {
            bool isSelected = selectedColorName == c['name'];
            return GestureDetector(
              onTap: () => onColorSelected(c['name']),
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: AppColors.black121212, width: 2) : Border.all(color: Colors.transparent, width: 2),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c['color'],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.grey707070),
            children: [
              const TextSpan(text: 'Selected: '),
              TextSpan(text: selectedColorName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black121212)),
            ],
          ),
        ),
      ],
    );
  }
}
