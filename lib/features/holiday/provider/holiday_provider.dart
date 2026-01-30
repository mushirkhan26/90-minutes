import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/holiday_model.dart';
import 'package:hrtz_hrms/core/api/network/holiday_service.dart';

class HolidayProvider extends ChangeNotifier {
  bool isLoading = false;
  List<HolidayModel> holidays = [];
  String? errorMessage; // 🔹 optional for showing errors

  Future<void> fetchHolidays() async {
    isLoading = true;
    notifyListeners(); // 🔹 tells UI to show loader
    notifyListeners();

    //     holidays = await HolidayService().getHolidays();

    //     isLoading = false;
    //     notifyListeners();
    //   }
    // }
    try {
      List<HolidayModel> fetchedHolidays = await HolidayService().getHolidays();

      if (fetchedHolidays.isEmpty) {
        errorMessage = 'No holidays found';
        holidays = [];
      } else {
        holidays = fetchedHolidays;
      }
    } catch (e) {
      errorMessage = 'Failed to fetch holidays: $e';
      holidays = [];
      print(errorMessage); // for debugging
    }

    isLoading = false;
    notifyListeners(); // 🔹 tells UI to stop loader
  }
}
