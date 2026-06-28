// mobile/lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/fade_route.dart';
import '../../../core/widgets/vexor_logo.dart';
import '../../../services/api_client.dart';
import '../../../services/notification_service.dart';
import '../../auth/screens/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt('reminder_hour') ?? 9,
        minute: prefs.getInt('reminder_minute') ?? 0,
      );
    });
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    if (val) {
      await NotificationService.requestPermission();
      await NotificationService.scheduleDaily(
        _reminderTime.hour,
        _reminderTime.minute,
      );
    } else {
      await NotificationService.cancel();
    }
    await prefs.setBool('notifications_enabled', val);
    if (!mounted) return;
    setState(() => _notificationsEnabled = val);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimary,
            surface: AppColors.surfaceCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', picked.hour);
    await prefs.setInt('reminder_minute', picked.minute);
    setState(() => _reminderTime = picked);
    if (_notificationsEnabled) {
      await NotificationService.scheduleDaily(picked.hour, picked.minute);
    }
  }

  Future<void> _logout() async {
    await ApiClient.instance.clearToken();
    await NotificationService.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    if (!mounted) return;
    Navigator.pushReplacement(context, FadeRoute(page: const AuthScreen()));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const VexorLogo(size: 52),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vexor',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Бесплатный план',
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
          const SizedBox(height: 20),

          // Уведомления
          const Text(
            'УВЕДОМЛЕНИЯ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Напоминание о тренировке',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Ежедневное уведомление',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  secondary: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                if (_notificationsEnabled) ...[
                  Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                  ),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Время напоминания',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _formatTime(_reminderTime),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Аккаунт
          const Text(
            'АККАУНТ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Подписка Premium',
            color: AppColors.warning,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Выйти',
            color: AppColors.danger,
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
