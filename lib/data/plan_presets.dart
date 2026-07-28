import '../models/exercise.dart';
import '../models/workout_plan.dart';

class PlanPreset {
  final String name;
  final String description;
  final String pattern;
  final List<DayPlan> days;

  const PlanPreset({
    required this.name,
    required this.description,
    required this.pattern,
    required this.days,
  });

  WorkoutPlan toPlan() => WorkoutPlan(
        pattern: pattern,
        startDate: DateTime.now(),
        days: days,
      );
}

const _rest = DayPlan();

/// Popular, evidence-based training splits. Every preset keeps at least one
/// full rest day per week and never hits the same muscle two days in a row.
class PlanPresets {
  PlanPresets._();

  static final List<PlanPreset> all = [
    PlanPreset(
      name: 'Full Body ×3 (1010101)',
      description:
          'Train the whole body every other day. Great for beginners — each muscle recovers 48h and gets trained 3×/week.',
      pattern: '1010101',
      days: [
        _fullBody('Full Body A'),
        _rest,
        _fullBody('Full Body B'),
        _rest,
        _fullBody('Full Body C'),
        _rest,
        _rest,
      ],
    ),
    PlanPreset(
      name: 'Upper / Lower (1101101)',
      description:
          '2 on, 1 off, 2 on, 2 off. Four sessions a week alternating upper and lower body — a proven intermediate split.',
      pattern: '1101101',
      days: [
        _upper('Upper 1'),
        _lower('Lower 1'),
        _rest,
        _upper('Upper 2'),
        _lower('Lower 2'),
        _rest,
        _rest,
      ],
    ),
    PlanPreset(
      name: 'Push / Pull / Legs (1110110)',
      description:
          'The classic PPL: push, pull, legs, rest, then push & pull again. High volume for intermediate/advanced lifters.',
      pattern: '1110110',
      days: [
        _push('Push'),
        _pull('Pull'),
        _legs('Legs'),
        _rest,
        _push('Push 2'),
        _pull('Pull 2'),
        _rest,
      ],
    ),
    PlanPreset(
      name: 'Beginner ×2 + Cardio (1001001)',
      description:
          'Two full-body strength days plus WHO-recommended activity. The minimum effective dose to build muscle and stay healthy.',
      pattern: '1001001',
      days: [
        _fullBody('Full Body A'),
        _rest,
        _rest,
        _fullBody('Full Body B'),
        _rest,
        _rest,
        _cardio('Cardio & Core'),
      ],
    ),
  ];

  static DayPlan _fullBody(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.quads,
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
          MuscleGroup.core,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'back_squat', sets: 3, reps: '6-10'),
          PlannedExercise(exerciseId: 'bench_press', sets: 3, reps: '6-10'),
          PlannedExercise(exerciseId: 'barbell_row', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'ohp', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'plank', sets: 3, reps: '30-60s', restSeconds: 60),
        ],
      );

  static DayPlan _upper(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
          MuscleGroup.biceps,
          MuscleGroup.triceps,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'bench_press', sets: 4, reps: '6-10'),
          PlannedExercise(exerciseId: 'barbell_row', sets: 4, reps: '6-10'),
          PlannedExercise(exerciseId: 'db_shoulder_press', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'lat_pulldown', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'db_curl', sets: 3, reps: '10-12', restSeconds: 60),
          PlannedExercise(exerciseId: 'triceps_pushdown', sets: 3, reps: '10-15', restSeconds: 60),
        ],
      );

  static DayPlan _lower(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
          MuscleGroup.core,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'back_squat', sets: 4, reps: '5-8', restSeconds: 150),
          PlannedExercise(exerciseId: 'romanian_deadlift', sets: 3, reps: '8-10'),
          PlannedExercise(exerciseId: 'hip_thrust', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'standing_calf_raise', sets: 4, reps: '10-15', restSeconds: 60),
          PlannedExercise(exerciseId: 'hanging_leg_raise', sets: 3, reps: '10-15', restSeconds: 60),
        ],
      );

  static DayPlan _push(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'bench_press', sets: 4, reps: '6-10'),
          PlannedExercise(exerciseId: 'incline_db_press', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'ohp', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'lateral_raise', sets: 4, reps: '12-20', restSeconds: 60),
          PlannedExercise(exerciseId: 'triceps_pushdown', sets: 3, reps: '10-15', restSeconds: 60),
          PlannedExercise(exerciseId: 'overhead_triceps_ext', sets: 3, reps: '10-15', restSeconds: 60),
        ],
      );

  static DayPlan _pull(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.back,
          MuscleGroup.biceps,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'deadlift', sets: 3, reps: '4-6', restSeconds: 180),
          PlannedExercise(exerciseId: 'pull_up', sets: 4, reps: '6-12'),
          PlannedExercise(exerciseId: 'seated_cable_row', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'face_pull', sets: 3, reps: '12-20', restSeconds: 60),
          PlannedExercise(exerciseId: 'barbell_curl', sets: 3, reps: '8-12', restSeconds: 60),
          PlannedExercise(exerciseId: 'hammer_curl', sets: 3, reps: '10-12', restSeconds: 60),
        ],
      );

  static DayPlan _legs(String label) => DayPlan(
        label: label,
        muscles: const [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
        ],
        exercises: const [
          PlannedExercise(exerciseId: 'back_squat', sets: 4, reps: '5-8', restSeconds: 150),
          PlannedExercise(exerciseId: 'leg_press', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'leg_curl', sets: 3, reps: '10-15'),
          PlannedExercise(exerciseId: 'hip_thrust', sets: 3, reps: '8-12'),
          PlannedExercise(exerciseId: 'standing_calf_raise', sets: 4, reps: '10-15', restSeconds: 60),
        ],
      );

  static DayPlan _cardio(String label) => DayPlan(
        label: label,
        muscles: const [MuscleGroup.cardio, MuscleGroup.core],
        exercises: const [
          PlannedExercise(exerciseId: 'treadmill_run', sets: 1, reps: '20-30 min', restSeconds: 0),
          PlannedExercise(exerciseId: 'plank', sets: 3, reps: '30-60s', restSeconds: 60),
          PlannedExercise(exerciseId: 'crunch', sets: 3, reps: '15-20', restSeconds: 60),
        ],
      );
}
