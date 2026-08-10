import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rfw/formats.dart'
    show parseLibraryFile, encodeLibraryBlob, decodeLibraryBlob;
import 'package:rfw/rfw.dart';

import 'server/api_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';
import 'widgets/chart_widgets.dart';

class RfwDashboardApp extends StatelessWidget {
  const RfwDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RFW Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final Runtime _runtime;
  late final DynamicContent _data;

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

  static const _remoteLib = LibraryName(<String>['remote']);
  static const _coreLib   = LibraryName(<String>['core']);
  static const _chartsLib = LibraryName(<String>['charts']);

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

    _runtime = Runtime();
    _data    = DynamicContent();

    _runtime.update(_coreLib, createCoreWidgets());
    _runtime.update(_chartsLib, createChartWidgets(_handleEvent));

    _fetchViewsAndLoad();
  }

  Future<void> _fetchViewsAndLoad() async {
    try {
      final views = await ApiService.getViews();
      if (mounted) setState(() => _views = views);
      AppLogger.app.i('Fetched ${views.length} views from API');
    } catch (e) {
      AppLogger.app.w('Could not fetch views list: $e');
    }
    _loadView(_currentView, animate: false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Data Loading ──────────────────────────────────────────────────────────

  Future<void> _loadView(String viewName, {bool animate = true}) async {
    AppLogger.app.i('Loading view: $viewName');
    setState(() => _isLoading = true);

    if (animate) await _fadeController.reverse();

    try {
      final results = await Future.wait([
        ApiService.getWidgetDescription(viewName),
        ApiService.getChartData(viewName),
      ]);

      final rfwtxt    = results[0] as String;
      final chartData = results[1] as Map<String, Object>;

      // Compute min / max / avg from points
      final points  = (chartData['points'] as List).cast<Map<String, Object>>();
      final yValues = points.map((p) => (p['y'] as num).toDouble()).toList();
      final cMin = yValues.isEmpty ? 0.0 : yValues.reduce(math.min);
      final cMax = yValues.isEmpty ? 0.0 : yValues.reduce(math.max);
      final cAvg = yValues.isEmpty
          ? 0.0
          : yValues.reduce((a, b) => a + b) / yValues.length;

      if (mounted) {
        setState(() {
          _runtime.update(
            _remoteLib,
            decodeLibraryBlob(encodeLibraryBlob(parseLibraryFile(rfwtxt))),
          );
          _data.updateAll(chartData);
          _currentView = viewName;
          _statMin = cMin;
          _statMax = cMax;
          _statAvg = cAvg;
          _isLoading   = false;
          _isInitialized = true;
        });
        AppLogger.rfw.i('Runtime + data updated for: $viewName');
      }
    } catch (e, s) {
      AppLogger.app.e('Failed to load view: $viewName', error: e, stackTrace: s);
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load: $e');
      }
    }

    if (mounted) _fadeController.forward();
  }

  void _handleEvent(String eventName, Map<String, Object> args) {
    AppLogger.rfw.d('RFW event: $eventName  args: $args');
    switch (eventName) {
      case 'switchView':
        final next = args['view'] as String? ?? 'LineChartView';
        AppLogger.app.i('Switching → $next');
        _loadView(next);
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: _buildAppBar(),
      body: _isInitialized
          ? _buildBody()
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
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
                colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('RFW Dashboard'),
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
                      strokeWidth: 2, color: Color(0xFF6C63FF)),
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
          // ── Chart Selector Chips ──────────────────────────────────────────
          if (_views.isNotEmpty) _buildChipSelector(),

          // ── Stats Row ────────────────────────────────────────────────────
          _buildStatCards(),

          const SizedBox(height: 8),

          // ── Remote Chart Widget ──────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: 430,
              child: RemoteWidget(
                runtime: _runtime,
                data: _data,
                widget: FullyQualifiedWidgetName(_remoteLib, _currentView),
                onEvent: (name, args) =>
                    _handleEvent(name, Map<String, Object>.from(args)),
              ),
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────────
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Chart selector chips ──────────────────────────────────────────────────

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
                      colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
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
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
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
                            : Icons.bar_chart_rounded,
                        color:
                            active ? Colors.white : const Color(0xFF9A9AB0),
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

  // ── Stat cards ────────────────────────────────────────────────────────────

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

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF03DAC6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text('Railway API',
              style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 11)),
          const Icon(Icons.arrow_right_alt_rounded,
              color: Color(0xFF9A9AB0), size: 14),
          Flexible(
            child: Text(
              _currentView,
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const Icon(Icons.wifi_rounded,
              color: Color(0xFF03DAC6), size: 12),
        ],
      ),
    );
  }
}
