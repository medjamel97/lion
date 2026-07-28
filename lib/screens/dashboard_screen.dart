import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exercise_library.dart';
import '../models/exercise.dart';
import '../models/session_log.dart';
import '../services/plan_validator.dart';
import '../state/app_state.dart';
import '../widgets/advice_card.dart';
import '../widgets/spotify_player.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final today = DateTime.now();
    final plan = state.plan;
    final cycleIndex = plan.cycleIndexFor(today);
    final isTraining = plan.isTrainingDay(cycleIndex);
    final dayPlan = plan.days[cycleIndex];
    final logged = state.isLoggedOn(today);
    final warnings = state.planAdvice
        .where((a) => a.severity == AdviceSeverity.warning)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hey ${state.profile?.name ?? 'Lion'} 🦁',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // ── Today's session ─────────────────────────────────────────
          Card(
            color: isTraining
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isTraining ? Icons.fitness_center : Icons.hotel,
                        color: isTraining
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTraining
                              ? (dayPlan.label.isEmpty
                                  ? 'Training day'
                                  : dayPlan.label)
                              : 'Rest day',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isTraining
                                ? theme.colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        'Day ${cycleIndex + 1}/${plan.cycleLength}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isTraining
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isTraining && dayPlan.muscles.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final m in dayPlan.muscles)
                          Chip(
                            label: Text('${m.emoji} ${m.label}'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  if (!isTraining)
                    Text(
                      'Recovery is where muscle is built. Sleep well, eat protein, stay hydrated — and come back stronger tomorrow.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),

          // ── Exercise list for today ─────────────────────────────────
          if (isTraining && dayPlan.exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final pe in dayPlan.exercises)
              _ExerciseTile(exerciseId: pe.exerciseId, sets: pe.sets, reps: pe.reps, restSeconds: pe.restSeconds),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: logged
                  ? null
                  : () => _logSession(context, dayPlan.label,
                      dayPlan.muscles.map((m) => m.label).toList(),
                      dayPlan.exercises.length),
              icon: Icon(logged ? Icons.check_circle : Icons.check),
              label: Text(
                  logged ? 'Session completed today 💪' : 'Mark session done'),
            ),
          ],

          // ── Stats row ───────────────────────────────────────────────
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Streak',
                  value: '${state.streak}',
                  sub: 'sessions in a row',
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'This week',
                  value: '${state.sessionsThisWeek}',
                  sub: 'of ${plan.trainingDaysPerWeek.toStringAsFixed(1)} planned',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Total',
                  value: '${state.logs.length}',
                  sub: 'sessions logged',
                  icon: Icons.emoji_events,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),

          // ── Plan warnings ───────────────────────────────────────────
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Coach says',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final w in warnings) AdviceCard(advice: w),
          ],

          // ── Music ───────────────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Training soundtrack',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SpotifyPlayer(url: state.spotifyUrl),
        ],
      ),
    );
  }

  Future<void> _logSession(BuildContext context, String label,
      List<String> muscles, int exerciseCount) async {
    final state = context.read<AppState>();
    final now = DateTime.now();
    await state.logSession(SessionLog(
      id: 'log_${now.millisecondsSinceEpoch}',
      date: now,
      dayLabel: label,
      muscleNames: muscles,
      exercisesCompleted: exerciseCount,
    ));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session logged. Roar! 🦁')),
      );
    }
  }
}

class _ExerciseTile extends StatelessWidget {
  final String exerciseId;
  final int sets;
  final String reps;
  final int restSeconds;

  const _ExerciseTile({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = ExerciseLibrary.byId(exerciseId);
    if (ex == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Text(ex.primaryMuscle.emoji,
            style: const TextStyle(fontSize: 22)),
        title: Text(ex.name,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$sets × $reps · rest ${restSeconds}s · ${ex.equipment.label}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: ex.isCompound
            ? Tooltip(
                message: 'Compound movement',
                child: Icon(Icons.star,
                    size: 18, color: theme.colorScheme.primary),
              )
            : null,
      ),
    );
  }
}
