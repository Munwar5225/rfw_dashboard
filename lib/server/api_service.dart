import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/app_logger.dart';

/// Replaces MockServer — fetches real data from Railway backend.
class ApiService {
  ApiService._();

  // ── Widget Description ───────────────────────────────────────────────────

  /// Fetches rfwtxt layout text for [viewName].
  /// Flutter passes this to parseLibraryFile().
  static Future<String> getWidgetDescription(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/widgets/$viewName');

    AppLogger.api.i('→ GET $uri');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /widgets/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)',
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
  /// Returns a Map matching Flutter DynamicContent.updateAll() shape.
  static Future<Map<String, Object>> getChartData(String viewName) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/data/$viewName');

    AppLogger.api.i('→ GET $uri');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /data/$viewName  '
        '(${stopwatch.elapsedMilliseconds}ms | ${res.bodyBytes.length}B)',
      );

      if (res.statusCode != 200) {
        AppLogger.api.e('Data load failed: ${res.statusCode} ${res.body}');
        throw Exception('Failed to load data "$viewName": ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final rawPoints = json['points'] as List<dynamic>;
      final points = rawPoints
          .map((p) => <String, Object>{
                'x': (p['x'] as num).toDouble(),
                'y': (p['y'] as num).toDouble(),
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

      AppLogger.api.d(
        'Data parsed for "$viewName": '
        '${points.length} points | title="${result['title']}"',
      );

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

    AppLogger.api.i('→ GET $uri');
    final stopwatch = Stopwatch()..start();

    try {
      final res = await http.get(uri);
      stopwatch.stop();

      AppLogger.api.i(
        '← ${res.statusCode} /views  '
        '(${stopwatch.elapsedMilliseconds}ms)',
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
}
