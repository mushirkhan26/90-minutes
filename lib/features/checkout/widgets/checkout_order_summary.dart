import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('Edit cart', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _itemThumb(AppColors.lightGreenBadge),
              const SizedBox(width: 8),
              _itemThumb(AppColors.categoryWomenBg),
              const SizedBox(width: 8),
              _itemThumb(AppColors.categoryLocalBg),
              const SizedBox(width: 8),
              _itemThumb(AppColors.categoryBridalBg),
            ],
          ),
          const SizedBox(height: 24),
          _summaryRow('4 items (MRP)', '₹10,596'),
          const SizedBox(height: 12),
          _summaryRow('Discount', '-₹1,500', isDiscount: true),
          const SizedBox(height: 12),
          _summaryRow('Delivery', 'FREE', isFree: true, originalVal: '₹1,500'),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('₹9,096', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 24),
          _deliveryInfoBanner(),
        ],
      ),
    );
  }

  Widget _itemThumb(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Icon(Icons.image_outlined, size: 20, color: AppColors.primaryDarkGreen.withValues(alpha: 0.3))),
    );
  }

  Widget _summaryRow(String label, String value, {bool isDiscount = false, bool isFree = false, String? originalVal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey707070, fontSize: 14)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: isDiscount || isFree ? AppColors.successColor : AppColors.black121212,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (originalVal != null)
              Text(originalVal, style: const TextStyle(color: AppColors.grey707070, fontSize: 10, decoration: TextDecoration.lineThrough)),
          ],
        ),
      ],
    );
  }

  Widget _deliveryInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBadge.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: AppColors.primaryDarkGreen),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('90-min delivery guaranteed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDarkGreen)),
                Text('By 12:42 PM - Baldev Nagar, Jodhpur', style: TextStyle(fontSize: 10, color: AppColors.primaryDarkGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
