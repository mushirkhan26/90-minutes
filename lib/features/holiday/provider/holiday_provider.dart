import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/models/holiday_model.dart';
import 'package:hrtz_hrms/core/api/network/holiday_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum HolidayState { initial, loading, loaded, error }

class HolidayProvider extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();
  final LocalStorageService _localStorage = LocalStorageService();
  final LoggingService _logger = LoggingService.instance;

  HolidayState _state = HolidayState.initial;
  HolidayState get state => _state;

  List<HolidayModel> _holidays = [];
  List<HolidayModel> get holidays => _holidays;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == HolidayState.loading;

  static const String _storageKey = 'cached_holidays';

  HolidayProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromLocal();
    fetchHolidays();
  }

  Future<void> _loadFromLocal() async {
    try {
      final cachedData = await _localStorage.getString(_storageKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        _holidays = decoded.map((json) => HolidayModel.fromJson(json)).toList();
        _state = HolidayState.loaded;
        notifyListeners();
        _logger.logNetwork('✅ Loaded holidays from cache');
      }
    } catch (e) {
      _logger.error('HOLIDAY_PROVIDER', 'Error loading from local', error: e);
    }
  }

  Future<void> fetchHolidays() async {
    // Only show loading if we don't have cached data
    if (_holidays.isEmpty) {
      _state = HolidayState.loading;
      notifyListeners();
    }

    try {
      final response = await _holidayService.getHolidays();

      if (response.success && response.data != null) {
        _holidays = response.data!;
        _state = HolidayState.loaded;
        
        // Rule 1: Save to local storage
        final encoded = jsonEncode(_holidays.map((e) => e.toJson()).toList());
        await _localStorage.saveString(_storageKey, encoded);
        _logger.logNetwork('✅ Holidays fetched and cached');
      } else {
        if (_holidays.isEmpty) {
          _state = HolidayState.error;
          _errorMessage = response.message;
        }
      }
    } catch (e) {
      if (_holidays.isEmpty) {
        _state = HolidayState.error;
        _errorMessage = 'Failed to load holidays';
      }
      _logger.error('HOLIDAY_PROVIDER', 'Fetch error', error: e);
    }
    notifyListeners();
  }
}
