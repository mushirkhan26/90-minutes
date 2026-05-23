import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_90/features/cart/bloc/cart_bloc.dart';
import 'package:delivery_90/features/cart/bloc/cart_state.dart';
import 'package:delivery_90/config/theme/app_colors.dart';
import 'package:delivery_90/core/models/cart_model.dart';
import '../widgets/cart_delivery_banner.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_promo_cards.dart';
import '../widgets/cart_coupon_section.dart';
import '../widgets/cart_price_breakdown.dart';
import '../widgets/empty_cart_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded) {
                  return Text('${state.cart.items.length} items',
                      style: const TextStyle(fontSize: 12, color: Colors.grey));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGreenBadge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.savings_outlined, size: 14, color: AppColors.darkGreenText),
                SizedBox(width: 4),
                Text('Saving ₹1,100',
                    style: TextStyle(
                        color: AppColors.darkGreenText, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            final cart = state.cart;
            if (cart.items.isEmpty) {
              return const EmptyCartView();
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      const CartDeliveryBanner(),
                      ...cart.items.map((item) => CartItemTile(item: item)),
                      const FreeDeliveryPromo(),
                      const CartCouponSection(),
                      CartPriceBreakdown(cart: cart),
                      const TryReturnBanner(),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: _buildStickyFooter(context, cart),
                ),
              ],
            );
          } else if (state is CartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.push('/checkout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cart.items.length} items',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                Text('₹${cart.total.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Row(
              children: [
                Text('Checkout',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
