import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/chart_config.dart';
import '../server/api_service.dart';
import '../utils/app_logger.dart';
import '../widgets/dynamic_chart_widgets.dart';

/// Dashboard page for the "Configured Charts" mode.
///
/// Mirrors the existing [DashboardPage] structure but:
/// - Calls [ApiService.getConfigData] instead of [ApiService.getWidgetDescription]
///   + [ApiService.getChartData].
/// - Renders [ChartRenderer] (pure Flutter) instead of [RemoteWidget].
/// - No RFW imports — completely independent.
class ConfiguredDashboardPage extends StatefulWidget {
  const ConfiguredDashboardPage({super.key});

  @override
  State<ConfiguredDashboardPage> createState() =>
      _ConfiguredDashboardPageState();
}

class _ConfiguredDashboardPageState extends State<ConfiguredDashboardPage>
    with SingleTickerProviderStateMixin {
  ChartConfig? _config;
  String _currentView = 'LineChartView';
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _views = [];

  // Computed stats
  double _statMin = 0;
  double _statMax = 0;
  double _statAvg = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fetchViewsAndLoad();
  }

  Future<void> _fetchViewsAndLoad() async {
    try {
      final views = await ApiService.getViews();
      if (mounted) setState(() => _views = views);
      if (views.isNotEmpty) {
        _currentView = views.first['view_name'] as String;
      }
      AppLogger.app.i('Configured mode: fetched ${views.length} views');
    } catch (e) {
      AppLogger.app.w('Configured mode: could not fetch views list: $e');
    }
    _loadView(_currentView, animate: false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Data Loading ────────────────────────────────────────────────────────────

  Future<void> _loadView(String viewName, {bool animate = true}) async {
    AppLogger.app.i('Configured mode: loading view $viewName');
    setState(() => _isLoading = true);

    if (animate) await _fadeController.reverse();

    try {
      final config = await ApiService.getConfigData(viewName);

      // Aggregate y-values for stat cards
      final List<double> yValues;
      if (config.charts != null && config.charts!.isNotEmpty) {
        yValues = config.charts!
            .expand((s) => s.points.map((p) => p.y))
            .toList();
      } else {
        yValues = config.points.map((p) => p.y).toList();
      }

      final cMin = yValues.isEmpty ? 0.0 : yValues.reduce(math.min);
      final cMax = yValues.isEmpty ? 0.0 : yValues.reduce(math.max);
      final cAvg = yValues.isEmpty
          ? 0.0
          : yValues.reduce((a, b) => a + b) / yValues.length;

      if (mounted) {
        setState(() {
          _config        = config;
          _currentView   = viewName;
          _statMin       = cMin;
          _statMax       = cMax;
          _statAvg       = cAvg;
          _isLoading     = false;
          _isInitialized = true;
        });
        AppLogger.app.i('Configured mode: view "$viewName" loaded');
      }
    } catch (e, s) {
      AppLogger.app.e(
        'Configured mode: failed to load "$viewName"',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load: $e');
      }
    }

    if (mounted) _fadeController.forward();
  }

  void _handleEvent(String eventName, Map<String, Object> args) {
    AppLogger.app.d('Configured chart event: $eventName  args: $args');
    switch (eventName) {
      case 'onPointTapped':
        _showSnackBar('📍 Point tapped!');
      case 'onBarTapped':
        _showSnackBar('📊 Bar tapped: index ${args['index']}');
      default:
        AppLogger.app.w('Unhandled event: $eventName');
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: _buildAppBar(),
      body: _isInitialized
          ? _buildBody()
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF03DAC6)),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF03DAC6), Color(0xFF6C63FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF03DAC6).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Configured Charts'),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF03DAC6)),
                )
              : const Icon(Icons.cloud_done_rounded,
                  color: Color(0xFF03DAC6), size: 22),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Chart Selector Chips ────────────────────────────────────────────
          if (_views.isNotEmpty) _buildChipSelector(),

          // ── Stats Row ──────────────────────────────────────────────────────
          _buildStatCards(),

          const SizedBox(height: 8),

          // ── Configured Chart Widget ────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: _config?.height ?? 430,
              child: ChartRenderer(
                config: _config!,
                onEvent: _handleEvent,
              ),
            ),
          ),

          // ── Footer ─────────────────────────────────────────────────────────
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Chart selector chips ────────────────────────────────────────────────────

  Widget _buildChipSelector() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _views.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final view    = _views[i];
          final name    = view['view_name']    as String;
          final display = view['display_name'] as String;
          final type    = view['chart_type']   as String;
          final active  = name == _currentView;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF03DAC6), Color(0xFF6C63FF)],
                    )
                  : null,
              color: active ? null : const Color(0xFF1A1B2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? Colors.transparent : Colors.white12,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFF03DAC6).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (name != _currentView) _loadView(name);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type == 'line'
                            ? Icons.show_chart_rounded
                            : type == 'combined'
                                ? Icons.grid_view_rounded
                                : Icons.bar_chart_rounded,
                        color: active ? Colors.white : const Color(0xFF9A9AB0),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        display,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFF9A9AB0),
                          fontSize: 12,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stat cards ──────────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _statCard('MIN', _statMin, const Color(0xFF03DAC6)),
          const SizedBox(width: 10),
          _statCard('MAX', _statMax, const Color(0xFF6C63FF)),
          const SizedBox(width: 10),
          _statCard('AVG', _statAvg, const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _statCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF03DAC6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text('Config API',
              style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 11)),
          const Icon(Icons.arrow_right_alt_rounded,
              color: Color(0xFF9A9AB0), size: 14),
          Flexible(
            child: Text(
              _currentView,
              style: const TextStyle(
                color: Color(0xFF03DAC6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const Icon(Icons.tune_rounded, color: Color(0xFF03DAC6), size: 12),
        ],
      ),
    );
  }
}
