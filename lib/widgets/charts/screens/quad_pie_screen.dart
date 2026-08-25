import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/pie_widget.dart';

class QuadPieScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const QuadPieScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }
    final seriesList = defaultTab.series.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            children: seriesList.map((s) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(s.seriesLabel, style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                Expanded(child: PieWidget(series: s, visualConfig: config.visualConfig)),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }
}
