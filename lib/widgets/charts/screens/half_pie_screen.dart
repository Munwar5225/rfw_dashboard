import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/pie_widget.dart';

class HalfPieScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const HalfPieScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    final series = defaultTab.series.first;
    String centerText = '';
    if (series.sections.isNotEmpty) {
      centerText = '${series.sections.first.value.toStringAsFixed(0)}%';
    } else if (config.visualConfig['centerText'] != null) {
      centerText = config.visualConfig['centerText'] as String;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: PieWidget(
            series: series,
            visualConfig: {...config.visualConfig, 'centerText': centerText},
            isHalf: true,
          ),
        ),
      ],
    );
  }
}
