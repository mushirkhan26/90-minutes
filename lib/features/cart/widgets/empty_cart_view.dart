import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Empty State Icon Circle
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F9F6),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 60, color: AppColors.primaryDarkGreen),
                  Positioned(
                    right: 35,
                    bottom: 35,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cart khali hai!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Lagta hai abhi kuch pasand nahi aaya. Chalte hain — kuch achha dhundho!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Shopping shuru karo ↗', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
          // Coupons Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.confirmation_number_outlined, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coupons aur offers dekho', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('STYLE20, FIRST90 aur aur bhi...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Categories Header
          Row(
            children: [
              const Expanded(child: Divider()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Yeh categories try karo', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          // Categories Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem('Women', '1,240 items', const Color(0xFFFFE5EC), Colors.pink),
                _buildCategoryItem('Men', '860 items', const Color(0xFFE2F0D9), Colors.green),
                _buildCategoryItem('Bridal', '320 items', const Color(0xFFFFF4E5), Colors.orange),
                _buildCategoryItem('Local', '48 shops', const Color(0xFFE8EAF6), Colors.indigo),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Delivery Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF00897B)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('90-min delivery available', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                      Text('Abhi order karo — aaj hi ghar pe!', style: TextStyle(fontSize: 12, color: Color(0xFF00695C))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF00695C)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String subtitle, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_outlined, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
