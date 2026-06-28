// mobile/lib/root_screen.dart

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/plan/screens/plan_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/progress/screens/progress_screen.dart';
import 'features/settings/screens/settings_screen.dart';

/// Корневой экран приложения с нижней навигацией.
/// IndexedStack сохраняет состояние всех вкладок при переключении.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  static const _screens = [
    PlanScreen(),
    ChatScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.fitness_center_outlined),
      selectedIcon: Icon(Icons.fitness_center),
      label: 'План',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Чат',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart),
      label: 'Прогресс',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Настройки',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _destinations,
      ),
    );
  }
}
