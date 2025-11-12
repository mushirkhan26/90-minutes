import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../config/theme/app_colors.dart';

class HomeChart extends StatefulWidget {
  const HomeChart({super.key});

  @override
  State<HomeChart> createState() => _HomeChartState();
}

class _HomeChartState extends State<HomeChart> {
  bool _isLoading = true;
  List<ChartData> _chartData = [];
  String _totalTime = '00:00';
  String _productivity = 'Productivity: 00:00';
  String _onlineTime = '00:00';
  String _meetingTime = '00:00';
  String _breakTime = '00:00';

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeeId = authProvider.userData?['employeeId'] ?? '24110001';
    final now = DateTime.now();
    final date = now.toUtc().toIso8601String();

    final (success, message) = await authProvider.fetchAttendance(
      employeeId: employeeId,
      date: date,
    );

    if (success && authProvider.attendanceData != null) {
      final attendanceData = authProvider.attendanceData!;
      setState(() {
        // Update chart data
        _chartData = [
          ChartData(
            'Online',
            attendanceData['onlineTime']?.toDouble() ?? 0,
            AppColors.activeGreen,
          ),
          ChartData(
            'Meeting',
            attendanceData['meetingTime']?.toDouble() ?? 0,
            Colors.blue,
          ),
          ChartData(
            'Break',
            attendanceData['breakTime']?.toDouble() ?? 0,
            Colors.purple,
          ),
        ];
        // Update card values
        _totalTime = attendanceData['totalTime']?.toString() ?? '00:00';
        _productivity =
            'Productivity: ${attendanceData['productivity'] ?? '00:00'}';
        _onlineTime = attendanceData['onlineTime']?.toString() ?? '00:00';
        _meetingTime = attendanceData['meetingTime']?.toString() ?? '00:00';
        _breakTime = attendanceData['breakTime']?.toString() ?? '00:00';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _areAllValuesZero() {
    return _chartData.every((data) => data.value == 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Utilization Graph",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Check if chartData is empty or all values are zero
                _chartData.isEmpty || _areAllValuesZero()
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No data available for the chart.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: SfCircularChart(
                          key: const ValueKey('utilization_chart'),
                          series: <CircularSeries>[
                            DoughnutSeries<ChartData, String>(
                              animationDuration: 0,
                              dataSource: _chartData,
                              xValueMapper: (ChartData data, _) =>
                                  data.category,
                              yValueMapper: (ChartData data, _) => data.value,
                              pointColorMapper: (ChartData data, _) =>
                                  data.color,
                              radius: '80%',
                              innerRadius: '60%',
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.inside,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          legend: const Legend(
                            isVisible: true,
                            position: LegendPosition.right,
                            overflowMode: LegendItemOverflowMode.wrap,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Dynamic Cards
          _buildCard('Total', _totalTime, Colors.deepOrange, _productivity),
          const SizedBox(height: 15),
          _buildCard('Online', _onlineTime, AppColors.activeGreen),
          const SizedBox(height: 15),
          _buildCard('Meeting', _meetingTime, Colors.blue),
          const SizedBox(height: 15),
          _buildCard('Break', _breakTime, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String time,
    Color color, [
    String? subtitle,
  ]) {
    return Container(
      width: 375,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 130, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(time, style: TextStyle(color: color)),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
