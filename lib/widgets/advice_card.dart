import 'package:flutter/material.dart';

import '../services/plan_validator.dart';

class AdviceCard extends StatelessWidget {
  final PlanAdvice advice;

  const AdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (advice.severity) {
      AdviceSeverity.good => (Icons.check_circle_outline, Colors.greenAccent),
      AdviceSeverity.info => (Icons.info_outline, Colors.lightBlueAccent),
      AdviceSeverity.warning =>
        (Icons.warning_amber_rounded, Colors.orangeAccent),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(advice.title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    advice.detail,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
