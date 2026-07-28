/// A record of a completed (or skipped) workout session.
class SessionLog {
  final String id;
  final DateTime date;
  final String dayLabel;
  final List<String> muscleNames;
  final int exercisesCompleted;
  final int durationMinutes;
  final String note;

  const SessionLog({
    required this.id,
    required this.date,
    this.dayLabel = '',
    this.muscleNames = const [],
    this.exercisesCompleted = 0,
    this.durationMinutes = 0,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'dayLabel': dayLabel,
        'muscleNames': muscleNames,
        'exercisesCompleted': exercisesCompleted,
        'durationMinutes': durationMinutes,
        'note': note,
      };

  factory SessionLog.fromJson(Map<String, dynamic> json) {
    return SessionLog(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      dayLabel: json['dayLabel'] as String? ?? '',
      muscleNames:
          ((json['muscleNames'] as List?) ?? []).map((e) => '$e').toList(),
      exercisesCompleted: (json['exercisesCompleted'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
    );
  }
}
