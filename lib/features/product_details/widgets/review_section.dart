import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import 'review_card.dart';
import 'rating_bar.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Customer reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.black121212)),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('4.8', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.black121212)),
                const SizedBox(height: 4),
                Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < 4 ? AppColors.primaryAmber : AppColors.greyE5E7EB, size: 14))),
                const SizedBox(height: 4),
                const Text('342 reviews', style: TextStyle(fontSize: 11, color: AppColors.grey707070)),
              ],
            ),
            const SizedBox(width: 35),
            const Expanded(
              child: Column(
                children: [
                  RatingBar(star: 5, progress: 0.8, count: '265'),
                  RatingBar(star: 4, progress: 0.2, count: '48'),
                  RatingBar(star: 3, progress: 0.1, count: '17'),
                  RatingBar(star: 2, progress: 0.05, count: '7'),
                  RatingBar(star: 1, progress: 0.02, count: '4'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const ReviewCard(name: 'Priya Kumari', date: '2 days ago', comment: 'Bilkul waise hi mila jaise photo mein tha. 90 minute mein delivery bhi aayi — bahut impressed hoon. Silk quality top class hai. Shaadi mein pehna toh sab ne tarif ki!', initials: 'PK'),
        const SizedBox(height: 16),
        const ReviewCard(name: 'Rekha Joshi', date: '1 week ago', comment: 'Try & Return feature bahut achha hai — size S try kiya, thoda bada laga, rider ne waapis le liya aur XS bheja. Zero jhanjhat. Local designer ka product hone ke bawajood quality amazing hai.', initials: 'RJ'),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Sab 342 reviews dekho', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
