/// Models for the Configured Charts mode.
///
/// Parsed from the GET /config-data/:viewName API response.
/// All fields have sensible defaults so missing JSON keys never crash.
library;

class ChartPoint {
  final double x;
  final double y;
  final String label;

  const ChartPoint({required this.x, required this.y, required this.label});

  factory ChartPoint.fromJson(Map<String, dynamic> json) => ChartPoint(
        x:     (json['x'] as num?)?.toDouble()  ?? 0.0,
        y:     (json['y'] as num?)?.toDouble()  ?? 0.0,
        label: json['label'] as String?         ?? '',
      );
}

class ChartSeries {
  final String series;
  final String type;       // "line" | "bar"
  final String label;
  final int color;
  final bool isCurved;
  final bool showDots;
  final double lineWidth;
  final double barWidth;
  final double barRadius;
  final bool showValues;
  final List<ChartPoint> points;

  const ChartSeries({
    required this.series,
    required this.type,
    required this.label,
    required this.color,
    required this.isCurved,
    required this.showDots,
    required this.lineWidth,
    required this.barWidth,
    required this.barRadius,
    required this.showValues,
    required this.points,
  });

  factory ChartSeries.fromJson(Map<String, dynamic> json) => ChartSeries(
        series:     json['series']     as String?  ?? '',
        type:       json['type']       as String?  ?? 'line',
        label:      json['label']      as String?  ?? '',
        color:      (json['color']     as num?)?.toInt()    ?? 0xFF6C63FF,
        isCurved:   json['isCurved']   as bool?    ?? true,
        showDots:   json['showDots']   as bool?    ?? true,
        lineWidth:  (json['lineWidth'] as num?)?.toDouble() ?? 3.0,
        barWidth:   (json['barWidth']  as num?)?.toDouble() ?? 18.0,
        barRadius:  (json['barRadius'] as num?)?.toDouble() ?? 6.0,
        showValues: json['showValues'] as bool?    ?? false,
        points: (json['points'] as List<dynamic>?)
                ?.map((p) => ChartPoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ChartConfig {
  final String title;
  final String subtitle;
  final String chartType;   // "line" | "bar" | "combined"
  final int color;
  // axis / grid
  final bool showYAxis;
  final bool showValues;
  final bool showGrid;
  final double height;
  // line
  final bool isCurved;
  final bool showDots;
  final double lineWidth;
  // bar
  final double barWidth;
  final double barRadius;
  // data
  final List<ChartPoint> points;
  final List<ChartSeries>? charts; // combined only

  const ChartConfig({
    required this.title,
    required this.subtitle,
    required this.chartType,
    required this.color,
    required this.showYAxis,
    required this.showValues,
    required this.showGrid,
    required this.height,
    required this.isCurved,
    required this.showDots,
    required this.lineWidth,
    required this.barWidth,
    required this.barRadius,
    required this.points,
    this.charts,
  });

  factory ChartConfig.fromJson(Map<String, dynamic> json) => ChartConfig(
        title:      json['title']      as String?  ?? '',
        subtitle:   json['subtitle']   as String?  ?? '',
        chartType:  json['chartType']  as String?  ?? 'line',
        color:      (json['color']     as num?)?.toInt()    ?? 0xFF6C63FF,
        showYAxis:  json['showYAxis']  as bool?    ?? true,
        showValues: json['showValues'] as bool?    ?? false,
        showGrid:   json['showGrid']   as bool?    ?? true,
        height:     (json['height']    as num?)?.toDouble() ?? 430.0,
        isCurved:   json['isCurved']   as bool?    ?? true,
        showDots:   json['showDots']   as bool?    ?? true,
        lineWidth:  (json['lineWidth'] as num?)?.toDouble() ?? 3.0,
        barWidth:   (json['barWidth']  as num?)?.toDouble() ?? 18.0,
        barRadius:  (json['barRadius'] as num?)?.toDouble() ?? 6.0,
        points: (json['points'] as List<dynamic>?)
                ?.map((p) => ChartPoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        charts: (json['charts'] as List<dynamic>?)
                ?.map((c) => ChartSeries.fromJson(c as Map<String, dynamic>))
                .toList(),
      );
}
