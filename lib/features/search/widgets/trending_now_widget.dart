import 'package:flutter/material.dart';

class TrendingNowWidget extends StatelessWidget {
  const TrendingNowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final trending = ['Linen Shirts', 'Cargo Pants', 'Summer Dresses', 'Gym Wear'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Trending now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 45,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: trending.length,
            itemBuilder: (context, index) => _buildTrendingItem(trending[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.north_east, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}


