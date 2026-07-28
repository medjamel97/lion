import 'exercise.dart';

/// One exercise slot inside a day plan, with its prescription.
class PlannedExercise {
  final String exerciseId;
  final int sets;
  final String reps;
  final int restSeconds;

  const PlannedExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.restSeconds = 90,
  });

  PlannedExercise copyWith({int? sets, String? reps, int? restSeconds}) {
    return PlannedExercise(
      exerciseId: exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
      };

  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    return PlannedExercise(
      exerciseId: json['exerciseId'] as String,
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: json['reps'] as String? ?? '8-12',
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
    );
  }
}

/// The plan for a single day of the cycle (only meaningful for training days).
class DayPlan {
  final String label;
  final List<MuscleGroup> muscles;
  final List<PlannedExercise> exercises;

  const DayPlan({
    this.label = '',
    this.muscles = const [],
    this.exercises = const [],
  });

  DayPlan copyWith({
    String? label,
    List<MuscleGroup>? muscles,
    List<PlannedExercise>? exercises,
  }) {
    return DayPlan(
      label: label ?? this.label,
      muscles: muscles ?? this.muscles,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'muscles': muscles.map((m) => m.name).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      label: json['label'] as String? ?? '',
      muscles: ((json['muscles'] as List?) ?? [])
          .map((m) => MuscleGroup.values.asNameMap()[m])
          .whereType<MuscleGroup>()
          .toList(),
      exercises: ((json['exercises'] as List?) ?? [])
          .map((e) => PlannedExercise.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// A repeating training cycle, e.g. pattern "1010101" or "1101101".
/// Each character is one day: '1' = training day, '0' = rest day.
/// The cycle repeats indefinitely starting from [startDate].
class WorkoutPlan {
  final String pattern;
  final DateTime startDate;

  /// One entry per day of the cycle. Rest days keep an empty DayPlan.
  final List<DayPlan> days;

  WorkoutPlan({
    required this.pattern,
    required this.startDate,
    required this.days,
  }) : assert(pattern.length == days.length);

  int get cycleLength => pattern.length;

  bool isTrainingDay(int cycleIndex) => pattern[cycleIndex % cycleLength] == '1';

  int get trainingDaysPerCycle => '1'.allMatches(pattern).length;

  /// Average training days per 7-day week for this cycle.
  double get trainingDaysPerWeek => trainingDaysPerCycle * 7 / cycleLength;

  /// Index in the cycle for a given calendar date.
  int cycleIndexFor(DateTime date) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(start).inDays;
    return ((diff % cycleLength) + cycleLength) % cycleLength;
  }

  DayPlan dayPlanFor(DateTime date) => days[cycleIndexFor(date)];

  WorkoutPlan copyWith({
    String? pattern,
    DateTime? startDate,
    List<DayPlan>? days,
  }) {
    return WorkoutPlan(
      pattern: pattern ?? this.pattern,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
    );
  }

  /// Returns a copy with the pattern changed, preserving existing day plans
  /// where possible.
  WorkoutPlan withPattern(String newPattern) {
    final newDays = List<DayPlan>.generate(newPattern.length, (i) {
      if (i < days.length) return days[i];
      return const DayPlan();
    });
    return WorkoutPlan(pattern: newPattern, startDate: startDate, days: newDays);
  }

  WorkoutPlan withDay(int index, DayPlan day) {
    final newDays = List<DayPlan>.from(days);
    newDays[index] = day;
    return copyWith(days: newDays);
  }

  Map<String, dynamic> toJson() => {
        'pattern': pattern,
        'startDate': startDate.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final pattern = json['pattern'] as String? ?? '1010101';
    var days = ((json['days'] as List?) ?? [])
        .map((d) => DayPlan.fromJson(Map<String, dynamic>.from(d)))
        .toList();
    if (days.length != pattern.length) {
      days = List<DayPlan>.generate(
        pattern.length,
        (i) => i < days.length ? days[i] : const DayPlan(),
      );
    }
    return WorkoutPlan(
      pattern: pattern,
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      days: days,
    );
  }

  factory WorkoutPlan.empty() {
    return WorkoutPlan(
      pattern: '1010101',
      startDate: DateTime.now(),
      days: List<DayPlan>.generate(7, (_) => const DayPlan()),
    );
  }
}
