// mobile/lib/features/progress/services/streak_calculator.dart

import '../models/progress_entry.dart';

/// Чистая функция расчёта стрика — без side effects, легко тестируется.
/// Стрик = количество дней подряд (включая сегодня или вчера) с выполненной тренировкой.
abstract final class StreakCalculator {
  static int currentStreak(List<ProgressEntry> entries) {
    if (entries.isEmpty) return 0;

    final completedDates = entries
        .where((e) => e.workoutCompleted)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    if (completedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Стрик считается живым, если есть тренировка сегодня или вчера
    DateTime cursor;
    if (completedDates.contains(todayDate)) {
      cursor = todayDate;
    } else if (completedDates.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (completedDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int longestStreak(List<ProgressEntry> entries) {
    if (entries.isEmpty) return 0;

    final completedDates = entries
        .where((e) => e.workoutCompleted)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toList()
      ..sort();

    if (completedDates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < completedDates.length; i++) {
      final diff = completedDates[i].difference(completedDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else if (diff > 1) {
        current = 1;
      }
    }

    return longest;
  }

  static double? totalWeightLost(List<ProgressEntry> entries) {
    final weighted = entries.where((e) => e.weightKg != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weighted.length < 2) return null;

    final first = weighted.first.weightKg!;
    final last = weighted.last.weightKg!;
    final delta = first - last;

    return delta > 0 ? delta : null;
  }
}
