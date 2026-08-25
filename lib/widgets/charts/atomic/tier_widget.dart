import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class TierWidget extends StatefulWidget {
  final ChartSeriesV2 series;
  final Map<String, dynamic> visualConfig;

  const TierWidget({
    Key? key,
    required this.series,
    required this.visualConfig,
  }) : super(key: key);

  @override
  State<TierWidget> createState() => _TierWidgetState();
}

class _TierWidgetState extends State<TierWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getMergedConfig() {
    final Map<String, dynamic> globalProps = widget.visualConfig;
    final graphsConfig = globalProps['graphs'] as Map<String, dynamic>?;
    final Map<String, dynamic> graphOverrides = (graphsConfig?[widget.series.seriesKey] as Map<String, dynamic>?) ?? {};
    
    return {
      ...globalProps,
      ...widget.series.visualConfig,
      ...graphOverrides,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mergedConfig = _getMergedConfig();
    final bool showRank = (mergedConfig['showRank'] as bool?) ?? true;
    final bool showVolumn = (mergedConfig['showVolumn'] as bool?) ?? true;
    final bool showValues = (mergedConfig['showValues'] as bool?) ?? true;
    
    final bool isClickable = (mergedConfig['isClickable'] as bool?) ?? false;
    final String? description = mergedConfig['description']?.toString();

    final points = widget.series.points ?? [];

    Widget content = Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: points.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFF2C2C3F)),
        itemBuilder: (context, index) {
          final point = points[index];
          final rank = index + 1;
          
          Color rankColor;
          if (rank == 1) rankColor = _hexColor('#FFD700');
          else if (rank == 2) rankColor = _hexColor('#C0C0C0');
          else if (rank == 3) rankColor = _hexColor('#CD7F32');
          else rankColor = _hexColor(point.color);

          final Animation<double> fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval((index / points.length).clamp(0.0, 1.0), 1.0, curve: Curves.easeIn),
            ),
          );

          return FadeTransition(
            opacity: fadeAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  if (showRank)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: rankColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        rank.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _hexColor(point.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    point.key,
                    style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 16),
                  ),
                  const Spacer(),
                  if (showValues)
                    Text(
                      point.value.toStringAsFixed(1),
                      style: const TextStyle(color: Color(0xFFEFEFF4), fontWeight: FontWeight.bold),
                    ),
                  if (showVolumn && point.volumn != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      point.volumn.toString(),
                      style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 12),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );

    if (description != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(child: content),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    if (isClickable) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.series.seriesLabel} clicked!'),
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
