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
    
    // Collect specific configurations and descriptions
    final graphsConfig = visualConfig['graphs'] as Map<String, dynamic>? ?? {};
    final List<String> descriptions = [];
    bool isAnyClickable = false;
    
    for (var series in seriesList) {
      final override = graphsConfig[series.seriesKey] as Map<String, dynamic>? ?? {};
      if (override['description'] != null) descriptions.add(override['description'].toString());
      if (override['isClickable'] == true) isAnyClickable = true;
    }

    Widget content = Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
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
                      interval: 1,
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
                  final gConf = graphsConfig[series.seriesKey] as Map<String, dynamic>? ?? {};
                  
                  final bool isCurved = (gConf['isCurved'] as bool?) ?? (sConf['isCurved'] as bool?) ?? (visualConfig['isCurved'] as bool?) ?? true;
                  final bool showDots = (gConf['showDots'] as bool?) ?? (sConf['showDots'] as bool?) ?? (visualConfig['showDots'] as bool?) ?? true;
                  final double lineWidth = (gConf['lineWidth'] as num?)?.toDouble() ?? (sConf['lineWidth'] as num?)?.toDouble() ?? (visualConfig['lineWidth'] as num?)?.toDouble() ?? 3.0;
                  final bool showFill = (gConf['showFill'] as bool?) ?? (sConf['showFill'] as bool?) ?? (visualConfig['showFill'] as bool?) ?? false;
                  final double fillOpacity = (visualConfig['fillOpacity'] as num?)?.toDouble() ?? 0.15;
                  
                  final String colorHex = (gConf['color'] as String?) ?? (sConf['color'] as String?) ?? '#6C63FF';
                  final Color color = _hexColor(colorHex);

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
          ),
          if (descriptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...descriptions.map((desc) => Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic),
                )).toList(),
          ]
        ],
      ),
    );

    if (isAnyClickable) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Line chart clicked!'),
              duration: Duration(seconds: 1),
              backgroundColor: Color(0xFF6C63FF),
            ),
          );
        },
        child: content,
      );
    }
    
    return content;
  }
}
