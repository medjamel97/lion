import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Horizontal preview of the next 7 days: which are training vs rest, and
/// which past/today sessions are already done.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final plan = state.plan;
    final today = DateTime.now();

    return Row(
      children: List.generate(7, (i) {
        final date = today.add(Duration(days: i));
        final cycleIndex = plan.cycleIndexFor(date);
        final isTraining = plan.isTrainingDay(cycleIndex);
        final done = state.isLoggedOn(date);
        final isToday = i == 0;

        final Color bg;
        final Color fg;
        if (isToday) {
          bg = theme.colorScheme.primary;
          fg = theme.colorScheme.onPrimary;
        } else if (isTraining) {
          bg = theme.colorScheme.primaryContainer;
          fg = theme.colorScheme.onPrimaryContainer;
        } else {
          bg = theme.colorScheme.surfaceContainerHighest;
          fg = theme.colorScheme.onSurfaceVariant;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _weekdays[date.weekday - 1],
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: fg, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: fg, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Icon(
                    done
                        ? Icons.check_circle
                        : isTraining
                            ? Icons.fitness_center
                            : Icons.dark_mode_outlined,
                    size: 14,
                    color: done ? Colors.greenAccent : fg,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
