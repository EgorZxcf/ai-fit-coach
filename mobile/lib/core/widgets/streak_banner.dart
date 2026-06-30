// mobile/lib/core/widgets/streak_banner.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Баннер стрика — показывает текущую серию дней с тренировками.
/// Меняет визуал в зависимости от длины серии (мотивационная градация).
class StreakBanner extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakBanner({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  ({Color color, String emoji, String message}) get _tier {
    if (currentStreak == 0) {
      return (
        color: AppColors.textSecondary,
        emoji: '💤',
        message: 'Начни серию сегодня!',
      );
    }
    if (currentStreak < 3) {
      return (
        color: AppColors.primary,
        emoji: '🔥',
        message: 'Хорошее начало!',
      );
    }
    if (currentStreak < 7) {
      return (
        color: AppColors.warning,
        emoji: '🔥',
        message: 'Набираешь обороты!',
      );
    }
    if (currentStreak < 30) {
      return (
        color: const Color(0xFFFF6B6B),
        emoji: '🔥',
        message: 'Невероятная серия!',
      );
    }
    return (
      color: const Color(0xFFFFD700),
      emoji: '👑',
      message: 'Ты легенда!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tier.color.withOpacity(0.18), AppColors.surfaceCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tier.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tier.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(tier.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currentStreak',
                      style: TextStyle(
                        color: tier.color,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentStreak == 1 ? 'день подряд' : 'дней подряд',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tier.message,
                  style: TextStyle(
                    color: tier.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (longestStreak > currentStreak)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$longestStreak',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'рекорд',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
