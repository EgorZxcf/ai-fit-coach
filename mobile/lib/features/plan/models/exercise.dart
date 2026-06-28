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
}
