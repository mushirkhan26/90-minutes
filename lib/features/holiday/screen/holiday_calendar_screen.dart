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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Holiday Calendar',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                /// 🔹 Banner
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/holiday_banner.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// 🔹 Print Layout Table
                Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FlexColumnWidth(2.5),
                    2: FlexColumnWidth(2.5),
                    3: FlexColumnWidth(4),
                  },
                  children: [
                    /// Table Header
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xffEEEEEE)),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('#',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Day',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Holiday Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),

                    /// Table Rows
                    ...List.generate(provider.holidays.length, (index) {
                      final h = provider.holidays[index];
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${index + 1}',
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(h.date)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(h.day, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(h.holiday),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'End of Holiday List',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
