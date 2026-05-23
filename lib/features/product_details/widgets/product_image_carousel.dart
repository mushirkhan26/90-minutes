import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import 'product_badge.dart';

class ProductImageCarousel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 380,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              itemCount: 4,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return Center(
                  child: Icon(Icons.image_outlined, size: 80, color: AppColors.primaryDarkGreen.withValues(alpha: 0.5)),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 25,
          left: 35,
          child: ProductBadge(label: '90 Min', bgColor: AppColors.primaryDarkGreen, textColor: Colors.white, icon: Icons.timer_outlined),
        ),
        Positioned(
          top: 25,
          right: 35,
          child: const Text('Local designer', style: TextStyle(color: AppColors.categoryLocalText, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Positioned(
          bottom: 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: index == selectedIndex ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: index == selectedIndex ? AppColors.primaryDarkGreen : AppColors.primaryDarkGreen.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
