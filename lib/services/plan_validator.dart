import '../data/exercise_library.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';

enum AdviceSeverity { good, info, warning }

class PlanAdvice {
  final AdviceSeverity severity;
  final String title;
  final String detail;

  const PlanAdvice({
    required this.severity,
    required this.title,
    required this.detail,
  });
}

/// Checks a plan against widely accepted training & health guidelines:
/// - WHO: 150-300 min moderate activity/week + muscle-strengthening on 2+ days
/// - Recovery: ~48h before training the same muscle hard again
/// - Volume: ~10-20 hard sets per muscle per week is the hypertrophy sweet spot
/// - At least one full rest day per week; avoid 6+ consecutive training days
class PlanValidator {
  PlanValidator._();

  static List<PlanAdvice> validate(WorkoutPlan plan) {
    final advice = <PlanAdvice>[];
    final pattern = plan.pattern;
    final n = pattern.length;

    // ── Rest days ────────────────────────────────────────────────────
    final restDays = '0'.allMatches(pattern).length;
    if (restDays == 0) {
      advice.add(const PlanAdvice(
        severity: AdviceSeverity.warning,
        title: 'No rest days',
        detail:
            'Your cycle has zero rest days. Muscles grow while you recover — schedule at least one full rest day per week to avoid overtraining and injury.',
      ));
    }

    // Longest consecutive training streak (treating the cycle as circular).
    final doubled = pattern + pattern;
    var maxStreak = 0;
    var streak = 0;
    for (var i = 0; i < doubled.length; i++) {
      if (doubled[i] == '1') {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 0;
      }
    }
    if (maxStreak > n) maxStreak = n;
    if (restDays > 0 && maxStreak >= 6) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.warning,
        title: '$maxStreak training days in a row',
        detail:
            'Long streaks without rest increase injury risk and hurt performance. Consider inserting a rest day after 3-5 consecutive sessions.',
      ));
    }

    // ── Weekly frequency vs WHO recommendation ───────────────────────
    final perWeek = plan.trainingDaysPerWeek;
    if (perWeek < 2) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.info,
        title: 'Below WHO strength recommendation',
        detail:
            'You train ${perWeek.toStringAsFixed(1)} days/week. WHO recommends muscle-strengthening activity on at least 2 days per week, plus 150-300 minutes of moderate aerobic activity.',
      ));
    } else if (perWeek <= 6) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.good,
        title: 'Healthy training frequency',
        detail:
            '${perWeek.toStringAsFixed(1)} sessions/week meets WHO guidelines (2+ strength days/week) while leaving room for recovery.',
      ));
    }

    // ── 48h recovery per muscle ──────────────────────────────────────
    final consecutive = <String>{};
    for (var i = 0; i < n; i++) {
      final next = (i + 1) % n;
      if (pattern[i] == '1' && pattern[next] == '1') {
        final a = plan.days[i].muscles.toSet()
          ..remove(MuscleGroup.cardio)
          ..remove(MuscleGroup.core);
        final b = plan.days[next].muscles.toSet()
          ..remove(MuscleGroup.cardio)
          ..remove(MuscleGroup.core);
        for (final m in a.intersection(b)) {
          consecutive.add(m.label);
        }
      }
    }
    if (consecutive.isNotEmpty) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.warning,
        title: 'Same muscle on back-to-back days',
        detail:
            '${consecutive.join(', ')} appear(s) on consecutive training days. Muscles need roughly 48h to recover and grow — space them out or alternate muscle groups.',
      ));
    }

    // ── Weekly volume per muscle (10-20 hard sets sweet spot) ────────
    final weeklySets = <MuscleGroup, double>{};
    for (var i = 0; i < n; i++) {
      if (pattern[i] != '1') continue;
      for (final pe in plan.days[i].exercises) {
        final ex = ExerciseLibrary.byId(pe.exerciseId);
        if (ex == null || ex.primaryMuscle == MuscleGroup.cardio) continue;
        weeklySets[ex.primaryMuscle] =
            (weeklySets[ex.primaryMuscle] ?? 0) + pe.sets * 7 / n;
      }
    }
    final overworked = weeklySets.entries
        .where((e) => e.value > 22)
        .map((e) => '${e.key.label} (${e.value.round()} sets)')
        .toList();
    if (overworked.isNotEmpty) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.warning,
        title: 'Very high weekly volume',
        detail:
            '${overworked.join(', ')} exceed ~20 hard sets/week. Beyond that, extra sets mostly add fatigue, not growth ("junk volume").',
      ));
    }
    final lowVolume = weeklySets.entries
        .where((e) => e.value > 0 && e.value < 8)
        .map((e) => '${e.key.label} (${e.value.round()} sets)')
        .toList();
    if (lowVolume.isNotEmpty) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.info,
        title: 'Low weekly volume for some muscles',
        detail:
            '${lowVolume.join(', ')} get fewer than ~10 sets/week. For muscle growth, 10-20 hard sets per muscle per week is the usual target.',
      ));
    }

    // ── Empty training days ──────────────────────────────────────────
    final emptyDays = <int>[];
    for (var i = 0; i < n; i++) {
      if (pattern[i] == '1' && plan.days[i].exercises.isEmpty) {
        emptyDays.add(i + 1);
      }
    }
    if (emptyDays.isNotEmpty) {
      advice.add(PlanAdvice(
        severity: AdviceSeverity.info,
        title: 'Days without exercises',
        detail:
            'Day ${emptyDays.join(', ')} of your cycle ${emptyDays.length == 1 ? 'is' : 'are'} marked as training but ${emptyDays.length == 1 ? 'has' : 'have'} no exercises yet. Tap a day to plan it.',
      ));
    }

    if (advice.every((a) => a.severity != AdviceSeverity.warning)) {
      advice.insert(
        0,
        const PlanAdvice(
          severity: AdviceSeverity.good,
          title: 'Plan looks healthy',
          detail:
              'Your schedule respects recovery and healthy training habits. Stay consistent — consistency beats intensity.',
        ),
      );
    }

    return advice;
  }
}
