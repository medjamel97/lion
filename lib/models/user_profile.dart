enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

extension ActivityLevelInfo on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary (desk job, little exercise)';
      case ActivityLevel.light:
        return 'Lightly active (1-3 workouts/week)';
      case ActivityLevel.moderate:
        return 'Moderately active (3-5 workouts/week)';
      case ActivityLevel.active:
        return 'Active (6-7 workouts/week)';
      case ActivityLevel.veryActive:
        return 'Very active (physical job + training)';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }
}

enum FitnessGoal { loseFat, maintain, buildMuscle }

extension FitnessGoalInfo on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.loseFat:
        return 'Lose fat';
      case FitnessGoal.maintain:
        return 'Maintain';
      case FitnessGoal.buildMuscle:
        return 'Build muscle';
    }
  }
}

class UserProfile {
  final String name;
  final double heightCm;
  final double weightKg;
  final int age;
  final Sex sex;
  final ActivityLevel activityLevel;
  final FitnessGoal goal;

  const UserProfile({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.sex,
    required this.activityLevel,
    required this.goal,
  });

  UserProfile copyWith({
    String? name,
    double? heightCm,
    double? weightKg,
    int? age,
    Sex? sex,
    ActivityLevel? activityLevel,
    FitnessGoal? goal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'sex': sex.name,
        'activityLevel': activityLevel.name,
        'goal': goal.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 75,
      age: (json['age'] as num?)?.toInt() ?? 25,
      sex: Sex.values.asNameMap()[json['sex']] ?? Sex.male,
      activityLevel: ActivityLevel.values.asNameMap()[json['activityLevel']] ??
          ActivityLevel.moderate,
      goal: FitnessGoal.values.asNameMap()[json['goal']] ??
          FitnessGoal.buildMuscle,
    );
  }
}
