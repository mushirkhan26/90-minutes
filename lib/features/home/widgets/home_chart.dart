import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../config/theme/app_colors.dart';

class HomeChart extends StatelessWidget {
  const HomeChart({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isFetchingAttendance;
    final hasData = authProvider.hasAttendanceData;

    if (isLoading && authProvider.attendanceData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Process chart data from provider
    final List<ChartData> chartData = [
      ChartData('Online', authProvider.attendanceData?['onlineTime']?.toDouble() ?? 0, AppColors.activeGreen),
      ChartData('Meeting', authProvider.attendanceData?['meetingTime']?.toDouble() ?? 0, Colors.blue),
      ChartData('Break', authProvider.attendanceData?['breakTime']?.toDouble() ?? 0, Colors.purple),
    ];

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
                !hasData
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
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.category,
                              yValueMapper: (ChartData data, _) => data.value,
                              pointColorMapper: (ChartData data, _) => data.color,
                              radius: '80%',
                              innerRadius: '60%',
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.inside,
                                textStyle: TextStyle(fontSize: 12, color: Colors.white),
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
          _buildCard('Total', authProvider.totalTime, Colors.deepOrange, authProvider.productivityLabel),
          const SizedBox(height: 15),
          _buildCard('Online', authProvider.onlineTime, AppColors.activeGreen),
          const SizedBox(height: 15),
          _buildCard('Meeting', authProvider.meetingTime, Colors.blue),
          const SizedBox(height: 15),
          _buildCard('Break', authProvider.breakTime, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String time, Color color, [String? subtitle]) {
    return Container(
      width: 375,
      padding: const EdgeInsets.all(12),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(time, style: TextStyle(color: color)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
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
