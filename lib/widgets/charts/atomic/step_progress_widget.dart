import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

class StepProgressWidget extends StatefulWidget {
  final ChartSeriesV2 series;
  final Map<String, dynamic> visualConfig;

  const StepProgressWidget({
    Key? key,
    required this.series,
    required this.visualConfig,
  }) : super(key: key);

  @override
  State<StepProgressWidget> createState() => _StepProgressWidgetState();
}

class _StepProgressWidgetState extends State<StepProgressWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
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
    final bool isVertical = (mergedConfig['isVertical'] as bool?) ?? false;
    final double stepSize = (mergedConfig['stepSize'] as num?)?.toDouble() ?? 28.0;
    final double connectorWidth = (mergedConfig['connectorWidth'] as num?)?.toDouble() ?? 3.0;
    final bool showLabel = (mergedConfig['showLabel'] as bool?) ?? true;
    final bool showValue = (mergedConfig['showValue'] as bool?) ?? false;
    
    final Color completedColor = _hexColor((mergedConfig['completedColor'] as String?) ?? '#6C63FF');
    final Color pendingColor = _hexColor((mergedConfig['pendingColor'] as String?) ?? '#E0E0E0');
    
    final bool isClickable = (mergedConfig['isClickable'] as bool?) ?? false;
    final String? description = mergedConfig['description']?.toString();

    final points = widget.series.points ?? [];

    Widget content = Container(
      color: const Color(0xFF1A1B2E),
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: StepProgressPainter(
              points: points,
              isVertical: isVertical,
              stepSize: stepSize,
              connectorWidth: connectorWidth,
              completedColor: completedColor,
              pendingColor: pendingColor,
              progress: _controller.value,
            ),
            child: _buildLabels(points, isVertical, stepSize, showLabel, showValue),
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

  Widget _buildLabels(List<ChartDataPointV2> points, bool isVertical, double stepSize, bool showLabel, bool showValue) {
    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(points.length, (index) {
          final point = points[index];
          return Container(
            height: 60, // Fixed height for vertical steps
            padding: EdgeInsets.only(left: stepSize + 16),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLabel) Text(point.key, style: const TextStyle(color: Color(0xFFEFEFF4))),
                if (showValue) Text(point.value.toString(), style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 12)),
              ],
            ),
          );
        }),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(points.length, (index) {
          final point = points[index];
          return Expanded(
            child: Container(
              padding: EdgeInsets.only(top: stepSize + 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLabel) Text(point.key, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFEFEFF4), fontSize: 12)),
                  if (showValue) Text(point.value.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9A9AB0), fontSize: 10)),
                ],
              ),
            ),
          );
        }),
      );
    }
  }
}

class StepProgressPainter extends CustomPainter {
  final List<ChartDataPointV2> points;
  final bool isVertical;
  final double stepSize;
  final double connectorWidth;
  final Color completedColor;
  final Color pendingColor;
  final double progress;

  StepProgressPainter({
    required this.points,
    required this.isVertical,
    required this.stepSize,
    required this.connectorWidth,
    required this.completedColor,
    required this.pendingColor,
    required this.progress,
  });

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = connectorWidth;

    List<Offset> centers = [];
    if (isVertical) {
      double ySpacing = 60.0;
      for (int i = 0; i < points.length; i++) {
        centers.add(Offset(stepSize / 2, i * ySpacing + stepSize / 2));
      }
    } else {
      double xSpacing = size.width / (points.length > 1 ? points.length - 1 : 1);
      for (int i = 0; i < points.length; i++) {
        centers.add(Offset(i * xSpacing, stepSize / 2));
      }
    }

    // Draw lines
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      bool bothCompleted = (p1.value == 1) && (p2.value == 1);
      
      linePaint.color = bothCompleted ? completedColor : pendingColor;
      
      // Animate line drawing
      final lengthToDraw = bothCompleted ? progress : 1.0;
      final currentP2 = Offset(
        centers[i].dx + (centers[i+1].dx - centers[i].dx) * lengthToDraw,
        centers[i].dy + (centers[i+1].dy - centers[i].dy) * lengthToDraw
      );

      canvas.drawLine(centers[i], currentP2, linePaint);
    }

    // Draw circles
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      bool isCompleted = p.value == 1;
      Color cColor = _hexColor(p.color);
      
      if (isCompleted) {
        fillPaint.color = cColor;
        canvas.drawCircle(centers[i], (stepSize / 2) * progress, fillPaint);
      } else {
        strokePaint.color = pendingColor;
        fillPaint.color = const Color(0xFF1A1B2E); // background
        canvas.drawCircle(centers[i], stepSize / 2, fillPaint);
        canvas.drawCircle(centers[i], stepSize / 2, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StepProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
