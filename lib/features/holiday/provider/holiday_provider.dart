import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/holiday_model.dart';
import 'package:hrtz_hrms/core/api/network/holiday_service.dart';

class HolidayProvider extends ChangeNotifier {
  bool isLoading = false;
  List<HolidayModel> holidays = [];
  String? errorMessage;

  Future<void> fetchHolidays() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await HolidayService().getHolidays();

    if (response.success && response.data != null) {
      holidays = response.data!;
    } else {
      errorMessage = response.message;
      holidays = [];
    }

    isLoading = false;
    notifyListeners(); // 🔹 tells UI to stop loader
  }
}
