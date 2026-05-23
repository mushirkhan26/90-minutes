import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CheckoutAddressSelector extends StatefulWidget {
  const CheckoutAddressSelector({super.key});

  @override
  State<CheckoutAddressSelector> createState() => _CheckoutAddressSelectorState();
}

class _CheckoutAddressSelectorState extends State<CheckoutAddressSelector> {
  String _selectedAddress = 'Home';

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: _selectedAddress,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedAddress = value;
          });
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () {},
                  child: const Text('+ Add new', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          _addressCard(
            'Home',
            'Rahul Sharma',
            '12, Baldev Nagar, Near SBI Bank, Jodhpur, Rajasthan — 342001',
          ),
          const SizedBox(height: 12),
          _addressCard(
            'Office',
            'Rahul Sharma',
            'Plot 5, Shastri Nagar, MBM Campus, Jodhpur, Rajasthan — 342011',
          ),
        ],
      ),
    );
  }

  Widget _addressCard(String tag, String name, String address) {
    bool isSelected = _selectedAddress == tag;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : AppColors.greyOutline.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<String>(
            value: tag,
            activeColor: AppColors.primaryDarkGreen,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreenBadge : AppColors.categoryBridalBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(tag, style: TextStyle(color: isSelected ? AppColors.primaryDarkGreen : AppColors.categoryBridalText, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: AppColors.grey707070, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
