import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class SingleValueBarWidget extends StatelessWidget {
  final ChartDataPointV2 point;
  final Map<String, dynamic> visualConfig;

  const SingleValueBarWidget({
    Key? key,
    required this.point,
    required this.visualConfig,
  }) : super(key: key);

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final String orientation = (visualConfig['orientation'] as String?) ?? 'horizontal';
    final double maxValue = (visualConfig['maxValue'] as num?)?.toDouble() ?? 100.0;
    final String filledColorStr = (visualConfig['filledColor'] as String?) ?? point.color ?? '#6C63FF';
    final String emptyColorStr = (visualConfig['emptyColor'] as String?) ?? '#E0E0E0';
    final double barHeight = (visualConfig['barHeight'] as num?)?.toDouble() ?? 24.0;
    final double barRadius = (visualConfig['barRadius'] as num?)?.toDouble() ?? 12.0;
    final bool showPercentage = (visualConfig['showPercentage'] as bool?) ?? true;
    final bool showValue = (visualConfig['showValue'] as bool?) ?? true;

    final double value = point.value?.toDouble() ?? 0.0;
    final Color filledColor = _hexColor(filledColorStr);
    final Color emptyColor = _hexColor(emptyColorStr);

    final double percentage = (value / maxValue).clamp(0.0, 1.0);
    final int displayPct = (percentage * 100).toInt();

    Widget bar = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, child) {
        if (orientation == 'horizontal') {
          return SizedBox(
            height: barHeight,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: emptyColor,
                    borderRadius: BorderRadius.circular(barRadius),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: val,
                  child: Container(
                    decoration: BoxDecoration(
                      color: filledColor,
                      borderRadius: BorderRadius.circular(barRadius),
                    ),
                  ),
                ),
                if (showPercentage)
                  Center(
                    child: Text(
                      '$displayPct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return SizedBox(
            width: barHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: emptyColor,
                    borderRadius: BorderRadius.circular(barRadius),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: val,
                  child: Container(
                    decoration: BoxDecoration(
                      color: filledColor,
                      borderRadius: BorderRadius.circular(barRadius),
                    ),
                  ),
                ),
                if (showPercentage)
                  Center(
                    child: Text(
                      '$displayPct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );

    return Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: orientation == 'horizontal'
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (point.key != null) ...[
                  Text(point.key!, style: const TextStyle(color: Color(0xFFEFEFF4))),
                  const SizedBox(height: 8),
                ],
                bar,
                if (showValue) ...[
                  const SizedBox(height: 8),
                  Text(value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF9A9AB0))),
                ],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                bar,
                if (point.key != null || showValue) ...[
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (point.key != null) Text(point.key!, style: const TextStyle(color: Color(0xFFEFEFF4))),
                      if (showValue) Text(value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF9A9AB0))),
                    ],
                  )
                ]
              ],
            ),
    );
  }
}
