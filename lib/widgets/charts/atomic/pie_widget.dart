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

  Map<String, dynamic> _getMergedConfig() {
    final Map<String, dynamic> globalProps = widget.visualConfig;
    final graphsConfig = globalProps['graphs'] as Map<String, dynamic>?;
    final Map<String, dynamic> graphOverrides = (graphsConfig?[widget.series.seriesKey] as Map<String, dynamic>?) ?? {};
    
    return {
      ...globalProps,
      ...widget.series.visualConfig, // Legacy support just in case
      ...graphOverrides,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mergedConfig = _getMergedConfig();
    
    final bool showCenterText = (mergedConfig['showCenterText'] as bool?) ?? true;
    final bool showLegend = (mergedConfig['showLegend'] as bool?) ?? true;
    final bool isClickable = (mergedConfig['isClickable'] as bool?) ?? false;
    final String? description = mergedConfig['description']?.toString();
    
    final double startAngle = widget.isHalf ? 180.0 : ((mergedConfig['startAngle'] as num?)?.toDouble() ?? 0.0);
    
    final originalSections = widget.series.sections ?? [];
    double totalValue = originalSections.fold(0.0, (sum, sec) => sum + (sec.value ?? 0.0));
    if (totalValue == 0) totalValue = 1; // Prevent division by zero if all 0

    Widget content = Container(
      color: Colors.transparent, // Let parent handle background
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double availableHeight = widget.isHalf ? constraints.maxHeight * 2 : constraints.maxHeight;
                
                final double minDim = availableHeight < availableWidth ? availableHeight : availableWidth;
                final double baseSize = minDim.isInfinite ? 200.0 : minDim;
                
                final double maxTotalRadius = (baseSize / 2.0) * 0.95;

                double cfgHole = (mergedConfig['holeRadius'] as num?)?.toDouble() ?? (maxTotalRadius * 0.7);
                double cfgRadius = (mergedConfig['radius'] as num?)?.toDouble() ?? (maxTotalRadius * 0.3);

                if (cfgHole + cfgRadius > maxTotalRadius) {
                  final scale = maxTotalRadius / (cfgHole + cfgRadius);
                  cfgHole *= scale;
                  cfgRadius *= scale;
                }

                final double holeRadius = cfgHole.clamp(10.0, 150.0);
                final double radius = cfgRadius.clamp(5.0, 60.0);

                final List<PieChartSectionData> pieSections = originalSections.map((section) {
                  final color = _hexColor(section.color ?? '#6C63FF');
                  final showValues = (mergedConfig['showValues'] as bool?) ?? false;
                  
                  return PieChartSectionData(
                    value: section.value ?? 0.0,
                    color: color,
                    title: showValues ? section.value?.toStringAsFixed(0) ?? '' : '',
                    radius: radius,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEFEFF4)),
                  );
                }).toList();

                if (widget.isHalf) {
                  pieSections.add(PieChartSectionData(
                    value: totalValue,
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

                final String? finalCenterText = widget.centerText ?? mergedConfig['centerText']?.toString();

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
          ],
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.series.seriesLabel} clicked!'),
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
}
