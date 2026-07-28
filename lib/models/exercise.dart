enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  glutes,
  calves,
  core,
  cardio,
}

extension MuscleGroupInfo on MuscleGroup {
  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.core:
        return 'Core / Abs';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }

  String get emoji {
    switch (this) {
      case MuscleGroup.chest:
        return '🫁';
      case MuscleGroup.back:
        return '🔙';
      case MuscleGroup.shoulders:
        return '🤷';
      case MuscleGroup.biceps:
        return '💪';
      case MuscleGroup.triceps:
        return '🦾';
      case MuscleGroup.quads:
        return '🦵';
      case MuscleGroup.hamstrings:
        return '🦿';
      case MuscleGroup.glutes:
        return '🍑';
      case MuscleGroup.calves:
        return '🐄';
      case MuscleGroup.core:
        return '🧱';
      case MuscleGroup.cardio:
        return '🏃';
    }
  }
}

enum Equipment { barbell, dumbbell, machine, cable, bodyweight, kettlebell, other }

extension EquipmentInfo on Equipment {
  String get label {
    switch (this) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.machine:
        return 'Machine';
      case Equipment.cable:
        return 'Cable';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.other:
        return 'Other';
    }
  }
}

/// A reference exercise from the built-in library.
class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final bool isCompound;
  final int defaultSets;
  final String defaultReps;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    this.isCompound = false,
    this.defaultSets = 3,
    this.defaultReps = '8-12',
  });
}
