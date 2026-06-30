// mobile/lib/features/progress/widgets/achievements_grid.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/achievement.dart';

/// Сетка достижений с визуальным разделением на разблокированные/заблокированные.
class AchievementsGrid extends StatelessWidget {
  final AchievementContext context_;

  const AchievementsGrid({super.key, required this.context_});

  void _showDetails(BuildContext context, Achievement achievement, bool unlocked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (unlocked ? achievement.color : AppColors.textSecondary)
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: unlocked ? achievement.color : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            if (!unlocked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🔒 Не разблокировано',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementCatalog.all;
    final unlockedCount =
        achievements.where((a) => a.isUnlocked(context_)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Достижения',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$unlockedCount/${achievements.length}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (ctx, i) {
            final achievement = achievements[i];
            final unlocked = achievement.isUnlocked(context_);

            return GestureDetector(
              onTap: () => _showDetails(ctx, achievement, unlocked),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: unlocked
                        ? achievement.color.withOpacity(0.4)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? achievement.color.withOpacity(0.15)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        unlocked ? achievement.icon : Icons.lock_outline,
                        color: unlocked
                            ? achievement.color
                            : AppColors.textSecondary.withOpacity(0.5),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        achievement.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
