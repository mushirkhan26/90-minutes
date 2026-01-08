import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/holiday_model.dart';
import 'package:hrtz_hrms/core/api/network/holiday_service.dart';

class HolidayProvider extends ChangeNotifier {
  bool isLoading = false;
  List<HolidayModel> holidays = [];

  Future<void> fetchHolidays() async {
    isLoading = true;
    notifyListeners();

    holidays = await HolidayService().getHolidays();

    isLoading = false;
    notifyListeners();
  }
}