library;

/// V2 chart config models — used by the Configured Charts V2 mode.
/// Covers all 16 chart types with a unified tabs → series → points shape.

// ── LegendItemV2 ─────────────────────────────────────────────────────────────

class LegendItemV2 {
  final String legendValue;
  final String legendColor;

  const LegendItemV2({required this.legendValue, required this.legendColor});

  factory LegendItemV2.fromJson(Map<String, dynamic> json) => LegendItemV2(
        legendValue: json['legendValue'] as String? ?? '',
        legendColor: json['legendColor'] as String? ?? '#6C63FF',
      );
}

// ── ChartDataPointV2 ──────────────────────────────────────────────────────────
/// Universal data point covering bar, line, stack, horizontal-bar, tier, step.

class ChartDataPointV2 {
  final String key;
  final double value;
  // stack
  final double? value2;
  final double? value3;
  // horizontal bar
  final double? percentage;
  final double? target;
  // tier
  final double? volumn;
  // colors
  final String color;
  final String? color2;
  final String? color3;
  final String? targetColor;

  const ChartDataPointV2({
    required this.key,
    required this.value,
    required this.color,
    this.value2,
    this.value3,
    this.percentage,
    this.target,
    this.volumn,
    this.color2,
    this.color3,
    this.targetColor,
  });

  factory ChartDataPointV2.fromJson(Map<String, dynamic> json) =>
      ChartDataPointV2(
        key:         json['key']         as String? ?? '',
        value:       (json['value']      as num?)?.toDouble() ?? 0,
        color:       json['color']       as String? ?? '#6C63FF',
        value2:      (json['value2']     as num?)?.toDouble(),
        value3:      (json['value3']     as num?)?.toDouble(),
        percentage:  (json['percentage'] as num?)?.toDouble(),
        target:      (json['target']     as num?)?.toDouble(),
        volumn:      (json['volumn']     as num?)?.toDouble(),
        color2:      json['color2']      as String?,
        color3:      json['color3']      as String?,
        targetColor: json['targetColor'] as String?,
      );
}

// ── ChartSectionV2 ────────────────────────────────────────────────────────────
/// Pie / half-pie section: key, value, color.

class ChartSectionV2 {
  final String key;
  final double value;
  final String color;

  const ChartSectionV2({
    required this.key,
    required this.value,
    required this.color,
  });

  factory ChartSectionV2.fromJson(Map<String, dynamic> json) => ChartSectionV2(
        key:   json['key']   as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0,
        color: json['color'] as String? ?? '#6C63FF',
      );
}

// ── ChartSeriesV2 ─────────────────────────────────────────────────────────────
/// One series within a tab.
/// [seriesType]: 'bar' | 'line' | 'pie' | 'half_pie' | 'stack' |
///               'horizontal_bar' | 'tier' | 'step' | 'single_value'

class ChartSeriesV2 {
  final String seriesKey;
  final String seriesLabel;
  final String seriesType;
  final Map<String, dynamic> visualConfig;
  final List<LegendItemV2> legend;
  // populated for non-pie types
  final List<ChartDataPointV2> points;
  // populated for pie / half_pie types
  final List<ChartSectionV2> sections;

  const ChartSeriesV2({
    required this.seriesKey,
    required this.seriesLabel,
    required this.seriesType,
    required this.visualConfig,
    required this.legend,
    required this.points,
    required this.sections,
  });

  bool get isPie => seriesType == 'pie' || seriesType == 'half_pie';

  factory ChartSeriesV2.fromJson(Map<String, dynamic> json) => ChartSeriesV2(
        seriesKey:    json['seriesKey']   as String? ?? '',
        seriesLabel:  json['seriesLabel'] as String? ?? '',
        seriesType:   json['seriesType']  as String? ?? 'bar',
        visualConfig: (json['visualConfig'] as Map<String, dynamic>?) ?? {},
        legend: (json['legend'] as List<dynamic>?)
                ?.map((l) => LegendItemV2.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
        points: (json['points'] as List<dynamic>?)
                ?.map((p) => ChartDataPointV2.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        sections: (json['sections'] as List<dynamic>?)
                  ?.map((s) => ChartSectionV2.fromJson(s as Map<String, dynamic>))
                  .toList() ??
            [],
      );
}

// ── ChartTabV2 ────────────────────────────────────────────────────────────────

class ChartTabV2 {
  final String tabLabel;
  final List<ChartSeriesV2> series;

  const ChartTabV2({required this.tabLabel, required this.series});

  /// Convenience: find first series of given type in this tab.
  ChartSeriesV2? seriesOfType(String type) =>
      series.where((s) => s.seriesType == type).firstOrNull;

  factory ChartTabV2.fromJson(Map<String, dynamic> json) => ChartTabV2(
        tabLabel: json['tabLabel'] as String? ?? 'default',
        series: (json['series'] as List<dynamic>?)
                ?.map((s) => ChartSeriesV2.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

// ── ChartConfigV2 ─────────────────────────────────────────────────────────────

class ChartConfigV2 {
  final String viewName;
  final String title;
  final String subtitle;
  final String chartType;
  final double height;
  final Map<String, dynamic> visualConfig;
  final List<ChartTabV2> tabs;

  const ChartConfigV2({
    required this.viewName,
    required this.title,
    required this.subtitle,
    required this.chartType,
    required this.height,
    required this.visualConfig,
    required this.tabs,
  });

  /// The first (or only) tab — for single-tab chart types.
  ChartTabV2? get defaultTab => tabs.firstOrNull;

  /// Convenience: first series of default tab.
  ChartSeriesV2? get defaultSeries => defaultTab?.series.firstOrNull;

  /// Read a bool from visualConfig with a fallback default.
  bool vBool(String key, {bool fallback = false}) =>
      (visualConfig[key] as bool?) ?? fallback;

  /// Read a double from visualConfig with a fallback default.
  double vDouble(String key, {double fallback = 0}) =>
      (visualConfig[key] as num?)?.toDouble() ?? fallback;

  /// Read a String from visualConfig with a fallback default.
  String vString(String key, {String fallback = ''}) =>
      (visualConfig[key] as String?) ?? fallback;

  factory ChartConfigV2.fromJson(Map<String, dynamic> json) => ChartConfigV2(
        viewName:     json['viewName']    as String? ?? '',
        title:        json['title']       as String? ?? '',
        subtitle:     json['subtitle']    as String? ?? '',
        chartType:    json['chartType']   as String? ?? 'bar_chart',
        height:       (json['height']     as num?)?.toDouble() ?? 430,
        visualConfig: (json['visualConfig'] as Map<String, dynamic>?) ?? {},
        tabs: (json['tabs'] as List<dynamic>?)
              ?.map((t) => ChartTabV2.fromJson(t as Map<String, dynamic>))
              .toList() ??
            [],
      );
}
