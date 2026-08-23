// mobile/lib/features/plan/models/workout_day.dart

import 'exercise.dart';

/// Модель одного дня тренировочного плана.
final class WorkoutDay {
  final String day;
  final String label;
  final String type;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.day,
    required this.label,
    required this.type,
    required this.exercises,
  });

  bool get isRestDay => exercises.isEmpty;
  int get completedCount => exercises.where((e) => e.done).length;
  double get progress =>
      exercises.isEmpty ? 0 : completedCount / exercises.length;

  /// Английское имя дня из API-контракта → (короткая, полная) метка на русском.
  static const Map<String, (String, String)> _dayNames = {
    'Monday': ('Пн', 'Понедельник'),
    'Tuesday': ('Вт', 'Вторник'),
    'Wednesday': ('Ср', 'Среда'),
    'Thursday': ('Чт', 'Четверг'),
    'Friday': ('Пт', 'Пятница'),
    'Saturday': ('Сб', 'Суббота'),
    'Sunday': ('Вс', 'Воскресенье'),
  };

  /// Парсинг из ответа `/plans/generate` и `/plans/current`:
  /// `{ "day": "Monday", "exercises": [...] }`.
  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day']?.toString() ?? '';
    final names = _dayNames[rawDay] ?? (rawDay, rawDay);
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    final exercises = exercisesJson
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    return WorkoutDay(
      day: names.$1,
      label: names.$2,
      type: exercises.isEmpty ? '🧘 Отдых' : 'Тренировка',
      exercises: exercises,
    );
  }

  /// Список дней из ответа `{ "plan_id": ..., "days": [...] }`.
  static List<WorkoutDay> listFromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as List<dynamic>? ?? [];
    return daysJson
        .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
