import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/plan_presets.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../widgets/advice_card.dart';
import '../widgets/pattern_editor.dart';
import 'day_planner_screen.dart';

/// Build the training cycle: choose the 1/0 pattern, apply presets, and
/// open each training day to plan muscles & exercises.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final plan = state.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text('Training plan',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            onPressed: () => _showPresets(context),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Presets'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            'Your cycle repeats forever. Tap a day to switch between training (1) and rest (0) — e.g. 1010101 or 1101101.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          PatternEditor(
            pattern: plan.pattern,
            onChanged: (p) => state.savePlan(plan.withPattern(p)),
          ),
          const SizedBox(height: 16),

          // ── Day-by-day planning ─────────────────────────────────────
          Text('Plan each day',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (var i = 0; i < plan.cycleLength; i++) _dayTile(context, i),

          // ── Health check ────────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Health check',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final advice in state.planAdvice) AdviceCard(advice: advice),
        ],
      ),
    );
  }

  Widget _dayTile(BuildContext context, int index) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final plan = state.plan;
    final isTraining = plan.isTrainingDay(index);
    final day = plan.days[index];
    final isToday = plan.cycleIndexFor(DateTime.now()) == index;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: isToday
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: ListTile(
        enabled: isTraining,
        onTap: isTraining
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DayPlannerScreen(dayIndex: index),
                  ),
                )
            : null,
        leading: CircleAvatar(
          backgroundColor: isTraining
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: isTraining
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          child: Text('${index + 1}'),
        ),
        title: Text(
          isTraining
              ? (day.label.isEmpty ? 'Training day' : day.label)
              : 'Rest day',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isTraining ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: isTraining
            ? Text(
                day.muscles.isEmpty
                    ? 'Tap to choose muscles & exercises'
                    : '${day.muscles.map((m) => m.label).join(', ')} · ${day.exercises.length} exercises',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: isTraining
            ? const Icon(Icons.chevron_right)
            : const Icon(Icons.hotel, size: 18),
      ),
    );
  }

  void _showPresets(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text('Proven training splits',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'Applying a preset replaces your current plan (pattern, muscles and exercises).',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              for (final preset in PlanPresets.all)
                Card(
                  child: ListTile(
                    title: Text(preset.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle: Text(preset.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    onTap: () {
                      state.savePlan(preset.toPlan());
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
