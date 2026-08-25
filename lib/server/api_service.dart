import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chart_config.dart';
import '../models/chart_config_v2.dart';
import '../utils/app_logger.dart';

/// Replaces MockServer — fetches real data from Railway backend.
class ApiService {
  ApiService._();

  // ── Widget Description ───────────────────────────────────────────────────

  /// Fetches rfwtxt layout text for [viewName].
  /// Flutter passes this to parseLibraryFile().
  static Future<String> getWidgetDescription(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/widgets/$viewName');

    AppLogger.api.i('→ GET $uri\nRequest Body: null');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /widgets/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)\n'
        'Response Body: ${res.body}',
      );

      if (res.statusCode == 200) {
        // Strip \r — RFW parser only handles \n line endings
        final rfwtxt = res.body.replaceAll('\r', '');
        AppLogger.rfw.d('Parsing rfwtxt for "$viewName" (${rfwtxt.length} chars)');
        return rfwtxt;
      }

      AppLogger.api.e('Widget load failed: ${res.statusCode} ${res.body}');
      throw Exception('Failed to load widget "$viewName": ${res.body}');
    } catch (e, s) {
      stopwatch.stop();
      AppLogger.api.e(
        'GET /widgets/$viewName failed after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ── Chart Data ───────────────────────────────────────────────────────────

  /// Fetches chart data for [viewName].
  ///
  /// Handles two response shapes from the backend:
  ///   • Single-chart  → { title, subtitle, color, nextView, nextLabel, points[] }
  ///   • Combined-chart→ { ..., charts[{ series, type, label, color, points[] }], points[] }
  ///
  /// Always returns a [Map] that includes both `points` (for stat cards) and
  /// optionally `charts` (for RFW combined widget state access).
  static Future<Map<String, Object>> getChartData(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/data/$viewName');

    AppLogger.api.i('→ GET $uri\nRequest Body: null');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /data/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)\n'
        'Response Body: ${res.body}',
      );

      if (res.statusCode != 200) {
        AppLogger.api.e('Data load failed: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load data "$viewName": ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      // ── Flat points[] — always present (stat card compat) ──────────────────
      final rawPoints = json['points'] as List<dynamic>;
      final points = rawPoints
          .map((p) => <String, Object>{
                'x':     (p['x'] as num).toDouble(),
                'y':     (p['y'] as num).toDouble(),
                'label': p['label'] as String,
              })
          .toList();

      final result = <String, Object>{
        'title':     json['title']     as String,
        'subtitle':  json['subtitle']  as String,
        'color':     (json['color'] as num).toInt(),
        'nextView':  json['nextView']  as String,
        'nextLabel': json['nextLabel'] as String,
        'points':    points,
      };

      // ── charts[] — present for combined views only ─────────────────────────
      if (json.containsKey('charts')) {
        final rawCharts = json['charts'] as List<dynamic>;
        final charts = rawCharts.map((c) {
          final cPoints = (c['points'] as List<dynamic>)
              .map((p) => <String, Object>{
                    'x':     (p['x'] as num).toDouble(),
                    'y':     (p['y'] as num).toDouble(),
                    'label': p['label'] as String,
                  })
              .toList();
          return <String, Object>{
            'series': c['series'] as String,
            'type':   c['type']   as String,
            'label':  c['label']  as String,
            'color':  (c['color'] as num).toInt(),
            'points': cPoints,
          };
        }).toList();

        result['charts'] = charts;
        AppLogger.api.d(
          'Combined chart "$viewName": ${charts.length} series | '
          'title="${result['title']}"',
        );
      } else {
        AppLogger.api.d(
          'Data parsed for "$viewName": '
          '${points.length} points | title="${result['title']}"',
        );
      }

      return result;
    } catch (e, s) {
      stopwatch.stop();
      AppLogger.api.e(
        'GET /data/$viewName failed after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ── Available Views ──────────────────────────────────────────────────────

  /// Fetches list of all available chart views from DB.
  static Future<List<Map<String, dynamic>>> getViews() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/views');

    AppLogger.api.i('→ GET $uri\nRequest Body: null');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /views  '
        '(${stopwatch.elapsedMilliseconds}ms)\n'
        'Response Body: ${res.body}',
      );

      if (res.statusCode != 200) {
        AppLogger.api.e('Views load failed: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load views: ${res.body}');
      }

      final list = jsonDecode(res.body) as List<dynamic>;
      AppLogger.api.d('Views fetched: ${list.length} views available');
      return list.cast<Map<String, dynamic>>();
    } catch (e, s) {
      stopwatch.stop();
      AppLogger.api.e(
        'GET /views failed after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ── Configured Chart Data ────────────────────────────────────────────────

  /// Fetches chart data + all visual config from GET /config-data/:viewName.
  /// Used exclusively by the Configured Charts mode — RFW mode is unaffected.
  static Future<ChartConfig> getConfigData(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/config-data/$viewName');

    AppLogger.api.i('→ GET $uri\nRequest Body: null');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /config-data/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)\n'
        'Response Body: ${res.body}',
      );

      if (res.statusCode != 200) {
        AppLogger.api.e('Config-data load failed: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load config-data "$viewName": ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      AppLogger.api.d('Config-data parsed for "$viewName": chartType=${json['chartType']}');
      return ChartConfig.fromJson(json);
    } catch (e, s) {
      stopwatch.stop();
      AppLogger.api.e(
        'GET /config-data/$viewName failed after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ── Configured Chart Data V2 (all 16 chart types) ────────────────────────

  /// Fetches full chart config + data from GET /config-data/v2/:viewName.
  /// Returns [ChartConfigV2] which covers all 16 chart types.
  static Future<ChartConfigV2> getConfigDataV2(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/config-data/v2/$viewName');

    AppLogger.api.i('→ GET $uri\nRequest Body: null');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /config-data/v2/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)\n'
        'Response Body: ${res.body}',
      );

      if (res.statusCode != 200) {
        AppLogger.api.e('V2 load failed: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load config-data/v2 "$viewName": ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      AppLogger.api.d(
        'V2 parsed "$viewName": chartType=${json['chartType']} '
        'tabs=${(json['tabs'] as List?)?.length ?? 0}',
      );
      return ChartConfigV2.fromJson(json);
    } catch (e, s) {
      stopwatch.stop();
      AppLogger.api.e(
        'GET /config-data/v2/$viewName failed after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
