import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class RatingBar extends StatelessWidget {
  final int star;
  final double progress;
  final String count;

  const RatingBar({
    super.key,
    required this.star,
    required this.progress,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.greyE5E7EB,
                color: star >= 4 ? AppColors.primaryDarkGreen : (star >= 3 ? AppColors.primaryAmber : AppColors.warningColor),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 25, child: Text(count, style: const TextStyle(fontSize: 11, color: AppColors.grey707070))),
        ],
      ),
    );
  }
}
