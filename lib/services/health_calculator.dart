import '../models/user_profile.dart';

class HealthMetrics {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double proteinMinG;
  final double proteinMaxG;
  final double waterLiters;
  final double healthyWeightMinKg;
  final double healthyWeightMaxKg;

  const HealthMetrics({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.proteinMinG,
    required this.proteinMaxG,
    required this.waterLiters,
    required this.healthyWeightMinKg,
    required this.healthyWeightMaxKg,
  });
}

/// Standard, widely accepted formulas:
/// - BMI and its WHO categories
/// - BMR via Mifflin-St Jeor (most accurate common equation)
/// - TDEE via activity multipliers
/// - Protein 1.6-2.2 g/kg/day (sports nutrition consensus for muscle growth)
/// - Water ~35 ml/kg/day
class HealthCalculator {
  HealthCalculator._();

  static HealthMetrics compute(UserProfile p) {
    final heightM = p.heightCm / 100;
    final bmi = p.weightKg / (heightM * heightM);

    final bmr = p.sex == Sex.male
        ? 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + 5
        : 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age - 161;

    final tdee = bmr * p.activityLevel.multiplier;

    double target;
    switch (p.goal) {
      case FitnessGoal.loseFat:
        target = tdee - 500; // ~0.5 kg/week deficit
        break;
      case FitnessGoal.maintain:
        target = tdee;
        break;
      case FitnessGoal.buildMuscle:
        target = tdee + 300; // lean bulk surplus
        break;
    }

    return HealthMetrics(
      bmi: bmi,
      bmiCategory: bmiCategory(bmi),
      bmr: bmr,
      tdee: tdee,
      targetCalories: target,
      proteinMinG: 1.6 * p.weightKg,
      proteinMaxG: 2.2 * p.weightKg,
      waterLiters: 0.035 * p.weightKg,
      healthyWeightMinKg: 18.5 * heightM * heightM,
      healthyWeightMaxKg: 24.9 * heightM * heightM,
    );
  }

  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }
}
