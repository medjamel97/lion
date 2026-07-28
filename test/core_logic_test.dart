import 'package:flutter_test/flutter_test.dart';

import 'package:lion/models/user_profile.dart';
import 'package:lion/models/weight_entry.dart';
import 'package:lion/models/workout_plan.dart';
import 'package:lion/services/health_calculator.dart';
import 'package:lion/services/plan_validator.dart';
import 'package:lion/widgets/spotify_player.dart';

void main() {
  group('WorkoutPlan pattern cycling', () {
    test('1010101 alternates training and rest', () {
      final plan = WorkoutPlan(
        pattern: '1010101',
        startDate: DateTime(2026, 1, 5),
        days: List.generate(7, (_) => const DayPlan()),
      );
      expect(plan.isTrainingDay(0), isTrue);
      expect(plan.isTrainingDay(1), isFalse);
      expect(plan.trainingDaysPerCycle, 4);
      expect(plan.cycleIndexFor(DateTime(2026, 1, 5)), 0);
      expect(plan.cycleIndexFor(DateTime(2026, 1, 12)), 0);
      expect(plan.cycleIndexFor(DateTime(2026, 1, 6)), 1);
      // Dates before the start date wrap correctly.
      expect(plan.cycleIndexFor(DateTime(2026, 1, 4)), 6);
    });

    test('1101101 keeps day plans across pattern edits', () {
      final plan = WorkoutPlan(
        pattern: '1101101',
        startDate: DateTime(2026, 1, 1),
        days: List.generate(7, (_) => const DayPlan(label: 'X')),
      );
      final shorter = plan.withPattern('110');
      expect(shorter.cycleLength, 3);
      expect(shorter.days.first.label, 'X');
      final longer = shorter.withPattern('11011');
      expect(longer.days.length, 5);
    });

    test('JSON round trip', () {
      final plan = WorkoutPlan(
        pattern: '110',
        startDate: DateTime(2026, 2, 1),
        days: const [
          DayPlan(label: 'Push', exercises: [
            PlannedExercise(exerciseId: 'bench_press', sets: 4, reps: '6-10'),
          ]),
          DayPlan(label: 'Pull'),
          DayPlan(),
        ],
      );
      final restored = WorkoutPlan.fromJson(plan.toJson());
      expect(restored.pattern, '110');
      expect(restored.days.first.label, 'Push');
      expect(restored.days.first.exercises.single.exerciseId, 'bench_press');
    });
  });

  group('HealthCalculator', () {
    test('computes BMI, BMR and TDEE for a reference male', () {
      const profile = UserProfile(
        name: 'Test',
        heightCm: 180,
        weightKg: 80,
        age: 30,
        sex: Sex.male,
        activityLevel: ActivityLevel.moderate,
        goal: FitnessGoal.buildMuscle,
      );
      final m = HealthCalculator.compute(profile);
      expect(m.bmi, closeTo(24.7, 0.1));
      expect(m.bmiCategory, 'Healthy weight');
      // Mifflin-St Jeor: 10*80 + 6.25*180 - 5*30 + 5 = 1780
      expect(m.bmr, closeTo(1780, 1));
      expect(m.tdee, closeTo(1780 * 1.55, 1));
      expect(m.targetCalories, closeTo(1780 * 1.55 + 300, 1));
      expect(m.proteinMinG, closeTo(128, 1));
      expect(m.proteinMaxG, closeTo(176, 1));
    });
  });

  group('PlanValidator', () {
    test('flags a cycle with no rest days', () {
      final plan = WorkoutPlan(
        pattern: '1111111',
        startDate: DateTime(2026, 1, 1),
        days: List.generate(7, (_) => const DayPlan()),
      );
      final advice = PlanValidator.validate(plan);
      expect(
        advice.any((a) =>
            a.severity == AdviceSeverity.warning &&
            a.title.contains('No rest days')),
        isTrue,
      );
    });

    test('accepts a healthy alternating plan', () {
      final plan = WorkoutPlan(
        pattern: '1010100',
        startDate: DateTime(2026, 1, 1),
        days: List.generate(7, (_) => const DayPlan()),
      );
      final advice = PlanValidator.validate(plan);
      expect(
        advice.any((a) => a.severity == AdviceSeverity.warning),
        isFalse,
      );
    });
  });

  group('Spotify embed URL', () {
    test('converts playlist links', () {
      expect(
        spotifyEmbedUrl(
            'https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP'),
        'https://open.spotify.com/embed/playlist/37i9dQZF1DX76Wlfdnj7AP?utm_source=generator&theme=0',
      );
    });

    test('rejects non-Spotify links', () {
      expect(spotifyEmbedUrl('https://example.com/foo'), isNull);
      expect(spotifyEmbedUrl('not a url'), isNull);
    });

    test('handles already-embedded links and tracks', () {
      expect(
        spotifyEmbedUrl('https://open.spotify.com/embed/track/abc123'),
        contains('/embed/track/abc123'),
      );
    });

    test('handles locale-prefixed links', () {
      expect(
        spotifyEmbedUrl('https://open.spotify.com/intl-fr/album/xyz789'),
        contains('/embed/album/xyz789'),
      );
    });
  });

  group('WeightEntry', () {
    test('JSON round trip and day key', () {
      final entry = WeightEntry(date: DateTime(2026, 7, 4, 8, 30), weightKg: 81.4);
      final restored = WeightEntry.fromJson(entry.toJson());
      expect(restored.weightKg, 81.4);
      expect(restored.dayKey, '2026-07-04');
      // Same calendar day, different time → same key (one entry per day).
      final evening = WeightEntry(date: DateTime(2026, 7, 4, 22), weightKg: 82);
      expect(evening.dayKey, entry.dayKey);
    });
  });
}
