import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class SearchCategoryList extends StatelessWidget {
  const SearchCategoryList({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Men', 'icon': Icons.man, 'color': Color(0xFFE3F2FD)},
    {'name': 'Women', 'icon': Icons.woman, 'color': Color(0xFFFCE4EC)},
    {'name': 'Kids', 'icon': Icons.child_care, 'color': Color(0xFFFFF3E0)},
    {'name': 'Beauty', 'icon': Icons.face, 'color': Color(0xFFF3E5F5)},
    {'name': 'Shoes', 'icon': Icons.shopping_bag, 'color': Color(0xFFE0F2F1)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Shop by category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: cat['color'] as Color,
                      child: Icon(cat['icon'] as IconData, color: AppColors.primaryDarkGreen, size: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(cat['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
