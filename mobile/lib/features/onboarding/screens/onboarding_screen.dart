// mobile/lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/fade_route.dart';
import '../../../core/widgets/vexor_logo.dart';
import '../../../root_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _goals = [
    {'value': 'weight_loss', 'label': 'Снижение веса', 'icon': '🔥'},
    {'value': 'muscle_gain', 'label': 'Набор массы', 'icon': '💪'},
    {'value': 'endurance', 'label': 'Выносливость', 'icon': '🏃'},
  ];

  static const _levels = [
    {'value': 'beginner', 'label': 'Новичок'},
    {'value': 'intermediate', 'label': 'Средний'},
    {'value': 'advanced', 'label': 'Продвинутый'},
  ];

  static const _equipmentOptions = [
    {'value': 'dumbbells', 'label': 'Гантели'},
    {'value': 'barbell', 'label': 'Штанга'},
    {'value': 'resistance_bands', 'label': 'Резинки'},
    {'value': 'pull_up_bar', 'label': 'Турник'},
    {'value': 'none', 'label': 'Без оборудования'},
  ];

  String? _selectedGoal;
  String? _selectedLevel;
  final Set<String> _selectedEquipment = {};
  final _restrictionsController = TextEditingController();
  bool _isSaving = false;

  bool get _canContinue => _selectedGoal != null && _selectedLevel != null;

  @override
  void dispose() {
    _restrictionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setString('goal', _selectedGoal!);
    await prefs.setString('level', _selectedLevel!);
    await prefs.setStringList('equipment', _selectedEquipment.toList());
    await prefs.setString('restrictions', _restrictionsController.text.trim());

    // TODO: отправить на POST /users/onboarding когда эндпоинт будет готов

    if (!mounted) return;
    Navigator.pushReplacement(context, FadeRoute(page: const RootScreen()));
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const VexorLogo(size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vexor',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Настроим план под тебя',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _section('Цель'),
              Column(
                children: _goals.map((g) {
                  final selected = _selectedGoal == g['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGoal = g['value']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            g['icon']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            g['label']!,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              _section('Уровень подготовки'),
              Row(
                children: List.generate(_levels.length, (i) {
                  final l = _levels[i];
                  final selected = _selectedLevel == l['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedLevel = l['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: i < _levels.length - 1 ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.12)
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          l['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              _section('Оборудование'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _equipmentOptions.map((opt) {
                  final sel = _selectedEquipment.contains(opt['value']);
                  return FilterChip(
                    label: Text(opt['label']!),
                    selected: sel,
                    onSelected: (val) => setState(() {
                      val
                          ? _selectedEquipment.add(opt['value']!)
                          : _selectedEquipment.remove(opt['value']!);
                    }),
                  );
                }).toList(),
              ),
              _section('Ограничения (необязательно)'),
              TextField(
                controller: _restrictionsController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Например: болит колено',
                ),
              ),
              const SizedBox(height: 28),
              _isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : FilledButton(
                      onPressed: _canContinue ? _submit : null,
                      child: const Text('Начать тренировки'),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
