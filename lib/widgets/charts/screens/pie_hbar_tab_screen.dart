import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/pie_widget.dart';
import '../atomic/bar_widget.dart';
import 'chart_screen_helpers.dart';

class PieHBarTabScreen extends StatefulWidget {
  final ChartConfigV2 config;

  const PieHBarTabScreen({super.key, required this.config});

  @override
  State<PieHBarTabScreen> createState() => _PieHBarTabScreenState();
}

class _PieHBarTabScreenState extends State<PieHBarTabScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.config.tabs.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    final currentTab = widget.config.tabs[_selectedTab];
    final pieS = currentTab.series.where((s) => s.seriesType == 'pie').firstOrNull;
    final hbarS = currentTab.series.where((s) => s.seriesType == 'horizontal_bar' || s.seriesType == 'bar').firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.config.title, style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 18, fontWeight: FontWeight.bold)),
              if (widget.config.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.config.subtitle, style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 14)),
              ]
            ],
          ),
        ),
        buildTabSelector(widget.config.tabs, _selectedTab, (i) {
          setState(() {
            _selectedTab = i;
          });
        }),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: pieS != null
                    ? PieWidget(series: pieS, visualConfig: widget.config.visualConfig)
                    : const Center(child: Text('No pie data', style: TextStyle(color: Colors.grey))),
              ),
              Expanded(
                child: hbarS != null
                    ? BarWidget(series: hbarS, visualConfig: {...widget.config.visualConfig, 'orientation': 'horizontal'})
                    : const Center(child: Text('No bar data', style: TextStyle(color: Colors.grey))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
