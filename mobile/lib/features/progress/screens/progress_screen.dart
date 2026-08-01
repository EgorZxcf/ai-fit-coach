// mobile/lib/features/progress/screens/progress_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/snackbar_helper.dart';
import '../../../services/api_client.dart';
import '../models/progress_entry.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<ProgressEntry> _entries = [];
  bool _isLoadingEntries = true;

  final _weightController = TextEditingController();
  bool _workoutDone = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final stored = await ProgressStorage.load();
    if (!mounted) return;
    setState(() {
      // Если локально пока пусто (первый запуск) — подставляем демо-данные,
      // чтобы график не выглядел пустым для нового пользователя.
      _entries = stored.isNotEmpty ? stored : _demoEntries();
      _isLoadingEntries = false;
    });
    if (stored.isEmpty) {
      await ProgressStorage.saveAll(_entries);
    }
  }

  List<ProgressEntry> _demoEntries() => [
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 10)), weightKg: 81.0, workoutCompleted: true),
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 8)), weightKg: 80.5, workoutCompleted: true),
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 6)), weightKg: 80.2, workoutCompleted: false),
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 4)), weightKg: 80.0, workoutCompleted: true),
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 2)), weightKg: 79.5, workoutCompleted: true),
        ProgressEntry(date: DateTime.now().subtract(const Duration(days: 1)), weightKg: 79.2, workoutCompleted: false),
      ];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addEntry() async {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    setState(() => _isSaving = true);

    final newEntry = ProgressEntry(
      date: DateTime.now(),
      weightKg: weight,
      workoutCompleted: _workoutDone,
    );

    // Локальная копия — источник правды всегда, независимо от бэкенда.
    final updated = [..._entries, newEntry];
    await ProgressStorage.saveAll(updated);

    // Бэкенд вызывается best-effort: если недоступен, ничего не теряем.
    final result = await ApiClient.instance.logProgress(
      date: DateTime.now().toIso8601String().split('T').first,
      weightKg: weight ?? 0,
      workoutCompleted: _workoutDone,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _entries = updated;
      _weightController.clear();
      _workoutDone = true;
    });

    switch (result) {
      case ApiSuccess():
        if (mounted) Navigator.pop(context);
        if (mounted) SnackbarHelper.showSuccess(context, 'Запись сохранена');
      case ApiError():
        if (mounted) Navigator.pop(context);
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Запись за сегодня',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Вес (кг)',
                  hintText: '79.5',
                  suffixText: 'кг',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Тренировка выполнена',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  value: _workoutDone,
                  onChanged: (val) => setS(() => _workoutDone = val),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : FilledButton(onPressed: _addEntry, child: const Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    return '${d.day}.${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingEntries) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final completed = _entries.where((e) => e.workoutCompleted).length;
    final weights = _entries.where((e) => e.weightKg != null).toList();
    final weightValues = weights.map((e) => e.weightKg!).toList();
    final weightDelta = weightValues.length >= 2
        ? weightValues.last - weightValues.first
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Добавить', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.warning,
                  label: 'Тренировок',
                  value: '$completed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: AppColors.primary,
                  label: 'Изменение',
                  value: weightDelta != null
                      ? '${weightDelta > 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} кг'
                      : '—',
                  valueColor: weightDelta == null
                      ? null
                      : weightDelta <= 0
                          ? AppColors.primary
                          : AppColors.danger,
                ),
              ),
            ],
          ),
          if (weightValues.length >= 2) ...[
            const SizedBox(height: 16),
            _WeightChart(entries: weights, weightValues: weightValues),
          ],
          const SizedBox(height: 24),
          const Text(
            'История',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._entries.reversed.map<Widget>(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: e.workoutCompleted
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: e.workoutCompleted
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      e.workoutCompleted ? Icons.check : Icons.close,
                      color: e.workoutCompleted
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(e.date),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          e.workoutCompleted
                              ? 'Тренировка выполнена'
                              : 'Тренировка пропущена',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (e.weightKg != null)
                    Text(
                      '${e.weightKg!.toStringAsFixed(1)} кг',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<ProgressEntry> entries;
  final List<double> weightValues;

  const _WeightChart({required this.entries, required this.weightValues});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.show_chart, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'График веса',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '${weightValues.first.toStringAsFixed(1)} → ${weightValues.last.toStringAsFixed(1)} кг',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _WeightChartPainter(weights: weightValues),
              size: const Size(double.infinity, 120),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: entries
                .map((e) => Text(
                      '${e.date.day}.${e.date.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> weights;

  const _WeightChartPainter({required this.weights});

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;

    final minW = weights.reduce(math.min);
    final maxW = weights.reduce(math.max);
    final range = (maxW - minW).abs() < 0.1 ? 1.0 : maxW - minW;
    final padding = range * 0.3;

    double x(int i) => i / (weights.length - 1) * size.width;
    double y(double w) =>
        size.height - ((w - minW + padding) / (range + padding * 2)) * size.height;

    final points = List.generate(
      weights.length,
      (i) => Offset(x(i), y(weights[i])),
    );

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath..lineTo(points.last.dx, size.height)..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = AppColors.primary);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.weights != weights;
}