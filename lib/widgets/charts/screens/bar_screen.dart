import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/bar_widget.dart';

class BarScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const BarScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    final barSeries = defaultTab.series
        .where((s) => s.seriesType == 'bar' || s.seriesType == 'horizontal_bar')
        .firstOrNull ?? defaultTab.series.first;

    // Determine orientation: config wins, then fall back based on chartType
    final orientation = (config.visualConfig['orientation'] as String?)
        ?? (config.chartType == 'horizontal_bar' ? 'horizontal' : 'vertical');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: BarWidget(
            series: barSeries,
            visualConfig: {...config.visualConfig, 'orientation': orientation},
          ),
        ),
      ],
    );
  }
}
