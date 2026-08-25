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
    final bool showCenterText = (widget.visualConfig['showCenterText'] as bool?) ?? true;
    final bool showLegend = (widget.visualConfig['showLegend'] as bool?) ?? true;
    final double startAngle = widget.isHalf ? ((widget.visualConfig['startAngle'] as num?)?.toDouble() ?? 180.0) : 0.0;
    
    final sections = widget.series.sections ?? [];

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minDim = constraints.maxHeight < constraints.maxWidth 
                    ? constraints.maxHeight 
                    : constraints.maxWidth;
                final double baseSize = minDim.isInfinite ? 200.0 : minDim;
                
                // Adaptive sizes based on available space
                final double holeRadius = (widget.visualConfig['holeRadius'] as num?)?.toDouble() ?? (baseSize * 0.30).clamp(20.0, 70.0);
                final double radius = (widget.visualConfig['radius'] as num?)?.toDouble() ?? (baseSize * 0.15).clamp(10.0, 40.0);

                Widget chart = PieChart(
                  PieChartData(
                    startDegreeOffset: startAngle,
                    sectionsSpace: 2,
                    centerSpaceRadius: holeRadius,
                    sections: sections.map((section) {
                      final color = _hexColor(section.color ?? '#6C63FF');
                      final showValues = (widget.visualConfig['showValues'] as bool?) ?? false;
                      
                      return PieChartSectionData(
                        value: section.value ?? 0.0,
                        color: color,
                        title: showValues ? section.key : '',
                        radius: radius,
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEFEFF4)),
                      );
                    }).toList(),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeInOut,
                );

                return Stack(
                  alignment: widget.isHalf ? Alignment.bottomCenter : Alignment.center,
                  children: [
                    chart,
                    if (showCenterText && widget.centerText != null)
                      Positioned(
                        bottom: widget.isHalf ? 10 : null,
                        child: Text(
                          widget.centerText!,
                          style: TextStyle(
                            color: const Color(0xFFEFEFF4),
                            fontSize: (holeRadius * 0.4).clamp(10.0, 18.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                );
              }
            ),
          ),
          if (showLegend && widget.series.legend != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: widget.series.legend!.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _hexColor(item.legendColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.legendValue,
                      style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10),
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
