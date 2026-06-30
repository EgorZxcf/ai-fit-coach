// mobile/lib/core/widgets/rest_timer.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Виджет таймера отдыха между подходами.
/// Показывается как bottom sheet после отметки упражнения выполненным.
/// Вибрирует и закрывается автоматически когда время вышло.
class RestTimerSheet extends StatefulWidget {
  final int seconds;
  final VoidCallback? onFinished;

  const RestTimerSheet({
    super.key,
    this.seconds = 90,
    this.onFinished,
  });

  /// Показать таймер отдыха поверх текущего экрана.
  static Future<void> show(
    BuildContext context, {
    int seconds = 90,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RestTimerSheet(seconds: seconds),
    );
  }

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  late int _total;
  Timer? _timer;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _total = widget.seconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);

      // Вибрация на последних 3 секундах
      if (_remaining <= 3 && _remaining > 0) {
        HapticFeedback.mediumImpact();
        _pulseController.forward().then((_) => _pulseController.reverse());
      }

      if (_remaining <= 0) {
        _onFinished();
      }
    });
  }

  void _onFinished() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() => _finished = true);
    widget.onFinished?.call();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _addTime(int seconds) {
    setState(() => _remaining += seconds);
  }

  void _skipRest() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0
        ? '$m:${s.toString().padLeft(2, '0')}'
        : '${s}с';
  }

  Color get _timerColor {
    if (_finished) return AppColors.primary;
    if (_remaining <= 10) return AppColors.danger;
    if (_remaining <= 30) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? _remaining / _total : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _timerColor.withOpacity(0.3), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ручка
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: _timerColor, size: 18),
              const SizedBox(width: 8),
              Text(
                _finished ? 'Время!' : 'Отдых',
                style: TextStyle(
                  color: _timerColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Круговой прогресс с таймером
          ScaleTransition(
            scale: _pulseAnimation,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Фоновый круг
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: AppColors.surfaceCard,
                    ),
                  ),
                  // Прогресс
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 6,
                      color: _timerColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Время
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _finished ? '✓' : _formatTime(_remaining),
                        style: TextStyle(
                          color: _timerColor,
                          fontSize: _finished ? 48 : 40,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      if (!_finished)
                        const Text(
                          'осталось',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Кнопки +30с и +60с
          if (!_finished)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeButton(
                  label: '+30с',
                  onTap: () => _addTime(30),
                ),
                const SizedBox(width: 12),
                _TimeButton(
                  label: '+60с',
                  onTap: () => _addTime(60),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Кнопка пропустить
          if (!_finished)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _skipRest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Пропустить отдых',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
