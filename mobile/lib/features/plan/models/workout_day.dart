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
}
