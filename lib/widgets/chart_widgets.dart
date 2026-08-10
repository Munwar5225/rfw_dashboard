import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

/// Registers custom chart widgets so RFW remote descriptions can reference them.
LocalWidgetLibrary createChartWidgets(
  BuildContext Function() contextGetter,
  void Function(String event, Map<String, Object> args) onEvent,
) {
  return LocalWidgetLibrary({
    // ── LineChartWidget ────────────────────────────────────────────────────
    'LineChartWidget': (context, source, node) {
      final rawPoints = source.isList(node, 'points')
          ? source.asList(node, 'points')
          : const <Object>[];

      final color = Color(
        source.isInt(node, 'color') ? source.asInt(node, 'color') : 0xFF6C63FF,
      );

      final spots = rawPoints.indexed.map((entry) {
        final i = entry.$1;
        final pt = entry.$2 is Map ? entry.$2 as Map : {};
        final x = _toDouble(pt['x']) ?? i.toDouble();
        final y = _toDouble(pt['y']) ?? 0.0;
        return FlSpot(x, y);
      }).toList();

      final onTapCallback = node.containsKey('onPointTapped')
          ? () => onEvent('onPointTapped', {})
          : null;

      return GestureDetector(
        onTap: onTapCallback,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              ),
            ),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 36),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
              ),
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                    radius: 5,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withOpacity(0.15),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1A1B2E),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ),
      );
    },

    // ── BarChartWidget ─────────────────────────────────────────────────────
    'BarChartWidget': (context, source, node) {
      final rawPoints = source.isList(node, 'points')
          ? source.asList(node, 'points')
          : const <Object>[];

      final color = Color(
        source.isInt(node, 'color') ? source.asInt(node, 'color') : 0xFF4CAF50,
      );

      final groups = rawPoints.indexed.map((entry) {
        final i = entry.$1;
        final pt = entry.$2 is Map ? entry.$2 as Map : {};
        final y = _toDouble(pt['y']) ?? 0.0;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: y,
              color: color,
              width: 18,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        );
      }).toList();

      final labels = rawPoints.map((pt) {
        final map = pt is Map ? pt : {};
        return map['label']?.toString() ?? '';
      }).toList();

      final onTapCallback = node.containsKey('onBarTapped')
          ? (FlTouchEvent event, BarTouchResponse? response) {
              if (response?.spot != null) {
                onEvent('onBarTapped',
                    {'index': response!.spot!.touchedBarGroupIndex});
              }
            }
          : null;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 36),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: groups,
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: onTapCallback,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1A1B2E),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    },

    // ── ChartHeader ────────────────────────────────────────────────────────
    'ChartHeader': (context, source, node) {
      final title = source.isString(node, 'title')
          ? source.asString(node, 'title')
          : 'Chart';
      final subtitle = source.isString(node, 'subtitle')
          ? source.asString(node, 'subtitle')
          : '';

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFEFEFF4),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF9A9AB0),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      );
    },

    // ── ChartSwitchButton ──────────────────────────────────────────────────
    'ChartSwitchButton': (context, source, node) {
      final label = source.isString(node, 'label')
          ? source.asString(node, 'label')
          : 'SWITCH';
      final nextView = source.isString(node, 'nextView')
          ? source.asString(node, 'nextView')
          : 'LineChartView';

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onEvent('switchView', {'view': nextView}),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Switch to $label Chart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
