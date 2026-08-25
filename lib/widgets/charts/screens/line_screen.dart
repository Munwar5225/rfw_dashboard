import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/line_widget.dart';

class LineScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const LineScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: LineWidget(
            seriesList: defaultTab.series,
            visualConfig: config.visualConfig,
          ),
        ),
      ],
    );
  }
}
