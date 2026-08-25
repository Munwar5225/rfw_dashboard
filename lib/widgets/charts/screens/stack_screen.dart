import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';
import '../atomic/stack_bar_widget.dart';
import 'chart_screen_helpers.dart';

class StackScreen extends StatefulWidget {
  final ChartConfigV2 config;

  const StackScreen({super.key, required this.config});

  @override
  State<StackScreen> createState() => _StackScreenState();
}

class _StackScreenState extends State<StackScreen> {
  int _selectedTab = 0;
  bool _toggleOn = false;

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.config.chartType == 'stack_with_toggle';
    
    if (widget.config.tabs.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.white)));
    }

    final currentTab = widget.config.tabs[_selectedTab];
    if (currentTab.series.isEmpty) {
      return const Center(child: Text('No series data', style: TextStyle(color: Colors.white)));
    }
    
    final series = currentTab.series.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        buildTabSelector(widget.config.tabs, _selectedTab, (i) {
          setState(() {
            _selectedTab = i;
          });
        }),
        Expanded(
          child: StackBarWidget(
            series: series,
            visualConfig: widget.config.visualConfig,
            showToggle: showToggle,
            toggleValue: _toggleOn,
            onToggleChanged: showToggle ? (v) => setState(() => _toggleOn = v) : null,
          ),
        ),
      ],
    );
  }
}
