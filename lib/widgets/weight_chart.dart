import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../theme.dart';

/// Dependency-free line chart of body-weight entries with a gradient fill.
class WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final double height;

  const WeightChart({super.key, required this.entries, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Log your weight a few times to see the trend.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WeightChartPainter(
          entries: entries,
          lineColor: LionTheme.gold,
          labelStyle: theme.textTheme.labelSmall!
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final Color lineColor;
  final TextStyle labelStyle;

  _WeightChartPainter({
    required this.entries,
    required this.lineColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const bottomPad = 18.0;
    const topPad = 10.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;

    var minW = entries.map((e) => e.weightKg).reduce(math.min);
    var maxW = entries.map((e) => e.weightKg).reduce(math.max);
    final span = math.max(1.0, maxW - minW);
    minW -= span * 0.15;
    maxW += span * 0.15;

    final firstMs = entries.first.date.millisecondsSinceEpoch;
    final lastMs = entries.last.date.millisecondsSinceEpoch;
    final msSpan = math.max(1, lastMs - firstMs);

    Offset pointFor(WeightEntry e) {
      final x = leftPad +
          chartW * (e.date.millisecondsSinceEpoch - firstMs) / msSpan;
      final y = topPad +
          chartH * (1 - (e.weightKg - minW) / (maxW - minW));
      return Offset(x, y);
    }

    // Grid lines + axis labels (min / mid / max).
    final gridPaint = Paint()
      ..color = labelStyle.color!.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (final t in [0.0, 0.5, 1.0]) {
      final y = topPad + chartH * t;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final value = maxW - (maxW - minW) * t;
      final tp = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(1), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Line path + gradient fill.
    final points = entries.map(pointFor).toList();
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, topPad + chartH)
      ..lineTo(points.first.dx, topPad + chartH)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.30),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(
            Rect.fromLTWH(leftPad, topPad, chartW, chartH)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots.
    final dotPaint = Paint()..color = lineColor;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }

    // First / last date labels.
    String fmt(DateTime d) => '${d.day}/${d.month}';
    final firstLabel = TextPainter(
      text: TextSpan(text: fmt(entries.first.date), style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    firstLabel.paint(canvas, Offset(leftPad, size.height - firstLabel.height));
    final lastLabel = TextPainter(
      text: TextSpan(text: fmt(entries.last.date), style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    lastLabel.paint(
        canvas,
        Offset(size.width - lastLabel.width,
            size.height - lastLabel.height));
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.entries != entries || old.lineColor != lineColor;
}
