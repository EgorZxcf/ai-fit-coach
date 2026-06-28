// mobile/lib/features/plan/screens/plan_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../models/exercise.dart';
import '../models/workout_day.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedDay = 0;
  bool _isLoading = true;

  final List<WorkoutDay> _plan = [
    WorkoutDay(day: 'Пн', label: 'Понедельник', type: 'Грудь и трицепс', exercises: [
      Exercise(name: 'Отжимания', sets: '4 × 15', muscles: 'Грудь', icon: Icons.sports_gymnastics),
      Exercise(name: 'Жим гантелей лёжа', sets: '3 × 12', muscles: 'Грудь, трицепс', icon: Icons.fitness_center),
      Exercise(name: 'Разводка гантелей', sets: '3 × 12', muscles: 'Грудь', icon: Icons.fitness_center),
      Exercise(name: 'Французский жим', sets: '3 × 12', muscles: 'Трицепс', icon: Icons.fitness_center),
      Exercise(name: 'Отжимания на брусьях', sets: '3 × 10', muscles: 'Трицепс, грудь', icon: Icons.sports_gymnastics),
    ]),
    WorkoutDay(day: 'Вт', label: 'Вторник', type: 'Спина и бицепс', exercises: [
      Exercise(name: 'Подтягивания', sets: '4 × 8', muscles: 'Спина, бицепс', icon: Icons.sports_gymnastics),
      Exercise(name: 'Тяга гантели в наклоне', sets: '3 × 12', muscles: 'Спина', icon: Icons.fitness_center),
      Exercise(name: 'Гиперэкстензия', sets: '3 × 15', muscles: 'Поясница', icon: Icons.sports_gymnastics),
      Exercise(name: 'Сгибания на бицепс', sets: '3 × 12', muscles: 'Бицепс', icon: Icons.fitness_center),
      Exercise(name: 'Молоток', sets: '3 × 12', muscles: 'Бицепс, предплечье', icon: Icons.fitness_center),
    ]),
    WorkoutDay(day: 'Ср', label: 'Среда', type: '🧘 Отдых', exercises: []),
    WorkoutDay(day: 'Чт', label: 'Четверг', type: 'Ноги', exercises: [
      Exercise(name: 'Приседания', sets: '4 × 15', muscles: 'Квадрицепс, ягодицы', icon: Icons.sports_gymnastics),
      Exercise(name: 'Выпады', sets: '3 × 12', muscles: 'Квадрицепс', icon: Icons.sports_gymnastics),
      Exercise(name: 'Румынская тяга', sets: '3 × 12', muscles: 'Бицепс бедра', icon: Icons.fitness_center),
      Exercise(name: 'Подъём на носки', sets: '4 × 20', muscles: 'Икры', icon: Icons.sports_gymnastics),
      Exercise(name: 'Ягодичный мостик', sets: '3 × 15', muscles: 'Ягодицы', icon: Icons.sports_gymnastics),
    ]),
    WorkoutDay(day: 'Пт', label: 'Пятница', type: 'Плечи и пресс', exercises: [
      Exercise(name: 'Жим гантелей сидя', sets: '4 × 12', muscles: 'Плечи', icon: Icons.fitness_center),
      Exercise(name: 'Разводка в стороны', sets: '3 × 15', muscles: 'Средняя дельта', icon: Icons.fitness_center),
      Exercise(name: 'Протяжка', sets: '3 × 12', muscles: 'Плечи, трапеция', icon: Icons.fitness_center),
      Exercise(name: 'Скручивания', sets: '4 × 20', muscles: 'Пресс', icon: Icons.sports_gymnastics),
      Exercise(name: 'Планка', sets: '3 × 45 сек', muscles: 'Пресс, кор', icon: Icons.sports_gymnastics),
    ]),
    WorkoutDay(day: 'Сб', label: 'Суббота', type: 'Кардио', exercises: [
      Exercise(name: 'Бег трусцой', sets: '30 мин', muscles: 'Кардио', icon: Icons.directions_run),
      Exercise(name: 'Прыжки со скакалкой', sets: '5 × 2 мин', muscles: 'Кардио', icon: Icons.sports_gymnastics),
      Exercise(name: 'Берпи', sets: '4 × 10', muscles: 'Всё тело', icon: Icons.sports_gymnastics),
    ]),
    WorkoutDay(day: 'Вс', label: 'Воскресенье', type: '🧘 Отдых', exercises: []),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonBox(width: double.infinity, height: 100, radius: 16),
        const SizedBox(height: 16),
        ...List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SkeletonBox(width: double.infinity, height: 70, radius: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 72,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _plan.length,
        itemBuilder: (context, i) {
          final d = _plan[i];
          final selected = _selectedDay == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d.day,
                    style: TextStyle(
                      color: selected ? Colors.black : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.black.withOpacity(0.4)
                          : d.exercises.isNotEmpty
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestDay(WorkoutDay day) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😴', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text(
            'День отдыха',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.label} — восстановление',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    return GestureDetector(
      onTap: () => setState(() => ex.done = !ex.done),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ex.done
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ex.done
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ex.done ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                ex.done ? Icons.check : ex.icon,
                color: ex.done ? Colors.black : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: TextStyle(
                      color: ex.done ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: ex.done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ex.muscles,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ex.sets,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _plan[_selectedDay];

    return Scaffold(
      appBar: AppBar(
        title: const Text('План'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Text(
              'Моковый план',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: _isLoading
                ? _buildSkeleton()
                : today.isRestDay
                    ? _buildRestDay(today)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.surfaceCard,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        today.label,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        today.type,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${today.exercises.length} упражнений',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: CircularProgressIndicator(
                                        value: today.progress,
                                        backgroundColor: AppColors.surface,
                                        color: AppColors.primary,
                                        strokeWidth: 4,
                                      ),
                                    ),
                                    Text(
                                      '${today.completedCount}/${today.exercises.length}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...today.exercises.map<Widget>(_buildExerciseCard),
                          const SizedBox(height: 80),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
