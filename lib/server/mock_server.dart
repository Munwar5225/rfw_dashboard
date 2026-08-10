/// Mock server that simulates a real backend returning RFW widget descriptions
/// and JSON chart data. Swap these static methods with real HTTP calls later.
library;

class MockServer {
  MockServer._();

  // ── Widget Descriptions (rfwtxt format) ──────────────────────────────────

  static String getWidgetDescription(String viewName) {
    switch (viewName) {
      case 'BarChartView':
        return _barChartDescription;
      case 'LineChartView':
      default:
        return _lineChartDescription;
    }
  }

  // ── Chart Data ───────────────────────────────────────────────────────────

  static Map<String, Object> getChartData(String viewName) {
    switch (viewName) {
      case 'BarChartView':
        return {
          'title': 'Monthly Revenue',
          'subtitle': 'Q1–Q2 2026 (in \$K)',
          'points': [
            {'x': 1.0, 'y': 42.0, 'label': 'Jan'},
            {'x': 2.0, 'y': 67.0, 'label': 'Feb'},
            {'x': 3.0, 'y': 55.0, 'label': 'Mar'},
            {'x': 4.0, 'y': 80.0, 'label': 'Apr'},
            {'x': 5.0, 'y': 73.0, 'label': 'May'},
            {'x': 6.0, 'y': 91.0, 'label': 'Jun'},
          ],
          'color': 0xFF4CAF50,
          'nextView': 'LineChartView',
          'nextLabel': 'LINE',
        };
      case 'LineChartView':
      default:
        return {
          'title': 'Sales Over Time',
          'subtitle': 'Weekly sales — last 7 weeks',
          'points': [
            {'x': 1.0, 'y': 15.0, 'label': 'W1'},
            {'x': 2.0, 'y': 28.0, 'label': 'W2'},
            {'x': 3.0, 'y': 22.0, 'label': 'W3'},
            {'x': 4.0, 'y': 45.0, 'label': 'W4'},
            {'x': 5.0, 'y': 38.0, 'label': 'W5'},
            {'x': 6.0, 'y': 60.0, 'label': 'W6'},
            {'x': 7.0, 'y': 55.0, 'label': 'W7'},
          ],
          'color': 0xFF6C63FF,
          'nextView': 'BarChartView',
          'nextLabel': 'BAR',
        };
    }
  }

  // ── rfwtxt Descriptions ──────────────────────────────────────────────────

  static const String _lineChartDescription = '''
import core;
import charts;

widget LineChartView = Column(
  children: [
    ChartHeader(
      title: data.title,
      subtitle: data.subtitle,
    ),
    Expanded(
      child: Padding(
        padding: [16, 0, 16, 16],
        child: LineChartWidget(
          points: data.points,
          color: data.color,
          onPointTapped: event "onPointTapped" {},
        ),
      ),
    ),
    ChartSwitchButton(
      label: data.nextLabel,
      nextView: data.nextView,
    ),
  ],
);
''';

  static const String _barChartDescription = '''
import core;
import charts;

widget BarChartView = Column(
  children: [
    ChartHeader(
      title: data.title,
      subtitle: data.subtitle,
    ),
    Expanded(
      child: Padding(
        padding: [16, 0, 16, 16],
        child: BarChartWidget(
          points: data.points,
          color: data.color,
          onBarTapped: event "onBarTapped" {},
        ),
      ),
    ),
    ChartSwitchButton(
      label: data.nextLabel,
      nextView: data.nextView,
    ),
  ],
);
''';
}
