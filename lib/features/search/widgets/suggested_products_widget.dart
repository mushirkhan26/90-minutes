import 'package:flutter/material.dart';

class SuggestedProductsWidget extends StatelessWidget {
  const SuggestedProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for you',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          _buildProductListItem(
            'White Oversized T-shirt',
            'Men\'s Wear',
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
          ),
          _buildProductListItem(
            'Blue High-Waist Jeans',
            'Women\'s Wear',
            'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500',
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(String title, String category, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(category, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.north_east, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }
}
