import 'package:flutter/material.dart';
import '../models/chart_config_v2.dart';
import '../server/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_renderer_v2.dart';

/// Dashboard that uses the V2 API (/config-data/v2/:viewName).
/// Supports all 16 chart types fully configured from the backend.
///
/// Mirrors the structure of the existing [ConfiguredDashboardPage] but
/// uses [ChartConfigV2] and [ChartRendererV2] instead.
class ConfiguredDashboardPageV2 extends StatefulWidget {
  const ConfiguredDashboardPageV2({super.key});

  @override
  State<ConfiguredDashboardPageV2> createState() =>
      _ConfiguredDashboardPageV2State();
}

class _ConfiguredDashboardPageV2State
    extends State<ConfiguredDashboardPageV2> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<ChartConfigV2> _charts = [];
  bool _isLoading = true;
  String? _error;

  // Predefined view names — these match rows in chart_config_v2.
  static const List<String> _viewNames = [
    'v2_pie',
    'v2_quad_pie',
    'v2_2pie_2bar',
    'v2_pie_hbar',
    'v2_bar',
    'v2_stack',
    'v2_stack_toggle',
    'v2_single_bar',
    'v2_tier',
    'v2_half_pie',
    'v2_line',
    'v2_hbar',
    'v2_step',
    'v2_pie_hbar_tab',
    'v2_dual_line',
    'v2_stack_line',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAllCharts();
  }

  Future<void> _loadAllCharts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait(
        _viewNames.map((v) => ApiService.getConfigDataV2(v)),
      );
      if (mounted) {
        setState(() {
          _charts = results;
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

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFEFEFF4), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configured Charts V2',
          style: TextStyle(
            color: Color(0xFFEFEFF4),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6C63FF), size: 22),
            tooltip: 'Refresh',
            onPressed: _loadAllCharts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoader();
    if (_error != null) return _buildError();
    if (_charts.isEmpty) return _buildEmpty();
    return _buildChartList();
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF6C63FF)),
          SizedBox(height: 16),
          Text(
            'Loading charts…',
            style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFFF6B6B)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load charts',
              style: TextStyle(
                  color: Color(0xFFEFEFF4),
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllCharts,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No charts configured.\nRun migration_v2.sql first.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 14),
      ),
    );
  }

  Widget _buildChartList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _charts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _ChartCard(config: _charts[i]),
    );
  }
}

// ── _ChartCard ────────────────────────────────────────────────────────────────

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
          // ── Header ────────────────────────────────────────────────────────
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
          // ── Chart ─────────────────────────────────────────────────────────
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

// ── _ChartTypeBadge ───────────────────────────────────────────────────────────

class _ChartTypeBadge extends StatelessWidget {
  final String chartType;
  const _ChartTypeBadge({required this.chartType});

  static IconData _icon(String t) => switch (t) {
        'pie_chart' || '4pie_chart' || '2pie_2bar' || 'half_pie' =>
          Icons.pie_chart_rounded,
        '1pie_1horizontal_bar' || '1pie_1horizontalbar_tab' =>
          Icons.donut_small_rounded,
        'bar_chart' || '2pie_2bar' => Icons.bar_chart_rounded,
        'horizontal_bar' || '1pie_1horizontal_bar' || 'bar_chart_single_value' =>
          Icons.align_horizontal_left_rounded,
        'stack_chart' || 'stack_with_toggle' || 'stack_with_line' =>
          Icons.stacked_bar_chart_rounded,
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
