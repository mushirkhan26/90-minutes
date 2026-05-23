import 'package:flutter/material.dart';
import '../../../core/models/cart_model.dart';

class CartPriceBreakdown extends StatelessWidget {
  final CartModel cart;
  const CartPriceBreakdown({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _priceRow('MRP total', '₹${cart.mrpTotal.toInt()}'),
          _priceRow('Product discount', '-₹${cart.productDiscount.toInt()}', color: Colors.green),
          _priceRow('Delivery fee', 'FREE', color: Colors.green, subtitle: '₹1,200'),
          const Divider(),
          _priceRow('Total payable', '₹${cart.total.toInt()}', isBold: true),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You save ', style: TextStyle(fontSize: 12, color: Colors.green)),
                Text('₹${cart.discount.toInt()} on this order', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.celebration, size: 14, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false, Color? color, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isBold ? Colors.black : Colors.grey.shade600, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 14, color: color ?? (isBold ? Colors.black : Colors.black87), fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
              if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
            ],
          ),
        ],
      ),
    );
  }
}
