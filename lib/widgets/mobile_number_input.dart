import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme/app_colors.dart';

class MobileNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const MobileNumberInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.08),
        const Text(
          'Enter Mobile Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null
                  ? AppColors.errorRed
                  : AppColors.greyOutline,
            ),
          ),
          child: Row(
            children: [
              _buildCountryCode(),
              Expanded(child: _buildTextField()),
            ],
          ),
        ),
        if (errorText != null) _buildErrorMessage(),
      ],
    );
  }

  Widget _buildCountryCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: errorText != null
                ? AppColors.errorRed
                : AppColors.greyOutline,
          ),
        ),
      ),
      child: const Row(
        children: [
          Text(
            '+91',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: const InputDecoration(
        hintText: '99999 99999',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4),
      child: Text(
        errorText!,
        style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
      ),
    );
  }
}
