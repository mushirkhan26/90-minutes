import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final String comment;
  final String initials;

  const ReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.comment,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.exploreBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.categoryBridalBg,
                child: Text(initials, style: const TextStyle(fontSize: 11, color: AppColors.categoryBridalText, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black121212)),
                  Text('$date • Verified buyer', style: const TextStyle(fontSize: 11, color: AppColors.grey707070)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: List.generate(5, (i) => const Icon(Icons.star, color: AppColors.primaryAmber, size: 12))),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.black354055, height: 1.5)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(width: 45, height: 45, decoration: BoxDecoration(color: AppColors.greyDFDFDF, borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 10),
              Container(width: 45, height: 45, decoration: BoxDecoration(color: AppColors.categoryLocalBg, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ],
      ),
    );
  }
}
