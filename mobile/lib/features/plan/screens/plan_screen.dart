// mobile/lib/features/plan/screens/plan_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/rest_timer.dart';
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
  int _restSeconds = 90;

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

  void _onExerciseTap(Exercise ex) {
    final wasCompleted = ex.done;
    setState(() => ex.done = !ex.done);
    if (!wasCompleted && mounted) {
      RestTimerSheet.show(context, seconds: _restSeconds);
    }
  }

  void _showRestSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Время отдыха',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [30, 60, 90, 120, 180].map((s) {
            final selected = _restSeconds == s;
            return GestureDetector(
              onTap: () { setState(() => _restSeconds = s); Navigator.pop(ctx); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      s >= 60 ? '${s ~/ 60} мин${s % 60 != 0 ? ' ${s % 60} сек' : ''}' : '$s сек',
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (selected) const Icon(Icons.check, color: AppColors.primary, size: 18),
                    if (s == 90)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('рекомендуем',
                            style: TextStyle(color: AppColors.primary, fontSize: 10)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkeleton() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const SkeletonBox(width: double.infinity, height: 100, radius: 16),
      const SizedBox(height: 16),
      ...List.generate(4, (_) => const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: SkeletonBox(width: double.infinity, height: 70, radius: 14),
      )),
    ],
  );

  Widget _buildDaySelector() => Container(
    height: 72,
    color: AppColors.background,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _plan.length,
      itemBuilder: (_, i) {
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
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(d.day, style: TextStyle(
                  color: selected ? Colors.black : AppColors.textPrimary,
                  fontWeight: FontWeight.w700, fontSize: 14,
                )),
                const SizedBox(height: 4),
                Container(
                  width: 6, height: 6,
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

  Widget _buildWorkoutComplete(WorkoutDay day) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.05)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
    ),
    child: Column(
      children: [
        const Text('🎉', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        const Text('Тренировка завершена!',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('${day.type} — все упражнения выполнены',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Отличная работа 💪',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    ),
  );

  Widget _buildExerciseCard(Exercise ex) => GestureDetector(
    onTap: () => _onExerciseTap(ex),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ex.done ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ex.done ? AppColors.primary.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ex.done ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ex.done ? Icons.check : ex.icon,
              color: ex.done ? Colors.black : AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name, style: TextStyle(
                  color: ex.done ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600, fontSize: 14,
                  decoration: ex.done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.primary,
                )),
                const SizedBox(height: 2),
                Text(ex.muscles, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
            child: Text(ex.sets, style: const TextStyle(
              color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final today = _plan[_selectedDay];
    final allDone = today.exercises.isNotEmpty &&
        today.exercises.every((e) => e.done);

    return Scaffold(
      appBar: AppBar(
        title: const Text('План'),
        actions: [
          GestureDetector(
            onTap: _showRestSettings,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _restSeconds >= 60
                        ? '${_restSeconds ~/ 60}м${_restSeconds % 60 != 0 ? '${_restSeconds % 60}с' : ''}'
                        : '${_restSeconds}с',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Text('Моковый план',
              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('😴', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 20),
                            const Text('День отдыха', style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('${today.label} — восстановление',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                '💡 Отдых так же важен как тренировка. Мышцы растут во время восстановления.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Заголовок тренировки
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary.withOpacity(0.15), AppColors.surfaceCard],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(today.label, style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(today.type, style: const TextStyle(
                                        color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 8),
                                      Text('${today.exercises.length} упражнений · отдых ${_restSeconds}с',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 52, height: 52,
                                      child: CircularProgressIndicator(
                                        value: today.progress,
                                        backgroundColor: AppColors.surface,
                                        color: allDone ? AppColors.primary : AppColors.primary,
                                        strokeWidth: 4,
                                      ),
                                    ),
                                    allDone
                                        ? const Icon(Icons.check, color: AppColors.primary, size: 22)
                                        : Text('${today.completedCount}/${today.exercises.length}',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Упражнения
                          ...today.exercises.map<Widget>(_buildExerciseCard),

                          // Карточка завершения тренировки
                          if (allDone) ...[
                            const SizedBox(height: 8),
                            _buildWorkoutComplete(today),
                          ],

                          const SizedBox(height: 80),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
