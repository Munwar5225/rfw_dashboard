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

  Map<String, dynamic> _getMergedConfig() {
    final Map<String, dynamic> globalProps = visualConfig;
    final graphsConfig = globalProps['graphs'] as Map<String, dynamic>?;
    final graphOverrides = graphsConfig != null && graphsConfig.isNotEmpty 
        ? graphsConfig.values.first as Map<String, dynamic> 
        : <String, dynamic>{};
    
    return {
      ...globalProps,
      ...graphOverrides,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mergedConfig = _getMergedConfig();
    final String orientation = (mergedConfig['orientation'] as String?) ?? 'horizontal';
    final double maxValue = (mergedConfig['maxValue'] as num?)?.toDouble() ?? 100.0;
    final String filledColorStr = (mergedConfig['filledColor'] as String?) ?? point.color ?? '#6C63FF';
    final String emptyColorStr = (mergedConfig['emptyColor'] as String?) ?? '#E0E0E0';
    final double barHeight = (mergedConfig['barHeight'] as num?)?.toDouble() ?? 24.0;
    final double barRadius = (mergedConfig['barRadius'] as num?)?.toDouble() ?? 12.0;
    final bool showPercentage = (mergedConfig['showPercentage'] as bool?) ?? true;
    final bool showValue = (mergedConfig['showValue'] as bool?) ?? true;
    final bool showLabels = (mergedConfig['showLabels'] as bool?) ?? true;
    
    final bool isClickable = (mergedConfig['isClickable'] as bool?) ?? false;
    final String? description = mergedConfig['description']?.toString();

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

    Widget content = Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: orientation == 'horizontal'
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLabels && point.key != null) ...[
                  Text(point.key!, style: const TextStyle(color: Color(0xFFEFEFF4))),
                  const SizedBox(height: 8),
                ],
                bar,
                if (showValue) ...[
                  const SizedBox(height: 8),
                  Text(value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF9A9AB0))),
                ],
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                bar,
                if ((showLabels && point.key != null) || showValue || description != null) ...[
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showLabels && point.key != null) Text(point.key!, style: const TextStyle(color: Color(0xFFEFEFF4))),
                      if (showValue) Text(value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF9A9AB0))),
                      if (description != null) Text(description, style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  )
                ]
              ],
            ),
    );

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${point.key ?? 'Single bar'} clicked!'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF6C63FF),
            ),
          );
        },
        child: content,
      );
    }
    
    return content;
  }
}
