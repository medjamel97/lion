import '../models/exercise.dart';

/// Built-in library of the most well-known gym exercises, grouped by primary
/// muscle. Default sets/reps follow common hypertrophy guidelines
/// (3-4 sets of 6-12 reps for compounds, 8-15 for isolations).
class ExerciseLibrary {
  ExerciseLibrary._();

  static const List<Exercise> all = [
    // ── Chest ──────────────────────────────────────────────────────────
    Exercise(id: 'bench_press', name: 'Barbell Bench Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders], equipment: Equipment.barbell, isCompound: true, defaultSets: 4, defaultReps: '6-10'),
    Exercise(id: 'incline_db_press', name: 'Incline Dumbbell Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'db_fly', name: 'Dumbbell Fly', primaryMuscle: MuscleGroup.chest, equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'cable_crossover', name: 'Cable Crossover', primaryMuscle: MuscleGroup.chest, equipment: Equipment.cable, defaultSets: 3, defaultReps: '12-15'),
    Exercise(id: 'push_up', name: 'Push-Up', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core], equipment: Equipment.bodyweight, isCompound: true, defaultSets: 3, defaultReps: '10-20'),
    Exercise(id: 'chest_dip', name: 'Chest Dip', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], equipment: Equipment.bodyweight, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'machine_chest_press', name: 'Machine Chest Press', primaryMuscle: MuscleGroup.chest, secondaryMuscles: [MuscleGroup.triceps], equipment: Equipment.machine, isCompound: true, defaultSets: 3, defaultReps: '8-12'),

    // ── Back ───────────────────────────────────────────────────────────
    Exercise(id: 'deadlift', name: 'Deadlift', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.core], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '4-6'),
    Exercise(id: 'pull_up', name: 'Pull-Up', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], equipment: Equipment.bodyweight, isCompound: true, defaultSets: 4, defaultReps: '6-12'),
    Exercise(id: 'lat_pulldown', name: 'Lat Pulldown', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], equipment: Equipment.cable, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'barbell_row', name: 'Barbell Bent-Over Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.core], equipment: Equipment.barbell, isCompound: true, defaultSets: 4, defaultReps: '6-10'),
    Exercise(id: 'seated_cable_row', name: 'Seated Cable Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], equipment: Equipment.cable, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'one_arm_db_row', name: 'One-Arm Dumbbell Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'tbar_row', name: 'T-Bar Row', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.biceps], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'back_extension', name: 'Back Extension', primaryMuscle: MuscleGroup.back, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings], equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '12-15'),

    // ── Shoulders ──────────────────────────────────────────────────────
    Exercise(id: 'ohp', name: 'Overhead Press', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core], equipment: Equipment.barbell, isCompound: true, defaultSets: 4, defaultReps: '6-10'),
    Exercise(id: 'db_shoulder_press', name: 'Dumbbell Shoulder Press', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.triceps], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'lateral_raise', name: 'Lateral Raise', primaryMuscle: MuscleGroup.shoulders, equipment: Equipment.dumbbell, defaultSets: 4, defaultReps: '12-20'),
    Exercise(id: 'front_raise', name: 'Front Raise', primaryMuscle: MuscleGroup.shoulders, equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '12-15'),
    Exercise(id: 'rear_delt_fly', name: 'Rear Delt Fly', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.back], equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '12-20'),
    Exercise(id: 'face_pull', name: 'Face Pull', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.back], equipment: Equipment.cable, defaultSets: 3, defaultReps: '12-20'),
    Exercise(id: 'arnold_press', name: 'Arnold Press', primaryMuscle: MuscleGroup.shoulders, secondaryMuscles: [MuscleGroup.triceps], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),

    // ── Biceps ─────────────────────────────────────────────────────────
    Exercise(id: 'barbell_curl', name: 'Barbell Curl', primaryMuscle: MuscleGroup.biceps, equipment: Equipment.barbell, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'db_curl', name: 'Dumbbell Curl', primaryMuscle: MuscleGroup.biceps, equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '10-12'),
    Exercise(id: 'hammer_curl', name: 'Hammer Curl', primaryMuscle: MuscleGroup.biceps, equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '10-12'),
    Exercise(id: 'preacher_curl', name: 'Preacher Curl', primaryMuscle: MuscleGroup.biceps, equipment: Equipment.machine, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'cable_curl', name: 'Cable Curl', primaryMuscle: MuscleGroup.biceps, equipment: Equipment.cable, defaultSets: 3, defaultReps: '10-15'),

    // ── Triceps ────────────────────────────────────────────────────────
    Exercise(id: 'close_grip_bench', name: 'Close-Grip Bench Press', primaryMuscle: MuscleGroup.triceps, secondaryMuscles: [MuscleGroup.chest], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '8-10'),
    Exercise(id: 'triceps_pushdown', name: 'Triceps Pushdown', primaryMuscle: MuscleGroup.triceps, equipment: Equipment.cable, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'overhead_triceps_ext', name: 'Overhead Triceps Extension', primaryMuscle: MuscleGroup.triceps, equipment: Equipment.dumbbell, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'skull_crusher', name: 'Skull Crusher', primaryMuscle: MuscleGroup.triceps, equipment: Equipment.barbell, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'triceps_dip', name: 'Triceps Dip (Bench)', primaryMuscle: MuscleGroup.triceps, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '10-15'),

    // ── Quads ──────────────────────────────────────────────────────────
    Exercise(id: 'back_squat', name: 'Barbell Back Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.core], equipment: Equipment.barbell, isCompound: true, defaultSets: 4, defaultReps: '5-8'),
    Exercise(id: 'front_squat', name: 'Front Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '6-10'),
    Exercise(id: 'leg_press', name: 'Leg Press', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], equipment: Equipment.machine, isCompound: true, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'leg_extension', name: 'Leg Extension', primaryMuscle: MuscleGroup.quads, equipment: Equipment.machine, defaultSets: 3, defaultReps: '12-15'),
    Exercise(id: 'lunge', name: 'Walking Lunge', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '10-12'),
    Exercise(id: 'bulgarian_split_squat', name: 'Bulgarian Split Squat', primaryMuscle: MuscleGroup.quads, secondaryMuscles: [MuscleGroup.glutes], equipment: Equipment.dumbbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),

    // ── Hamstrings ─────────────────────────────────────────────────────
    Exercise(id: 'romanian_deadlift', name: 'Romanian Deadlift', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '8-10'),
    Exercise(id: 'leg_curl', name: 'Lying Leg Curl', primaryMuscle: MuscleGroup.hamstrings, equipment: Equipment.machine, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'seated_leg_curl', name: 'Seated Leg Curl', primaryMuscle: MuscleGroup.hamstrings, equipment: Equipment.machine, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'good_morning', name: 'Good Morning', primaryMuscle: MuscleGroup.hamstrings, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '8-12'),

    // ── Glutes ─────────────────────────────────────────────────────────
    Exercise(id: 'hip_thrust', name: 'Barbell Hip Thrust', primaryMuscle: MuscleGroup.glutes, secondaryMuscles: [MuscleGroup.hamstrings], equipment: Equipment.barbell, isCompound: true, defaultSets: 4, defaultReps: '8-12'),
    Exercise(id: 'glute_bridge', name: 'Glute Bridge', primaryMuscle: MuscleGroup.glutes, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '12-15'),
    Exercise(id: 'cable_kickback', name: 'Cable Glute Kickback', primaryMuscle: MuscleGroup.glutes, equipment: Equipment.cable, defaultSets: 3, defaultReps: '12-15'),
    Exercise(id: 'sumo_deadlift', name: 'Sumo Deadlift', primaryMuscle: MuscleGroup.glutes, secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.quads, MuscleGroup.back], equipment: Equipment.barbell, isCompound: true, defaultSets: 3, defaultReps: '4-6'),

    // ── Calves ─────────────────────────────────────────────────────────
    Exercise(id: 'standing_calf_raise', name: 'Standing Calf Raise', primaryMuscle: MuscleGroup.calves, equipment: Equipment.machine, defaultSets: 4, defaultReps: '10-15'),
    Exercise(id: 'seated_calf_raise', name: 'Seated Calf Raise', primaryMuscle: MuscleGroup.calves, equipment: Equipment.machine, defaultSets: 4, defaultReps: '12-20'),

    // ── Core ───────────────────────────────────────────────────────────
    Exercise(id: 'plank', name: 'Plank', primaryMuscle: MuscleGroup.core, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '30-60s'),
    Exercise(id: 'crunch', name: 'Crunch', primaryMuscle: MuscleGroup.core, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '15-20'),
    Exercise(id: 'hanging_leg_raise', name: 'Hanging Leg Raise', primaryMuscle: MuscleGroup.core, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'russian_twist', name: 'Russian Twist', primaryMuscle: MuscleGroup.core, equipment: Equipment.bodyweight, defaultSets: 3, defaultReps: '15-20'),
    Exercise(id: 'ab_wheel', name: 'Ab Wheel Rollout', primaryMuscle: MuscleGroup.core, equipment: Equipment.other, defaultSets: 3, defaultReps: '8-12'),
    Exercise(id: 'cable_crunch', name: 'Cable Crunch', primaryMuscle: MuscleGroup.core, equipment: Equipment.cable, defaultSets: 3, defaultReps: '12-15'),

    // ── Cardio ─────────────────────────────────────────────────────────
    Exercise(id: 'treadmill_run', name: 'Treadmill Run', primaryMuscle: MuscleGroup.cardio, equipment: Equipment.machine, defaultSets: 1, defaultReps: '20-30 min'),
    Exercise(id: 'rowing_machine', name: 'Rowing Machine', primaryMuscle: MuscleGroup.cardio, secondaryMuscles: [MuscleGroup.back], equipment: Equipment.machine, isCompound: true, defaultSets: 1, defaultReps: '15-20 min'),
    Exercise(id: 'cycling', name: 'Stationary Bike', primaryMuscle: MuscleGroup.cardio, secondaryMuscles: [MuscleGroup.quads], equipment: Equipment.machine, defaultSets: 1, defaultReps: '20-40 min'),
    Exercise(id: 'jump_rope', name: 'Jump Rope', primaryMuscle: MuscleGroup.cardio, secondaryMuscles: [MuscleGroup.calves], equipment: Equipment.other, defaultSets: 3, defaultReps: '3-5 min'),
    Exercise(id: 'burpees', name: 'Burpees', primaryMuscle: MuscleGroup.cardio, secondaryMuscles: [MuscleGroup.core, MuscleGroup.chest], equipment: Equipment.bodyweight, isCompound: true, defaultSets: 3, defaultReps: '10-15'),
    Exercise(id: 'stair_climber', name: 'Stair Climber', primaryMuscle: MuscleGroup.cardio, secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.calves], equipment: Equipment.machine, defaultSets: 1, defaultReps: '15-25 min'),
  ];

  static final Map<String, Exercise> _byId = {
    for (final e in all) e.id: e,
  };

  static Exercise? byId(String id) => _byId[id];

  static List<Exercise> forMuscle(MuscleGroup muscle) =>
      all.where((e) => e.primaryMuscle == muscle).toList();

  static List<Exercise> forMuscles(Iterable<MuscleGroup> muscles) {
    final set = muscles.toSet();
    return all.where((e) => set.contains(e.primaryMuscle)).toList();
  }
}
