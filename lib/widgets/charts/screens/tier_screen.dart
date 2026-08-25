import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/tier_widget.dart';

class TierScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const TierScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }
    
    final series = defaultTab.series.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: TierWidget(
            series: series,
            visualConfig: config.visualConfig,
          ),
        ),
      ],
    );
  }
}
