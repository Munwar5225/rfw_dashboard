import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/stack_bar_widget.dart';
import '../atomic/line_widget.dart';

class StackLineScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const StackLineScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    final stackSeries = defaultTab.series.where((s) => s.seriesType == 'stack' || s.seriesType == 'bar').firstOrNull;
    final lineSeries = defaultTab.series.where((s) => s.seriesType == 'line').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(config.title, style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 18, fontWeight: FontWeight.bold)),
              if (config.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(config.subtitle, style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 14)),
              ]
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (stackSeries != null)
                StackBarWidget(
                  series: stackSeries,
                  visualConfig: {...config.visualConfig, 'transparentBackground': true},
                  showToggle: false,
                  toggleValue: false,
                ),
              if (lineSeries.isNotEmpty)
                Positioned.fill(
                  child: LineWidget(
                    seriesList: lineSeries,
                    visualConfig: {...config.visualConfig, 'transparentBackground': true},
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
