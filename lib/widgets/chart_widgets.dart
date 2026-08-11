import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

/// Registers custom chart widgets so RFW remote descriptions can reference them.
///
/// The RFW [LocalWidgetBuilder] signature is:
///   Widget Function(BuildContext context, DataSource source)
///
/// Data is read from [source] using path-based API:
///   source.v`<T>`(['key'])         → typed scalar value
///   source.isList(['key'])        → check if list
///   source.length(['key'])        → list length
///   source.voidHandler(['key'])   → VoidCallback event handler
LocalWidgetLibrary createChartWidgets(
  void Function(String event, Map<String, Object> args) onEvent,
) {
  return LocalWidgetLibrary({
    // ── LineChartWidget ────────────────────────────────────────────────────
    'LineChartWidget': (context, source) {
      final color = Color(source.v<int>(['color']) ?? 0xFF6C63FF);
      final showYAxis = source.v<bool>(['showYAxis']) ?? true;
      final count = source.isList(['points']) ? source.length(['points']) : 0;

      // Build x → label map so getTitlesWidget can show W1, W2 etc.
      final xToLabel = <double, String>{};
      final spots = List.generate(count, (i) {
        final x = source.v<double>(['points', i, 'x']) ??
            source.v<int>(['points', i, 'x'])?.toDouble() ??
            i.toDouble();
        final y = source.v<double>(['points', i, 'y']) ??
            source.v<int>(['points', i, 'y'])?.toDouble() ??
            0.0;
        final label = source.v<String>(['points', i, 'label']) ?? '';
        xToLabel[x] = label;
        return FlSpot(x, y);
      });

      final onTap = source.voidHandler(['onPointTapped']);

      return GestureDetector(
        onTap: onTap,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: showYAxis,
                  reservedSize: showYAxis ? 36 : 0,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final label = xToLabel[value];
                    if (label == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
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
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.28),
                      color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
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
    'BarChartWidget': (context, source) {
      final color = Color(source.v<int>(['color']) ?? 0xFF4CAF50);
      final showYAxis = source.v<bool>(['showYAxis']) ?? true;
      final count = source.isList(['points']) ? source.length(['points']) : 0;

      final groups = List.generate(count, (i) {
        final y = source.v<double>(['points', i, 'y']) ??
            source.v<int>(['points', i, 'y'])?.toDouble() ??
            0.0;
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
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ],
        );
      });

      final labels = List.generate(count, (i) {
        return source.v<String>(['points', i, 'label']) ?? '';
      });

      final onBarTapped =
          source.handler<void Function(FlTouchEvent, BarTouchResponse?)>(
        ['onBarTapped'],
        (trigger) => (FlTouchEvent event, BarTouchResponse? response) {
          if (response?.spot != null) {
            trigger({'index': response!.spot!.touchedBarGroupIndex});
          }
        },
      );

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showYAxis,
                reservedSize: showYAxis ? 36 : 0,
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: groups,
          barTouchData: BarTouchData(
            enabled: onBarTapped != null,
            touchCallback: onBarTapped,
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
    'ChartHeader': (context, source) {
      final title = source.v<String>(['title']) ?? 'Chart';
      final subtitle = source.v<String>(['subtitle']) ?? '';

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
    // Navigation is now handled by the AppBar dropdown — this is hidden.
    'ChartSwitchButton': (context, source) => const SizedBox.shrink(),
  });
}
