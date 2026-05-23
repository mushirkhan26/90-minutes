import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class AiTryOnBanner extends StatelessWidget {
  const AiTryOnBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline, color: AppColors.categoryLocalText, size: 24),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Virtual Try-On', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.categoryLocalText, fontSize: 14)),
                SizedBox(height: 2),
                Text('Apna photo upload karo — kapda tumhare upar dikhega', style: TextStyle(fontSize: 11, color: AppColors.categoryLocalText)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.categoryLocalText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Try karo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
