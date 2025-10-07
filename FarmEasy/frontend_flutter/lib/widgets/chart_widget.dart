import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class SoilAnalysisChart extends StatelessWidget {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double phLevel;
  final double organicCarbon;

  const SoilAnalysisChart({
    super.key,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.phLevel,
    required this.organicCarbon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Soil Analysis Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textDark,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: const BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('N',
                                  style: TextStyle(
                                      color: AppConstants.textDark,
                                      fontSize: 12));
                            case 1:
                              return const Text('P',
                                  style: TextStyle(
                                      color: AppConstants.textDark,
                                      fontSize: 12));
                            case 2:
                              return const Text('K',
                                  style: TextStyle(
                                      color: AppConstants.textDark,
                                      fontSize: 12));
                            case 3:
                              return const Text('pH',
                                  style: TextStyle(
                                      color: AppConstants.textDark,
                                      fontSize: 12));
                            case 4:
                              return const Text('OC',
                                  style: TextStyle(
                                      color: AppConstants.textDark,
                                      fontSize: 12));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: AppConstants.greyColor, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeGroupData(0, nitrogen, AppConstants.primaryGreen),
                    _makeGroupData(1, phosphorus, AppConstants.accentGreen),
                    _makeGroupData(2, potassium, AppConstants.lightGreen),
                    _makeGroupData(
                        3, phLevel * 7.14, Colors.blue), // Scale pH to 0-100
                    _makeGroupData(4, organicCarbon * 20,
                        Colors.orange), // Scale OC to 0-100
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Nitrogen', AppConstants.primaryGreen, nitrogen),
        _buildLegendItem('Phosphorus', AppConstants.accentGreen, phosphorus),
        _buildLegendItem('Potassium', AppConstants.lightGreen, potassium),
        _buildLegendItem('pH Level', Colors.blue, phLevel),
        _buildLegendItem('Organic Carbon', Colors.orange, organicCarbon),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 11,
            color: AppConstants.textDark,
          ),
        ),
      ],
    );
  }
}
