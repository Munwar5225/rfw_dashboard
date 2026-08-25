import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/chart_config.dart';

// ── ChartRenderer ─────────────────────────────────────────────────────────────
/// Top-level widget that switches on [config.chartType] and renders the
/// appropriate chart + header. Replaces RemoteWidget in Configured Charts mode.
class ChartRenderer extends StatelessWidget {
  final ChartConfig config;
  final void Function(String event, Map<String, Object> args)? onEvent;

  const ChartRenderer({super.key, required this.config, this.onEvent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DynamicChartHeader(config: config),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: switch (config.chartType) {
              'bar'      => DynamicBarChart(config: config, onEvent: onEvent),
              'combined' => DynamicCombinedChart(config: config, onEvent: onEvent),
              _          => DynamicLineChart(config: config, onEvent: onEvent),
            },
          ),
        ),
      ],
    );
  }
}

// ── DynamicChartHeader ────────────────────────────────────────────────────────
class DynamicChartHeader extends StatelessWidget {
  final ChartConfig config;

  const DynamicChartHeader({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.title,
            style: const TextStyle(
              color: Color(0xFFEFEFF4),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.subtitle,
            style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 13),
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
  }
}

// ── DynamicLineChart ──────────────────────────────────────────────────────────
class DynamicLineChart extends StatelessWidget {
  final ChartConfig config;
  final void Function(String event, Map<String, Object> args)? onEvent;

  const DynamicLineChart({super.key, required this.config, this.onEvent});

  @override
  Widget build(BuildContext context) {
    final color = Color(config.color);

    final xToLabel = <double, String>{};
    final spots = config.points.map((p) {
      xToLabel[p.x] = p.label;
      return FlSpot(p.x, p.y);
    }).toList();

    return GestureDetector(
      onTap: onEvent == null ? null : () => onEvent!('onPointTapped', {}),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: config.showGrid,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: config.showYAxis,
                reservedSize: config.showYAxis ? 36 : 0,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final label = xToLabel[value];
                  if (label == null || label.isEmpty) {
                    return const SizedBox.shrink();
                  }
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
              isCurved: config.isCurved,
              color: color,
              barWidth: config.lineWidth,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: config.showDots,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              showingIndicators: config.showValues
                  ? List.generate(spots.length, (i) => i)
                  : [],
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
  }
}

// ── DynamicBarChart ───────────────────────────────────────────────────────────
class DynamicBarChart extends StatelessWidget {
  final ChartConfig config;
  final void Function(String event, Map<String, Object> args)? onEvent;

  const DynamicBarChart({super.key, required this.config, this.onEvent});

  @override
  Widget build(BuildContext context) {
    final color = Color(config.color);
    final points = config.points;

    final groups = List.generate(points.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: points[i].y,
            color: color,
            width: config.barWidth,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(config.barRadius)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
        showingTooltipIndicators: config.showValues ? [0] : [],
      );
    });

    final labels = points.map((p) => p.label).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: config.showGrid,
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
              showTitles: config.showYAxis,
              reservedSize: config.showYAxis ? 36 : 0,
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
          enabled: onEvent != null,
          touchCallback: onEvent == null
              ? null
              : (event, response) {
                  if (response?.spot != null) {
                    onEvent!(
                      'onBarTapped',
                      {'index': response!.spot!.touchedBarGroupIndex},
                    );
                  }
                },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1A1B2E),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── DynamicCombinedChart ──────────────────────────────────────────────────────
/// Renders multiple line/bar series from [config.charts].
class DynamicCombinedChart extends StatelessWidget {
  final ChartConfig config;
  final void Function(String event, Map<String, Object> args)? onEvent;

  const DynamicCombinedChart({super.key, required this.config, this.onEvent});

  @override
  Widget build(BuildContext context) {
    final series = config.charts ?? [];
    if (series.isEmpty) {
      return const Center(
        child: Text('No series data', style: TextStyle(color: Colors.white54)),
      );
    }

    // Build all line bars (line-type series only for LineChart)
    // For a truly mixed chart, we render each series stacked — simplest approach
    // is to render all as a LineChart with per-bar overrides.
    final lineBars = series.map((s) {
      final color = Color(s.color);
      final xToLabel = <double, String>{};
      final spots = s.points.map((p) {
        xToLabel[p.x] = p.label;
        return FlSpot(p.x, p.y);
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: s.isCurved,
        color: color,
        barWidth: s.lineWidth,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: s.showDots,
          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        showingIndicators:
            s.showValues ? List.generate(spots.length, (i) => i) : [],
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();

    // Use first series labels for bottom axis
    final xToLabel = <double, String>{};
    for (final p in (series.firstOrNull?.points ?? [])) {
      xToLabel[p.x] = p.label;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: config.showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: config.showYAxis,
              reservedSize: config.showYAxis ? 36 : 0,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final label = xToLabel[value];
                if (label == null || label.isEmpty) {
                  return const SizedBox.shrink();
                }
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
        lineBarsData: lineBars,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1A1B2E),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
