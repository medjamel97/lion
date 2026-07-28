import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exercise_library.dart';
import '../models/exercise.dart';
import '../models/session_log.dart';
import '../models/workout_plan.dart';
import '../services/plan_validator.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/advice_card.dart';
import '../widgets/spotify_player.dart';
import '../widgets/stat_card.dart';
import '../widgets/week_strip.dart';
import 'workout_session_screen.dart';

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
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // ── Next 7 days ─────────────────────────────────────────────
          const WeekStrip(),
          const SizedBox(height: 12),

          // ── Today hero ──────────────────────────────────────────────
          _TodayHero(
            isTraining: isTraining,
            dayPlan: dayPlan,
            cycleIndex: cycleIndex,
            cycleLength: plan.cycleLength,
            logged: logged,
          ),

          // ── Exercise list for today ─────────────────────────────────
          if (isTraining && dayPlan.exercises.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final pe in dayPlan.exercises)
              _ExerciseTile(
                  exerciseId: pe.exerciseId,
                  sets: pe.sets,
                  reps: pe.reps,
                  restSeconds: pe.restSeconds),
          ],

          // ── Actions ─────────────────────────────────────────────────
          if (isTraining && !logged) ...[
            const SizedBox(height: 12),
            if (dayPlan.exercises.isNotEmpty)
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(dayPlan: dayPlan)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start workout'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _logSession(
                  context,
                  dayPlan.label,
                  dayPlan.muscles.map((m) => m.label).toList(),
                  dayPlan.exercises.length),
              icon: const Icon(Icons.check),
              label: const Text('Mark done without tracking'),
            ),
          ],
          if (isTraining && logged) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.emoji_events, color: LionTheme.gold),
                title: Text('Session completed today 💪',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text('Recover well — see you next session.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
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
                  sub:
                      'of ${plan.trainingDaysPerWeek.toStringAsFixed(1)} planned',
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
            for (final w in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: AdviceCard(advice: w),
              ),
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

class _TodayHero extends StatelessWidget {
  final bool isTraining;
  final DayPlan dayPlan;
  final int cycleIndex;
  final int cycleLength;
  final bool logged;

  const _TodayHero({
    required this.isTraining,
    required this.dayPlan,
    required this.cycleIndex,
    required this.cycleLength,
    required this.logged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkOnGold = Color(0xFF221800);
    final fg = isTraining ? darkOnGold : Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            isTraining ? LionTheme.heroGradient : LionTheme.restGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isTraining ? Icons.fitness_center : Icons.self_improvement,
                  color: fg, size: 20),
              const SizedBox(width: 8),
              Text(
                'TODAY · DAY ${cycleIndex + 1}/$cycleLength',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (logged) Icon(Icons.check_circle, color: fg, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isTraining
                ? (dayPlan.label.isEmpty
                    ? 'TRAINING DAY'
                    : dayPlan.label.toUpperCase())
                : 'REST DAY',
            style: LionTheme.display(size: 30, color: fg),
          ),
          const SizedBox(height: 8),
          if (isTraining && dayPlan.muscles.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final MuscleGroup m in dayPlan.muscles)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isTraining ? darkOnGold : Colors.white)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${m.emoji} ${m.label}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: fg, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          if (!isTraining)
            Text(
              'Recovery is where muscle is built. Sleep well, eat protein, stay hydrated — come back stronger tomorrow.',
              style: theme.textTheme.bodyMedium?.copyWith(color: fg),
            ),
          if (isTraining && dayPlan.muscles.isEmpty)
            Text(
              'No muscles planned for today yet — set them up in the Plan tab.',
              style: theme.textTheme.bodyMedium?.copyWith(color: fg),
            ),
        ],
      ),
    );
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
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading:
            Text(ex.primaryMuscle.emoji, style: const TextStyle(fontSize: 22)),
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
                child:
                    Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
              )
            : null,
      ),
    );
  }
}
