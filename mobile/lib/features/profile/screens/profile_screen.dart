// mobile/lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/snackbar_helper.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  String? _gender;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ProfileStorage.load();
    if (!mounted) return;
    setState(() {
      _ageController.text = profile.age?.toString() ?? '';
      _heightController.text = profile.heightCm?.toStringAsFixed(0) ?? '';
      _weightController.text = profile.currentWeightKg?.toStringAsFixed(1) ?? '';
      _targetWeightController.text =
          profile.targetWeightKg?.toStringAsFixed(1) ?? '';
      _gender = profile.gender;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final age = int.tryParse(_ageController.text.trim());
    final height = _parse(_heightController.text);
    final weight = _parse(_weightController.text);
    final targetWeight = _parse(_targetWeightController.text);

    setState(() => _isSaving = true);

    await ProfileStorage.save(UserProfile(
      age: age,
      heightCm: height,
      currentWeightKg: weight,
      targetWeightKg: targetWeight,
      gender: _gender,
    ));

    if (!mounted) return;
    setState(() => _isSaving = false);
    SnackbarHelper.showSuccess(context, 'Профиль сохранён');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('ПОЛ'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderChip(
                    label: 'Мужской',
                    icon: Icons.male,
                    selected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderChip(
                    label: 'Женский',
                    icon: Icons.female,
                    selected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _SectionLabel('ПАРАМЕТРЫ'),
            const SizedBox(height: 8),
            _ProfileField(
              controller: _ageController,
              label: 'Возраст',
              suffix: 'лет',
              icon: Icons.cake_outlined,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              controller: _heightController,
              label: 'Рост',
              suffix: 'см',
              icon: Icons.height,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              controller: _weightController,
              label: 'Текущий вес',
              suffix: 'кг',
              icon: Icons.monitor_weight_outlined,
              allowDecimal: true,
            ),
            const SizedBox(height: 12),
            _ProfileField(
              controller: _targetWeightController,
              label: 'Целевой вес',
              suffix: 'кг',
              icon: Icons.flag_outlined,
              allowDecimal: true,
            ),

            if (_bmiPreview != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ИМТ: ${_bmiPreview!.toStringAsFixed(1)} — используется для персонализации плана и советов ИИ-тренера',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? get _bmiPreview {
    final h = _parse(_heightController.text);
    final w = _parse(_weightController.text);
    if (h == null || w == null || h == 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      );
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final bool allowDecimal;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                suffixText: suffix,
                suffixStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
