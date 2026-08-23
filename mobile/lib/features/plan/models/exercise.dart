// mobile/lib/features/plan/models/exercise.dart

import 'package:flutter/material.dart';

/// Модель упражнения в плане тренировок.
final class Exercise {
  final String name;
  final String sets;
  final String muscles;
  final IconData icon;
  bool done;

  Exercise({
    required this.name,
    required this.sets,
    required this.muscles,
    required this.icon,
    this.done = false,
  });

  /// Парсинг из ответа бэкенда: `{ "name": "Squats", "sets": 3, "reps": 12 }`.
  /// Бэкенд не отдаёт мышечную группу и иконку — используем дефолты.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final sets = json['sets'];
    final reps = json['reps'];
    final setsLabel = (sets != null && reps != null)
        ? '$sets × $reps'
        : (json['sets_label']?.toString() ?? '');
    return Exercise(
      name: json['name']?.toString() ?? '',
      sets: setsLabel,
      muscles: json['muscles']?.toString() ?? '',
      icon: Icons.fitness_center,
    );
  }
}
