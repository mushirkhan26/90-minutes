import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class CheckoutStepIndicator extends StatelessWidget {
  const CheckoutStepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          _stepCircle(true, true, Icons.check),
          _stepLine(true),
          _stepCircle(true, false, null, "2"),
          _stepLine(false),
          _stepCircle(false, false, null, "3"),
        ],
      ),
    );
  }

  Widget _stepCircle(bool isReached, bool isDone, IconData? icon, [String? label]) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primaryDarkGreen : (isReached ? AppColors.black121212 : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(color: isReached ? Colors.transparent : AppColors.greyOutline),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 14, color: Colors.white)
            : Text(label ?? "",
                style: TextStyle(
                    color: isReached ? Colors.white : AppColors.grey707070,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primaryDarkGreen : AppColors.greyOutline.withValues(alpha: 0.3),
      ),
    );
  }
}
