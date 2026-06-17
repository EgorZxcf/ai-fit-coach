// Путь в репозитории: mobile/lib/main.dart
// Заменить стандартный файл, который создаст `flutter create`, этим содержимым.

import 'package:flutter/material.dart';

void main() {
  runApp(const AiFitCoachApp());
}

class AiFitCoachApp extends StatelessWidget {
  const AiFitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fit Coach',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final _screens = const [
    PlanScreen(),
    ChatScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'План'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Чат'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Прогресс'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('План тренировок')),
      body: const Center(child: Text('TODO: подключить GET /plans/current')),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI-тренер')),
      body: const Center(child: Text('TODO: подключить POST /chat/message')),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: const Center(child: Text('TODO: подключить GET /progress')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: const Center(child: Text('Подписка, профиль, выход')),
    );
  }
}
