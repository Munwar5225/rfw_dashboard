import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class DualAxisLineWidget extends StatelessWidget {
  final List<ChartSeriesV2> seriesList;
  final Map<String, dynamic> visualConfig;

  const DualAxisLineWidget({
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
    ChartSeriesV2? leftSeries;
    ChartSeriesV2? rightSeries;
    
    for (var series in seriesList) {
      final axisIndex = series.visualConfig?['axisIndex'] ?? 0;
      if (axisIndex == 0 && leftSeries == null) leftSeries = series;
      else if (axisIndex == 1 && rightSeries == null) rightSeries = series;
    }
    
    leftSeries ??= seriesList.isNotEmpty ? seriesList[0] : null;
    rightSeries ??= seriesList.length > 1 ? seriesList[1] : null;

    final graphsConfig = visualConfig['graphs'] as Map<String, dynamic>? ?? {};
    final leftConfig = leftSeries != null ? (graphsConfig[leftSeries.seriesKey] as Map<String, dynamic>? ?? {}) : {};
    final rightConfig = rightSeries != null ? (graphsConfig[rightSeries.seriesKey] as Map<String, dynamic>? ?? {}) : {};

    final String leftAxisLabel = (visualConfig['leftAxisLabel'] as String?) ?? '';
    final String rightAxisLabel = (visualConfig['rightAxisLabel'] as String?) ?? '';
    final Color leftColor = _hexColor(leftConfig['color']?.toString() ?? visualConfig['leftAxisColor']?.toString() ?? '#6C63FF');
    final Color rightColor = _hexColor(rightConfig['color']?.toString() ?? visualConfig['rightAxisColor']?.toString() ?? '#FF6B6B');
    
    final bool isCurved = (visualConfig['isCurved'] as bool?) ?? true;
    final bool showDots = (visualConfig['showDots'] as bool?) ?? true;
    final double lineWidth = (visualConfig['lineWidth'] as num?)?.toDouble() ?? 2.5;
    final bool showGrid = (visualConfig['showGrid'] as bool?) ?? true;

    final List<String> descriptions = [];
    bool isAnyClickable = false;
    
    if (leftConfig['description'] != null) descriptions.add(leftConfig['description'].toString());
    if (rightConfig['description'] != null) descriptions.add(rightConfig['description'].toString());
    if (leftConfig['isClickable'] == true || rightConfig['isClickable'] == true) isAnyClickable = true;

    double leftMax = 1;
    double rightMax = 1;
    
    if (leftSeries != null && leftSeries.points != null) {
      for (var p in leftSeries.points!) {
        if (p.value != null && p.value! > leftMax) leftMax = p.value!.toDouble();
      }
    }
    if (rightSeries != null && rightSeries.points != null) {
      for (var p in rightSeries.points!) {
        if (p.value != null && p.value! > rightMax) rightMax = p.value!.toDouble();
      }
    }

    final double ratio = leftMax > 0 && rightMax > 0 ? leftMax / rightMax : 1.0;

    List<LineChartBarData> lineBars = [];
    List<String> xLabels = [];
    
    if (leftSeries != null) {
      if (xLabels.isEmpty && leftSeries.points != null) {
        xLabels = leftSeries.points!.map((e) => e.key ?? '').toList();
      }
      lineBars.add(
        LineChartBarData(
          spots: List.generate(leftSeries.points?.length ?? 0, (index) {
            return FlSpot(index.toDouble(), leftSeries!.points![index].value?.toDouble() ?? 0.0);
          }),
          isCurved: isCurved,
          color: leftColor,
          barWidth: lineWidth,
          dotData: FlDotData(show: showDots),
        )
      );
    }
    
    if (rightSeries != null) {
      if (xLabels.isEmpty && rightSeries.points != null) {
        xLabels = rightSeries.points!.map((e) => e.key ?? '').toList();
      }
      lineBars.add(
        LineChartBarData(
          spots: List.generate(rightSeries.points?.length ?? 0, (index) {
            return FlSpot(index.toDouble(), (rightSeries!.points![index].value?.toDouble() ?? 0.0) * ratio);
          }),
          isCurved: isCurved,
          color: rightColor,
          barWidth: lineWidth,
          dotData: FlDotData(show: showDots),
        )
      );
    }

    Widget content = Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: showGrid, drawVerticalLine: false),
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
                            child: Text(xLabels[index], style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: leftAxisLabel.isNotEmpty ? Text(leftAxisLabel, style: TextStyle(color: leftColor)) : null,
                    sideTitles: const SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  rightTitles: AxisTitles(
                    axisNameWidget: rightAxisLabel.isNotEmpty ? Text(rightAxisLabel, style: TextStyle(color: rightColor)) : null,
                    sideTitles: SideTitles(
                      showTitles: rightSeries != null,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final originalValue = value / ratio;
                        return Text(
                          originalValue.toStringAsFixed(0),
                          style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 10),
                        );
                      }
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                minX: -0.2,
                maxX: xLabels.isNotEmpty ? (xLabels.length - 1) + 0.2 : 0,
                borderData: FlBorderData(show: false),
                lineBarsData: lineBars,
                minY: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            children: [
              if (leftSeries != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: leftColor),
                    const SizedBox(width: 8),
                    Text(leftSeries.seriesLabel, style: const TextStyle(color: Color(0xFFEFEFF4))),
                  ],
                ),
              if (rightSeries != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: rightColor),
                    const SizedBox(width: 8),
                    Text(rightSeries.seriesLabel, style: const TextStyle(color: Color(0xFFEFEFF4))),
                  ],
                ),
            ],
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
              content: Text('Dual axis line chart clicked!'),
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
