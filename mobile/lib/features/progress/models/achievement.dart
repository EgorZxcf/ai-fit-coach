// mobile/lib/features/progress/models/achievement.dart

import 'package:flutter/material.dart';

/// Модель достижения. Разблокируется на основе прогресса пользователя.
final class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(AchievementContext ctx) condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.condition,
  });

  bool isUnlocked(AchievementContext ctx) => condition(ctx);
}

/// Контекст данных для проверки условий достижений.
final class AchievementContext {
  final int totalWorkouts;
  final int currentStreak;
  final int longestStreak;
  final double? totalWeightLostKg;

  const AchievementContext({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.longestStreak,
    this.totalWeightLostKg,
  });
}

/// Реестр всех доступных достижений в приложении.
abstract final class AchievementCatalog {
  static final List<Achievement> all = [
    Achievement(
      id: 'first_workout',
      title: 'Первый шаг',
      description: 'Заверши первую тренировку',
      icon: Icons.flag,
      color: const Color(0xFF00C896),
      condition: (ctx) => ctx.totalWorkouts >= 1,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Разгон',
      description: '3 дня подряд с тренировками',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFFB347),
      condition: (ctx) => ctx.longestStreak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Неделя силы',
      description: '7 дней подряд с тренировками',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF6B6B),
      condition: (ctx) => ctx.longestStreak >= 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Железная воля',
      description: '30 дней подряд с тренировками',
      icon: Icons.whatshot,
      color: const Color(0xFFFF3B3B),
      condition: (ctx) => ctx.longestStreak >= 30,
    ),
    Achievement(
      id: 'workouts_10',
      title: 'В ритме',
      description: '10 тренировок выполнено',
      icon: Icons.fitness_center,
      color: const Color(0xFF00C896),
      condition: (ctx) => ctx.totalWorkouts >= 10,
    ),
    Achievement(
      id: 'workouts_50',
      title: 'Ветеран',
      description: '50 тренировок выполнено',
      icon: Icons.military_tech,
      color: const Color(0xFFFFD700),
      condition: (ctx) => ctx.totalWorkouts >= 50,
    ),
    Achievement(
      id: 'workouts_100',
      title: 'Легенда',
      description: '100 тренировок выполнено',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFD700),
      condition: (ctx) => ctx.totalWorkouts >= 100,
    ),
    Achievement(
      id: 'weight_loss_1',
      title: 'Первый результат',
      description: 'Сбросил первый килограмм',
      icon: Icons.trending_down,
      color: const Color(0xFF00C896),
      condition: (ctx) => (ctx.totalWeightLostKg ?? 0) >= 1,
    ),
    Achievement(
      id: 'weight_loss_5',
      title: 'Прогресс заметен',
      description: 'Сбросил 5 кг',
      icon: Icons.trending_down,
      color: const Color(0xFF00C896),
      condition: (ctx) => (ctx.totalWeightLostKg ?? 0) >= 5,
    ),
  ];
}
