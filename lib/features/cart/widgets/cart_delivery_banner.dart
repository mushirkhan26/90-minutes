import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CartDeliveryBanner extends StatelessWidget {
  const CartDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE6F4F1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: AppColors.darkGreenText),
              SizedBox(width: 8),
              Text('90-min delivery to Baldev Nagar', style: TextStyle(color: AppColors.darkGreenText, fontSize: 12)),
            ],
          ),
          Text('by 12:42 PM', style: TextStyle(color: AppColors.darkGreenText, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
