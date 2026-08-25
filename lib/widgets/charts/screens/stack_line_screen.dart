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
