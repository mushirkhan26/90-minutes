import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentIndex = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Google Pay / UPI', 'icon': Icons.account_balance_wallet_outlined},
    {'name': 'Credit / Debit Card', 'icon': Icons.credit_card_outlined},
    {'name': 'Cash on Delivery', 'icon': Icons.money_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Delivery Address
            _buildSection(
              title: 'Delivery Address',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('123, Fashion Street, Near Metro Station, New Delhi - 110001'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Change', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Delivery Slot (90-min concept)
            _buildSection(
              title: 'Delivery Mode',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('90-Min Express Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Get your order in under 90 minutes!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('FREE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),
            
            // Payment Methods
            _buildSection(
              title: 'Payment Method',
              child: Column(
                children: List.generate(_paymentMethods.length, (index) {
                  final method = _paymentMethods[index];
                  final isSelected = _selectedPaymentIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaymentIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey[200]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? AppColors.primary.withOpacity(0.02) : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(method['icon'], color: isSelected ? AppColors.primary : Colors.grey),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              method['name'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: _selectedPaymentIndex,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _selectedPaymentIndex = val!),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Order Summary
            _buildSection(
              title: 'Order Summary',
              child: Column(
                children: [
                  _buildSummaryRow('Item Total', '₹1,299.00'),
                  _buildSummaryRow('Delivery Fee', '₹0.00'),
                  _buildSummaryRow('Tax & Charges', '₹45.00'),
                  const Divider(height: 24),
                  _buildSummaryRow('Grand Total', '₹1,344.00', isBold: true),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('₹1,344.00', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        ],
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
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('Order Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Your order has been placed successfully. Get ready for your 90-min delivery!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
                  backgroundColor: Colors.black,
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
