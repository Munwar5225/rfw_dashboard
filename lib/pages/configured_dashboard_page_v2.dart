import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/chart_config_v2.dart';
import '../widgets/charts/screens/chart_renderer_v2.dart';
import '../theme.dart';

class ConfiguredDashboardPageV2 extends StatelessWidget {
  const ConfiguredDashboardPageV2({super.key});

  static const List<Map<String, String>> _views = [
    {'name': 'v2_quad_pie', 'label': '4 KPIs'},
    {'name': 'v2_2pie_2bar', 'label': 'Regional'},
    {'name': 'v2_pie_hbar', 'label': 'Target v Achieve'},
    {'name': 'v2_bar', 'label': 'Revenue'},
    {'name': 'v2_stack', 'label': 'Branch Perf'},
    {'name': 'v2_stack_toggle', 'label': 'On/Off'},
    {'name': 'v2_single_bar', 'label': 'KPI'},
    {'name': 'v2_tier', 'label': 'Top Branches'},
    {'name': 'v2_half_pie', 'label': 'Completion'},
    {'name': 'v2_line', 'label': 'Weekly Trend'},
    {'name': 'v2_hbar', 'label': 'Target Ach'},
    {'name': 'v2_step', 'label': 'Process'},
    {'name': 'v2_pie_hbar_tab', 'label': 'Breakdown'},
    {'name': 'v2_dual_line', 'label': 'Dual Axis'},
    {'name': 'v2_stack_line', 'label': 'Stack Line'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _views.length,
      child: Scaffold(
        backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0E17),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFEFEFF4), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Configured Charts V2',
            style: TextStyle(color: Color(0xFFEFEFF4), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFF6C63FF),
            labelColor: const Color(0xFF6C63FF),
            unselectedLabelColor: const Color(0xFF9A9AB0),
            tabs: _views.map((v) => Tab(text: v['label'])).toList(),
          ),
        ),
        body: TabBarView(
          children: _views.map((v) => _ChartTabLoader(viewName: v['name']!)).toList(),
        ),
      ),
    );
  }
}

class _ChartTabLoader extends StatefulWidget {
  final String viewName;
  const _ChartTabLoader({required this.viewName});

  @override
  State<_ChartTabLoader> createState() => _ChartTabLoaderState();
}

class _ChartTabLoaderState extends State<_ChartTabLoader> with AutomaticKeepAliveClientMixin {
  ChartConfigV2? _config;
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true; // Keeps the chart loaded when switching tabs

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final config = await ApiService.getConfigDataV2(widget.viewName);
      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 48),
            const SizedBox(height: 16),
            const Text('Failed to load chart', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChart,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_config == null) return const SizedBox.shrink();

    // Give it a bit of padding so it looks like a card on the screen
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _ChartCard(config: _config!),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final ChartConfigV2 config;
  const _ChartCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style: const TextStyle(
                          color: Color(0xFFEFEFF4),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (config.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          config.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF9A9AB0),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ChartTypeBadge(chartType: config.chartType),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: SizedBox(
              height: config.height,
              child: ChartRendererV2(config: config),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartTypeBadge extends StatelessWidget {
  final String chartType;
  const _ChartTypeBadge({required this.chartType});

  static IconData _icon(String t) => switch (t) {
        'pie_chart' || '4pie_chart' || '2pie_2bar' || 'half_pie' => Icons.pie_chart_rounded,
        '1pie_1horizontal_bar' || '1pie_1horizontalbar_tab' => Icons.donut_small_rounded,
        'bar_chart' || '2pie_2bar' => Icons.bar_chart_rounded,
        'horizontal_bar' || '1pie_1horizontal_bar' || 'bar_chart_single_value' => Icons.align_horizontal_left_rounded,
        'stack_chart' || 'stack_with_toggle' || 'stack_with_line' => Icons.stacked_bar_chart_rounded,
        'line_chart' || '2_axis_line_chart' => Icons.show_chart_rounded,
        'tier_chart' => Icons.emoji_events_rounded,
        'steper_lines' => Icons.linear_scale_rounded,
        _ => Icons.insert_chart_outlined_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(chartType), size: 14, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 4),
          Text(
            chartType.replaceAll('_', ' '),
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
