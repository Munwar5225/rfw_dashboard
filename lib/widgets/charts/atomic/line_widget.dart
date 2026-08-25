import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class LineWidget extends StatelessWidget {
  final List<ChartSeriesV2> seriesList;
  final Map<String, dynamic> visualConfig;

  const LineWidget({
    Key? key,
    required this.seriesList,
    required this.visualConfig,
  }) : super(key: key);

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bool showGrid = (visualConfig['showGrid'] as bool?) ?? true;
    final bool showValues = (visualConfig['showValues'] as bool?) ?? false;

    // Use first series to get x-axis labels
    List<String> xLabels = [];
    if (seriesList.isNotEmpty && seriesList.first.points != null) {
      xLabels = seriesList.first.points!.map((p) => p.key ?? '').toList();
    }

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF2C2C3F), strokeWidth: 1),
            getDrawingVerticalLine: (value) => FlLine(color: const Color(0xFF2C2C3F), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < xLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        xLabels[index],
                        style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: seriesList.map((series) {
            final sConf = series.visualConfig;
            final bool isCurved = (sConf['isCurved'] as bool?) ?? (visualConfig['isCurved'] as bool?) ?? true;
            final bool showDots = (sConf['showDots'] as bool?) ?? (visualConfig['showDots'] as bool?) ?? true;
            final double lineWidth = (sConf['lineWidth'] as num?)?.toDouble() ?? (visualConfig['lineWidth'] as num?)?.toDouble() ?? 3.0;
            final bool showFill = (sConf['showFill'] as bool?) ?? (visualConfig['showFill'] as bool?) ?? false;
            final double fillOpacity = (visualConfig['fillOpacity'] as num?)?.toDouble() ?? 0.15;
            final Color color = _hexColor((sConf['color'] as String?) ?? '#6C63FF');

            final points = series.points;

            return LineChartBarData(
              spots: List.generate(points.length, (index) {
                return FlSpot(index.toDouble(), points[index].value);
              }),
              isCurved: isCurved,
              color: color,
              barWidth: lineWidth,
              isStrokeCapRound: true,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: showFill,
                color: color.withAlpha((fillOpacity * 255).round()),
              ),
              showingIndicators: showValues ? List.generate(points.length, (index) => index) : [],
            );
          }).toList(),
        ),
      ),
    );
  }
}
