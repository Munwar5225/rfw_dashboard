import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/dual_axis_line_widget.dart';

class DualAxisLineScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const DualAxisLineScreen({super.key, required this.config});

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
          child: DualAxisLineWidget(
            seriesList: defaultTab.series,
            visualConfig: config.visualConfig,
          ),
        ),
      ],
    );
  }
}
