/// A dated body-weight measurement, used for the progress chart.
class WeightEntry {
  final DateTime date;
  final double weightKg;

  const WeightEntry({required this.date, required this.weightKg});

  /// Calendar-day key so one entry per day replaces older same-day entries.
  String get dayKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
