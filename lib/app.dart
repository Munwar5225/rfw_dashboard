import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

import 'server/mock_server.dart';
import 'theme/app_theme.dart';
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

// ─────────────────────────────────────────────────────────────────────────────

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

    _runtime = Runtime();
    _data = DynamicContent();

    // Register built-in core widgets (Text, Column, Row, Padding, etc.)
    _runtime.update(
      const LibraryName(<String>['core']),
      createCoreWidgets(),
    );

    // Register our custom chart widget library
    _runtime.update(
      const LibraryName(<String>['charts']),
      createChartWidgets(
        () => context,
        _handleEvent,
      ),
    );

    _loadView(_currentView, animate: false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Server interaction ───────────────────────────────────────────────────

  Future<void> _loadView(String viewName, {bool animate = true}) async {
    setState(() => _isLoading = true);

    if (animate) {
      await _fadeController.reverse();
    }

    // Simulate a tiny network delay for realism
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Fetch remote widget description from mock server
    final rfwtxt = MockServer.getWidgetDescription(viewName);
    _runtime.update(
      const LibraryName(<String>['remote']),
      decodeLibraryBlob(encodeLibraryBlob(parseLibraryFile(rfwtxt))),
    );

    // Fetch data from mock server and push into DynamicContent
    final chartData = MockServer.getChartData(viewName);
    _data.update('.', chartData);

    setState(() {
      _currentView = viewName;
      _isLoading = false;
    });

    _fadeController.forward();
  }

  void _handleEvent(String eventName, Map<String, Object> args) {
    switch (eventName) {
      case 'switchView':
        final nextView = args['view'] as String? ?? 'LineChartView';
        _loadView(nextView);

      case 'onPointTapped':
        _showSnackBar('📍 Line point tapped!');

      case 'onBarTapped':
        final idx = args['index'];
        _showSnackBar('📊 Bar #$idx tapped!');

      default:
        debugPrint('Unhandled RFW event: $eventName  args: $args');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('RFW Dashboard'),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF6C63FF)),
                )
              : const Icon(Icons.cloud_done_rounded,
                  color: Color(0xFF03DAC6), size: 20),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _fadeController.value == 0) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    return Column(
      children: [
        _buildServerBadge(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RemoteWidget(
              runtime: _runtime,
              data: _data,
              widget: FullyQualifiedWidgetName(
                const LibraryName(<String>['remote']),
                _currentView,
              ),
              onEvent: (name, args) =>
                  _handleEvent(name, Map<String, Object>.from(args)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF03DAC6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Serving widget from: ',
            style: TextStyle(color: Color(0xFF9A9AB0), fontSize: 12),
          ),
          Text(
            'MockServer → $_currentView',
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.wifi_rounded, color: Color(0xFF03DAC6), size: 14),
        ],
      ),
    );
  }
}
