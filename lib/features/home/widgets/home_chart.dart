import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../config/theme/app_colors.dart';

class HomeChart extends StatelessWidget {
  const HomeChart({super.key});

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: 200,
                  child: SfCircularChart(
                    key: const ValueKey('utilization_chart'),
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        animationDuration: 0,
                        dataSource: [
                          ChartData('Online', 27.39, AppColors.activeGreen),
                          ChartData('Meeting', 36.30, Colors.blue),
                          ChartData('Break', 36.30, Colors.purple),
                        ],
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => data.color,
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
          // Existing Cards
          _buildCard(
            'Total',
            '63:69',
            Colors.deepOrange,
            'Productivity: Medium',
          ),
          const SizedBox(height: 15),
          _buildCard('Online', '27:39', AppColors.activeGreen),
          const SizedBox(height: 15),
          _buildCard('Meeting', '36:30', Colors.blue),
          const SizedBox(height: 15),
          _buildCard('Break', '36:30', Colors.purple),
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
            padding: EdgeInsets.symmetric(horizontal: 150, vertical: 10),
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
