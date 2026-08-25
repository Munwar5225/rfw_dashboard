import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class BarWidget extends StatelessWidget {
  final ChartSeriesV2 series;
  final Map<String, dynamic> visualConfig;

  const BarWidget({
    Key? key,
    required this.series,
    required this.visualConfig,
  }) : super(key: key);

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final String orientation = (visualConfig['orientation'] as String?) ?? 'vertical';
    
    if (orientation == 'vertical') {
      return _buildVerticalBarChart();
    } else {
      return _buildHorizontalBarChart();
    }
  }

  Widget _buildVerticalBarChart() {
    final double defaultBarWidth = (visualConfig['barWidth'] as num?)?.toDouble() ?? 18.0;
    final double barRadius = (visualConfig['barRadius'] as num?)?.toDouble() ?? 6.0;
    final bool showGrid = (visualConfig['showGrid'] as bool?) ?? true;
    final bool showTarget = (visualConfig['showTarget'] as bool?) ?? false;
    final bool showValues = (visualConfig['showValues'] as bool?) ?? false;
    
    final points = series.points ?? [];

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxAllowedWidth = points.isEmpty ? defaultBarWidth : (constraints.maxWidth / points.length) * 0.6;
          final double barWidth = defaultBarWidth > maxAllowedWidth ? maxAllowedWidth : defaultBarWidth;
          
          return BarChart(
        BarChartData(
          gridData: FlGridData(show: showGrid, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < points.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        points[index].key ?? '',
                        style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10),
                      ),
                    );
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
                  TextStyle(color: rod.color ?? const Color(0xFFEFEFF4), fontSize: 10, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(points.length, (index) {
            final point = points[index];
            return BarChartGroupData(
              x: index,
              showingTooltipIndicators: showValues ? [0] : [],
              barRods: [
                BarChartRodData(
                  toY: point.value ?? 0,
                  color: _hexColor(point.color ?? '#6C63FF'),
                  width: barWidth,
                  borderRadius: BorderRadius.circular(barRadius),
                  backDrawRodData: showTarget ? BackgroundBarChartRodData(
                    show: true,
                    toY: (point.percentage ?? 100).toDouble(), // fallback for target
                    color: _hexColor(point.targetColor ?? '#303040'),
                  ) : null,
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
      );
      },
      ),
    );
  }

  Widget _buildHorizontalBarChart() {
    final points = series.points ?? [];
    
    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: points.length,
        itemBuilder: (context, index) {
          final point = points[index];
          final double barHeight = (visualConfig['barHeight'] as num?)?.toDouble() ?? 18.0;
          final double barRadius = (visualConfig['barRadius'] as num?)?.toDouble() ?? 4.0;
          
          final val = point.percentage ?? point.value ?? 0;
          final target = 100.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    point.key ?? '',
                    style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: CustomPaint(
                    painter: HorizontalBarPainter(
                      filledColor: _hexColor(point.color ?? '#6C63FF'),
                      emptyColor: _hexColor(point.targetColor ?? '#E0E0E0'),
                      value: val.toDouble(),
                      target: target,
                      barRadius: barRadius,
                    ),
                    size: Size(double.infinity, barHeight),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${val.toInt()}%',
                    style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HorizontalBarPainter extends CustomPainter {
  final Color filledColor;
  final Color emptyColor;
  final double value;
  final double target;
  final double barRadius;

  HorizontalBarPainter({
    required this.filledColor,
    required this.emptyColor,
    required this.value,
    required this.target,
    required this.barRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = emptyColor;
    final fillPaint = Paint()..color = filledColor;
    
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height), 
      Radius.circular(barRadius)
    );
    canvas.drawRRect(bgRect, bgPaint);
    
    final fillWidth = (value / target).clamp(0.0, 1.0) * size.width;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height), 
      Radius.circular(barRadius)
    );
    canvas.drawRRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant HorizontalBarPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.filledColor != filledColor;
  }
}
