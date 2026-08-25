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

  Map<String, dynamic> _getMergedConfig() {
    final Map<String, dynamic> globalProps = visualConfig;
    final graphsConfig = globalProps['graphs'] as Map<String, dynamic>?;
    final Map<String, dynamic> graphOverrides = (graphsConfig?[series.seriesKey] as Map<String, dynamic>?) ?? {};
    
    return {
      ...globalProps,
      ...series.visualConfig,
      ...graphOverrides,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mergedConfig = _getMergedConfig();
    final String orientation = (mergedConfig['orientation'] as String?) ?? 'vertical';
    final bool isClickable = (mergedConfig['isClickable'] as bool?) ?? false;
    final String? description = mergedConfig['description']?.toString();
    
    Widget content;
    if (orientation == 'vertical') {
      content = _buildVerticalBarChart(mergedConfig);
    } else {
      content = _buildHorizontalBarChart(mergedConfig);
    }

    if (description != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: content),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${series.seriesLabel} clicked!'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF6C63FF),
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildVerticalBarChart(Map<String, dynamic> mergedConfig) {
    final double defaultBarWidth = (mergedConfig['barWidth'] as num?)?.toDouble() ?? 18.0;
    final double barRadius = (mergedConfig['barRadius'] as num?)?.toDouble() ?? 6.0;
    final bool showGrid = (mergedConfig['showGrid'] as bool?) ?? true;
    final bool showTarget = (mergedConfig['showTarget'] as bool?) ?? false;
    final bool showValues = (mergedConfig['showValues'] as bool?) ?? false;
    final String? overallColor = mergedConfig['color']?.toString();
    
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
                interval: 1,
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
            final colorHex = overallColor ?? point.color ?? '#6C63FF';
            return BarChartGroupData(
              x: index,
              showingTooltipIndicators: showValues ? [0] : [],
              barRods: [
                BarChartRodData(
                  toY: point.value ?? 0,
                  color: _hexColor(colorHex),
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

  Widget _buildHorizontalBarChart(Map<String, dynamic> mergedConfig) {
    final points = series.points ?? [];
    final String? overallColor = mergedConfig['color']?.toString();
    
    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: points.length,
        itemBuilder: (context, index) {
          final point = points[index];
          final double barHeight = (mergedConfig['barHeight'] as num?)?.toDouble() ?? 18.0;
          final double barRadius = (mergedConfig['barRadius'] as num?)?.toDouble() ?? 4.0;
          
          final val = point.percentage ?? point.value ?? 0;
          final target = 100.0;
          final colorHex = overallColor ?? point.color ?? '#6C63FF';
          
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
                      filledColor: _hexColor(colorHex),
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
