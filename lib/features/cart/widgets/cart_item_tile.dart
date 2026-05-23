import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/cart_model.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.productImage ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.brand ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const Icon(Icons.close, size: 16, color: Colors.grey),
                  ],
                ),
                Text(item.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Size: ${item.size}  •  Color: ${item.color}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹${item.price.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    if (item.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text('₹${item.originalPrice!.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (item.badges != null)
                  Wrap(
                    spacing: 4,
                    children: item.badges!
                        .map((badge) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(badge, style: const TextStyle(color: Colors.deepPurple, fontSize: 10)),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 60),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, () => context.read<CartBloc>().add(UpdateQuantity(item.productId, item.quantity - 1))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () => context.read<CartBloc>().add(UpdateQuantity(item.productId, item.quantity + 1))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.grey),
      ),
    );
  }
}
