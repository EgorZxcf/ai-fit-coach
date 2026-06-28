// mobile/lib/features/progress/models/progress_entry.dart

/// Модель одной записи прогресса пользователя.
final class ProgressEntry {
  final DateTime date;
  final double? weightKg;
  final bool workoutCompleted;

  const ProgressEntry({
    required this.date,
    this.weightKg,
    required this.workoutCompleted,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        workoutCompleted: json['workout_completed'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        if (weightKg != null) 'weight_kg': weightKg,
        'workout_completed': workoutCompleted,
      };
}
