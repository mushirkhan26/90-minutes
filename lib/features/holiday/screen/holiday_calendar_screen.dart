import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/holiday_provider.dart';

class HolidayCalendarScreen extends StatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  State<HolidayCalendarScreen> createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HolidayProvider>().fetchHolidays();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HolidayProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔹 Banner
                Container(
                  margin: const EdgeInsets.all(12),
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/holiday_banner.png'),
                    ),
                  ),
                ),

                /// 🔹 Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(const Color(0xff009990)),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Day')),
                        DataColumn(label: Text('Holiday Name')),
                      ],
                      rows: List.generate(provider.holidays.length, (index) {
                        final h = provider.holidays[index];
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(
                            Text(
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(h.date)),
                            ),
                          ),
                          DataCell(Text(h.day)),
                          DataCell(Text(h.holiday)),
                        ]);
                      }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}