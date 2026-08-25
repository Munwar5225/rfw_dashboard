import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/pie_widget.dart';
import '../atomic/bar_widget.dart';

class TwoPieTwoBarScreen extends StatelessWidget {
  final ChartConfigV2 config;

  const TwoPieTwoBarScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final defaultTab = config.defaultTab;
    if (defaultTab == null || defaultTab.series.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.white)),
      );
    }

    final pieSeries = defaultTab.series
        .where((s) => s.seriesType == 'pie')
        .take(2)
        .toList();
    final barSeries = defaultTab.series
        .where((s) => s.seriesType == 'bar' || s.seriesType == 'horizontal_bar')
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title,
                style: const TextStyle(
                  color: Color(0xFFEFEFF4),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (config.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  config.subtitle,
                  style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        if (pieSeries.isNotEmpty)
          Expanded(
            child: Row(
              children: pieSeries
                  .map((s) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              s.seriesLabel,
                              style: const TextStyle(
                                color: Color(0xFFEFEFF4),
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: PieWidget(
                                series: s,
                                visualConfig: config.visualConfig,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        if (barSeries.isNotEmpty)
          Expanded(
            child: Row(
              children: barSeries
                  .map((s) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              s.seriesLabel,
                              style: const TextStyle(
                                color: Color(0xFFEFEFF4),
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: BarWidget(
                                series: s,
                                visualConfig: {
                                  ...config.visualConfig,
                                  'orientation': 'vertical',
                                },
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
