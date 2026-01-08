import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hrtz_hrms/core/models/holiday_model.dart';


class HolidayService {
  final String url =
      'https://7qj30pu8ee.execute-api.us-east-1.amazonaws.com/holiday';

  Future<List<HolidayModel>> getHolidays() async {
    final res = await http.get(Uri.parse(url));
    final List data = jsonDecode(res.body);
    return data.map((e) => HolidayModel.fromJson(e)).toList();
  }
}