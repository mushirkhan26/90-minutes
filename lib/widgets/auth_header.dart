import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final CrossAxisAlignment crossAxisAlignment;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(height: screenHeight * 0.04),
        if (showLogo) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: screenWidth * 0.1,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          textAlign: crossAxisAlignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: crossAxisAlignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
