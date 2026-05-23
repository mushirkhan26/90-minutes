import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import 'order_card_widgets.dart';

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.bluePrimary),
                  Positioned(
                    bottom: 35,
                    left: 30,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppColors.lightGreenBadge,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 12, color: AppColors.primaryDarkGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Koi order nahi abhi tak',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pehla order do aur 90-minute mein ghar pe\nfashion enjoy karo!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.grey707070),
          ),
          const SizedBox(height: 32),
          OrderActionButton(
            label: 'Pehla order do ↗',
            isPrimary: true,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 12),
          OrderActionButton(
            label: 'Products explore karo ↗',
            isPrimary: false,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.dividerColor)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Kyon order karein?',
                    style: TextStyle(fontSize: 12, color: AppColors.grey707070)),
              ),
              const Expanded(child: Divider(color: AppColors.dividerColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
              '90-min delivery',
              'Order karo — 90 min mein ghar pe',
              AppColors.lightGreenBadge,
              AppColors.primaryDarkGreen),
          _buildFeatureItem('Try & Return — free', 'Pasand na aaye toh rider le jaayega',
              AppColors.categoryBridalBg, AppColors.warningColor),
          _buildFeatureItem('Local Jodhpur designers', '48+ boutiques — authentic aur unique',
              AppColors.categoryLocalBg, AppColors.categoryLocalText),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.check_circle_outline, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey707070)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey707070, size: 16),
        ],
      ),
    );
  }
}
