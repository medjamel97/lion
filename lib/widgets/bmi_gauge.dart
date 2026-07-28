import 'package:flutter/material.dart';

/// Horizontal BMI gauge with WHO category zones and a marker at the
/// user's value.
class BmiGauge extends StatelessWidget {
  final double bmi;

  const BmiGauge({super.key, required this.bmi});

  static const double _min = 14;
  static const double _max = 40;

  static const _zones = <(double, double, Color, String)>[
    (14, 18.5, Color(0xFF4FC3F7), 'Under'),
    (18.5, 25, Color(0xFF66BB6A), 'Healthy'),
    (25, 30, Color(0xFFFFA726), 'Over'),
    (30, 40, Color(0xFFEF5350), 'Obese'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = bmi.clamp(_min, _max);
    final fraction = (clamped - _min) / (_max - _min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 34,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 14,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          for (final (lo, hi, color, _) in _zones)
                            Expanded(
                              flex: ((hi - lo) * 10).round(),
                              child: Container(height: 10, color: color),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: (fraction * w - 7).clamp(0.0, w - 14),
                    top: 0,
                    child: Column(
                      children: [
                        Icon(Icons.arrow_drop_down,
                            size: 22, color: theme.colorScheme.onSurface),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final (lo, hi, color, label) in _zones)
              Expanded(
                flex: ((hi - lo) * 10).round(),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
