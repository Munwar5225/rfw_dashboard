import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class PieWidget extends StatefulWidget {
  final ChartSeriesV2 series;
  final Map<String, dynamic> visualConfig;
  final String? centerText;
  final bool isHalf;

  const PieWidget({
    Key? key,
    required this.series,
    required this.visualConfig,
    this.centerText,
    this.isHalf = false,
  }) : super(key: key);

  @override
  State<PieWidget> createState() => _PieWidgetState();
}

class _PieWidgetState extends State<PieWidget> {
  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final double holeRadius = (widget.visualConfig['holeRadius'] as num?)?.toDouble() ?? 70.0;
    final bool showCenterText = (widget.visualConfig['showCenterText'] as bool?) ?? true;
    final bool showLegend = (widget.visualConfig['showLegend'] as bool?) ?? true;
    final double startAngle = widget.isHalf ? ((widget.visualConfig['startAngle'] as num?)?.toDouble() ?? 180.0) : 0.0;
    
    final sections = widget.series.sections ?? [];

    Widget chart = PieChart(
      PieChartData(
        startDegreeOffset: startAngle,
        sectionsSpace: 2,
        centerSpaceRadius: holeRadius,
        sections: sections.map((section) {
          final color = _hexColor(section.color ?? '#6C63FF');
          final radius = (widget.visualConfig['radius'] as num?)?.toDouble() ?? 30.0;
          final showValues = (widget.visualConfig['showValues'] as bool?) ?? false;
          
          return PieChartSectionData(
            value: section.value ?? 0.0,
            color: color,
            title: showValues ? section.key : '',
            radius: radius,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEFEFF4)),
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
      swapAnimationCurve: Curves.easeInOut,
    );

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.isHalf ? 150 : 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                chart,
                if (showCenterText && widget.centerText != null)
                  Positioned(
                    child: Text(
                      widget.centerText!,
                      style: const TextStyle(
                        color: Color(0xFFEFEFF4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showLegend && widget.series.legend != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: widget.series.legend!.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _hexColor(item.legendColor),
                        shape: BoxShape.circle,
                      ),
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
