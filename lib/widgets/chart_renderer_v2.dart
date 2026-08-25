import 'package:flutter/material.dart';
import '../../models/chart_config_v2.dart';
import 'charts/screens/pie_screen.dart';
import 'charts/screens/quad_pie_screen.dart';
import 'charts/screens/two_pie_two_bar_screen.dart';
import 'charts/screens/pie_hbar_screen.dart';
import 'charts/screens/bar_screen.dart';
import 'charts/screens/stack_screen.dart';
import 'charts/screens/single_value_bar_screen.dart';
import 'charts/screens/tier_screen.dart';
import 'charts/screens/half_pie_screen.dart';
import 'charts/screens/line_screen.dart';
import 'charts/screens/step_progress_screen.dart';
import 'charts/screens/pie_hbar_tab_screen.dart';
import 'charts/screens/dual_axis_line_screen.dart';
import 'charts/screens/stack_line_screen.dart';

/// Routes a [ChartConfigV2] to the correct screen widget based on [chartType].
///
/// Supported chart types:
///   pie_chart | 4pie_chart | 2pie_2bar | 1pie_1horizontal_bar |
///   bar_chart | horizontal_bar | stack_chart | stack_with_toggle |
///   bar_chart_single_value | tier_chart | half_pie | line_chart |
///   steper_lines | 1pie_1horizontalbar_tab | 2_axis_line_chart | stack_with_line
class ChartRendererV2 extends StatelessWidget {
  final ChartConfigV2 config;

  const ChartRendererV2({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return switch (config.chartType) {
      'pie_chart'               => PieScreen(config: config),
      '4pie_chart'              => QuadPieScreen(config: config),
      '2pie_2bar'               => TwoPieTwoBarScreen(config: config),
      '1pie_1horizontal_bar'    => PieHBarScreen(config: config),
      'bar_chart'               => BarScreen(config: config),
      'horizontal_bar'          => BarScreen(config: config),
      'stack_chart'             => StackScreen(config: config),
      'stack_with_toggle'       => StackScreen(config: config),
      'bar_chart_single_value'  => SingleValueBarScreen(config: config),
      'tier_chart'              => TierScreen(config: config),
      'half_pie'                => HalfPieScreen(config: config),
      'line_chart'              => LineScreen(config: config),
      'steper_lines'            => StepProgressScreen(config: config),
      '1pie_1horizontalbar_tab' => PieHBarTabScreen(config: config),
      '2_axis_line_chart'       => DualAxisLineScreen(config: config),
      'stack_with_line'         => StackLineScreen(config: config),
      _ => _UnsupportedChart(chartType: config.chartType),
    };
  }
}

class _UnsupportedChart extends StatelessWidget {
  final String chartType;
  const _UnsupportedChart({required this.chartType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_outlined, size: 48, color: Color(0xFF9A9AB0)),
            const SizedBox(height: 12),
            Text(
              'Chart type not supported:\n"$chartType"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
