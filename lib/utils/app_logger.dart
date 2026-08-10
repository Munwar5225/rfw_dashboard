import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central logger for the entire app.
/// Usage:
///   AppLogger.api.i('Fetching /views');
///   AppLogger.rfw.d('Parsing rfwtxt for LineChartView');
///   AppLogger.app.e('Something went wrong', error: e, stackTrace: s);
class AppLogger {
  AppLogger._();

  static final Logger _base = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// For API request/response logs
  static final Logger api = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: _TaggedOutput('[API]'),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// For RFW runtime/widget logs
  static final Logger rfw = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: _TaggedOutput('[RFW]'),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// For general app logs
  static final Logger app = _base;
}

/// Custom output that prepends a tag to every log line.
class _TaggedOutput extends LogOutput {
  _TaggedOutput(this.tag);
  final String tag;

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ignore: avoid_print
      print('$tag $line');
    }
  }
}
