import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class StackBarWidget extends StatelessWidget {
  final ChartSeriesV2 series;
  final Map<String, dynamic> visualConfig;
  final bool showToggle;
  final bool toggleValue;
  final void Function(bool)? onToggleChanged;

  const StackBarWidget({
    Key? key,
    required this.series,
    required this.visualConfig,
    this.showToggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
  }) : super(key: key);

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final double barWidth = (visualConfig['barWidth'] as num?)?.toDouble() ?? 22.0;
    final bool isVerticalLabel = (visualConfig['isVerticalLabel'] as bool?) ?? false;
    final bool showLegend = (visualConfig['showLegend'] as bool?) ?? true;
    final bool showValues = (visualConfig['showValues'] as bool?) ?? false;
    
    final points = series.points ?? [];

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (showToggle)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (visualConfig['toggleLabel'] != null)
                  Text(
                    visualConfig['toggleLabel'].toString(),
                    style: const TextStyle(color: Color(0xFFEFEFF4)),
                  ),
                Switch(
                  value: toggleValue,
                  onChanged: onToggleChanged,
                ),
              ],
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxAllowedWidth = points.isEmpty ? barWidth : (constraints.maxWidth / points.length) * 0.6;
                final double actualBarWidth = barWidth > maxAllowedWidth ? maxAllowedWidth : barWidth;
                return BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isVerticalLabel ? 60 : 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < points.length) {
                          Widget text = Text(
                            points[index].key ?? '',
                            style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10),
                          );
                          if (isVerticalLabel) {
                            return Transform.rotate(
                              angle: -1.5708, // -90 degrees
                              child: text,
                            );
                          }
                          return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 2,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(1),
                        const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(points.length, (index) {
                  final point = points[index];
                  final val1 = point.value?.toDouble() ?? 0.0;
                  final val2 = point.value2?.toDouble() ?? 0.0;
                  final val3 = point.value3?.toDouble() ?? 0.0;
                  final col1 = _hexColor(point.color ?? '#6C63FF');
                  final col2 = _hexColor(point.color2 ?? '#AAAAAA');
                  final col3 = _hexColor(point.color3 ?? '#CCCCCC');
                  
                  return BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: showValues ? [0] : [],
                    barRods: [
                      BarChartRodData(
                        toY: val1 + val2 + val3,
                        width: actualBarWidth,
                        borderRadius: BorderRadius.zero,
                        rodStackItems: [
                          BarChartRodStackItem(0, val1, col1),
                          BarChartRodStackItem(val1, val1 + val2, col2),
                          BarChartRodStackItem(val1 + val2, val1 + val2 + val3, col3),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
            );
            },
            ),
          ),
          if (showLegend) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: series.legend.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _hexColor(item.legendColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.legendValue,
                      style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }
}
