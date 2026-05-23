import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CheckoutPaymentSelector extends StatefulWidget {
  const CheckoutPaymentSelector({super.key});

  @override
  State<CheckoutPaymentSelector> createState() => _CheckoutPaymentSelectorState();
}

class _CheckoutPaymentSelectorState extends State<CheckoutPaymentSelector> {
  String _selectedMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: _selectedMethod,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedMethod = value;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text('Payment method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _upiSection(),
          const SizedBox(height: 12),
          _paymentMethodTile('Credit / Debit card', 'Visa, Mastercard, RuPay', Icons.credit_card_outlined, 'CARD'),
          const SizedBox(height: 12),
          _paymentMethodTile('Cash on delivery', 'Pay when rider arrives', Icons.money_outlined, 'COD'),
        ],
      ),
    );
  }

  Widget _upiSection() {
    bool isSelected = _selectedMethod == 'UPI';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Radio<String>(
                  value: 'UPI',
                  activeColor: AppColors.primaryDarkGreen,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.lightGreenBadge, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryDarkGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UPI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('GPay, PhonePe, Paytm, BHIM', style: TextStyle(color: AppColors.grey707070, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.lightGreenBadge, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Popular', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'UPI ID: name@upi',
                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey707070),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.greyOutline)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _upiAppIcon('GPay', Icons.account_balance),
                  _upiAppIcon('PhonePe', Icons.account_balance_wallet),
                  _upiAppIcon('Paytm', Icons.payment),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _upiAppIcon(String name, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.exploreBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyOutline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDarkGreen),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _paymentMethodTile(String title, String subtitle, IconData icon, String value) {
    bool isSelected = _selectedMethod == value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            activeColor: AppColors.primaryDarkGreen,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.grey707070, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.grey707070, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
