import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/single_value_bar_widget.dart';

class SingleValueBarScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const SingleValueBarScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty || defaultTab.series.first.points.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }
    
    final point = defaultTab.series.first.points.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleValueBarWidget(point: point, visualConfig: config.visualConfig),
            ),
          ),
        ),
      ],
    );
  }
}
