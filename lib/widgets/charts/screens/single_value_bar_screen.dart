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
