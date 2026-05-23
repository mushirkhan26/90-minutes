import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../widgets/checkout_step_indicator.dart';
import '../widgets/checkout_address_selector.dart';
import '../widgets/checkout_payment_selector.dart';
import '../widgets/checkout_order_summary.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exploreBackground,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black121212,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const CheckoutStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CheckoutAddressSelector(),
                  const CheckoutPaymentSelector(),
                  const CheckoutOrderSummary(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () {
            _showSuccessDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDarkGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paying via UPI', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  Text('Place order — ₹9,096', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Secure', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, color: AppColors.successColor, size: 80),
            const SizedBox(height: 24),
            const Text('Order Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Your order has been placed successfully. Get ready for your 90-min delivery!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey707070),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home');
                  context.push('/orders');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black121212,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Track Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
