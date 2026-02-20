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
    
    // Fallback data if everything is zero to show an empty state doughnut instead of text
    final double online = _parseTimeToDouble(authProvider.onlineTime);
    final double meeting = _parseTimeToDouble(authProvider.meetingTime);
    final double breakTime = _parseTimeToDouble(authProvider.breakTime);

    final bool isActuallyEmpty = online == 0 && meeting == 0 && breakTime == 0;

    final List<ChartData> chartData = isActuallyEmpty
        ? [ChartData('No Data', 1, Colors.grey.shade200)]
        : [
      ChartData('Online', online, AppColors.activeGreen),
      ChartData('Meeting', meeting, Colors.blue),
      ChartData('Break', breakTime, Colors.purple),
    ];

    if (isLoading && authProvider.attendanceData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String productivityText = authProvider.attendanceData?['productivity']?.toString() ?? '0%';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Utilization Graph",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: SfCircularChart(
                    key: const ValueKey('utilization_chart'),
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isActuallyEmpty ? "0%" : productivityText,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            const Text(
                              'Productivity',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                    legend: Legend(
                      isVisible: !isActuallyEmpty,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        animationDuration: 1000,
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => data.color,
                        radius: '100%',
                        innerRadius: '75%',
                        enableTooltip: !isActuallyEmpty,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: !isActuallyEmpty,
                          labelPosition: ChartDataLabelPosition.outside,
                          useSeriesColor: true,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Dynamic Cards
          _buildDetailCard('Total Hours', authProvider.totalTime, Colors.deepOrange, authProvider.productivityLabel, Icons.timer),
          const SizedBox(height: 12),
          _buildDetailCard('Online Duration', authProvider.onlineTime, AppColors.activeGreen, null, Icons.laptop),
          const SizedBox(height: 12),
          _buildDetailCard('Meeting Duration', authProvider.meetingTime, Colors.blue, null, Icons.groups),
          const SizedBox(height: 12),
          _buildDetailCard('Break Duration', authProvider.breakTime, Colors.purple, null, Icons.coffee),
        ],
      ),
    );
  }

  // Helper function to parse "HH:MM" or "MM:SS" string to double minutes
  double _parseTimeToDouble(String timeStr) {
    try {
      if (timeStr == '00:00' || timeStr.isEmpty) return 0;
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return double.parse(parts[0]) * 60 + double.parse(parts[1]);
      } else if (parts.length == 3) {
        return double.parse(parts[0]) * 3600 + double.parse(parts[1]) * 60 + double.parse(parts[2]);
      }
    } catch (_) {}
    return 0;
  }

  Widget _buildDetailCard(String title, String time, Color color, [String? subtitle, IconData? icon]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon ?? Icons.access_time, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF64748B))),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
