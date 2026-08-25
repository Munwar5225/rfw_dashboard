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
    
    // For half pies, we use a start degree of 180 (left edge), and it draws clockwise to 360 (right edge).
    final double startAngle = widget.isHalf ? 180.0 : ((widget.visualConfig['startAngle'] as num?)?.toDouble() ?? 0.0);
    
    final originalSections = widget.series.sections ?? [];
    double totalValue = originalSections.fold(0.0, (sum, sec) => sum + (sec.value ?? 0.0));
    if (totalValue == 0) totalValue = 1; // Prevent division by zero if all 0

    return Container(
      color: Colors.transparent, // Let parent handle background
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine base size depending on if it's a half pie or full pie.
                // A half pie only needs half the height.
                final double availableWidth = constraints.maxWidth;
                final double availableHeight = widget.isHalf ? constraints.maxHeight * 2 : constraints.maxHeight;
                
                final double minDim = availableHeight < availableWidth ? availableHeight : availableWidth;
                final double baseSize = minDim.isInfinite ? 200.0 : minDim;
                
                // We compute the maximum allowed total radius (diameter = baseSize).
                // Let's reserve a tiny margin, so max radius = baseSize / 2 * 0.95.
                final double maxTotalRadius = (baseSize / 2.0) * 0.95;

                // Read from config or use defaults
                double cfgHole = (widget.visualConfig['holeRadius'] as num?)?.toDouble() ?? (maxTotalRadius * 0.7);
                double cfgRadius = (widget.visualConfig['radius'] as num?)?.toDouble() ?? (maxTotalRadius * 0.3);

                // If the sum exceeds our available space, proportionally scale them down!
                if (cfgHole + cfgRadius > maxTotalRadius) {
                  final scale = maxTotalRadius / (cfgHole + cfgRadius);
                  cfgHole *= scale;
                  cfgRadius *= scale;
                }

                final double holeRadius = cfgHole.clamp(10.0, 150.0);
                final double radius = cfgRadius.clamp(5.0, 60.0);

                final List<PieChartSectionData> pieSections = originalSections.map((section) {
                  final color = _hexColor(section.color ?? '#6C63FF');
                  final showValues = (widget.visualConfig['showValues'] as bool?) ?? false;
                  
                  return PieChartSectionData(
                    value: section.value ?? 0.0,
                    color: color,
                    // Use just the value if it's too cramped, or omit string
                    title: showValues ? section.value?.toStringAsFixed(0) ?? '' : '',
                    radius: radius,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEFEFF4)),
                  );
                }).toList();

                // If it's a half pie, we inject a dummy section that takes exactly the total value 
                // (so it takes up the entire bottom 180 degrees) and make it transparent!
                if (widget.isHalf) {
                  pieSections.add(PieChartSectionData(
                    value: totalValue, // 50% of the entire pie
                    color: Colors.transparent,
                    title: '',
                    radius: radius,
                  ));
                }

                Widget chart = PieChart(
                  PieChartData(
                    startDegreeOffset: startAngle,
                    sectionsSpace: 2,
                    centerSpaceRadius: holeRadius,
                    sections: pieSections,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeInOut,
                );

                // If half pie, we use an OverflowBox so the bottom half of the circle
                // just bleeds out invisibly, keeping the top half centered in the available space.
                if (widget.isHalf) {
                  chart = Align(
                    alignment: Alignment.topCenter,
                    child: OverflowBox(
                      maxHeight: baseSize,
                      maxWidth: baseSize,
                      alignment: Alignment.topCenter,
                      child: chart,
                    ),
                  );
                }

                final String? finalCenterText = widget.centerText ?? widget.visualConfig['centerText']?.toString();

                return Stack(
                  alignment: widget.isHalf ? Alignment.bottomCenter : Alignment.center,
                  children: [
                    chart,
                    if (showCenterText && finalCenterText != null)
                      Positioned(
                        bottom: widget.isHalf ? 0 : null,
                        child: Text(
                          finalCenterText,
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
