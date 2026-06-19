// Путь в репозитории: mobile/lib/main.dart
// Добавлен экран онбординга (стартовый экран) + IndexedStack, чтобы вкладки не сбрасывались.

import 'dart:async';
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
      home: const OnboardingScreen(),
    );
  }
}

// ---------- ОНБОРДИНГ ----------

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> _goals = const [
    {'value': 'weight_loss', 'label': 'Снижение веса'},
    {'value': 'muscle_gain', 'label': 'Набор массы'},
    {'value': 'endurance', 'label': 'Выносливость'},
  ];

  final List<Map<String, String>> _levels = const [
    {'value': 'beginner', 'label': 'Новичок'},
    {'value': 'intermediate', 'label': 'Средний'},
    {'value': 'advanced', 'label': 'Продвинутый'},
  ];

  final List<Map<String, String>> _equipmentOptions = const [
    {'value': 'dumbbells', 'label': 'Гантели'},
    {'value': 'barbell', 'label': 'Штанга'},
    {'value': 'resistance_bands', 'label': 'Резинки'},
    {'value': 'pull_up_bar', 'label': 'Турник'},
    {'value': 'none', 'label': 'Без оборудования'},
  ];

  String? _selectedGoal;
  String? _selectedLevel;
  final Set<String> _selectedEquipment = {};
  final TextEditingController _restrictionsController = TextEditingController();

  bool get _canContinue => _selectedGoal != null && _selectedLevel != null;

  void _submit() {
    final data = {
      'goal': _selectedGoal,
      'level': _selectedLevel,
      'equipment': _selectedEquipment.toList(),
      'restrictions': _restrictionsController.text.trim(),
    };

    // TODO: отправить data на POST /users/onboarding, когда бэкенд будет готов.
    debugPrint('Onboarding data: $data');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootScreen()),
    );
  }

  @override
  void dispose() {
    _restrictionsController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildChoiceChips({
    required List<Map<String, String>> options,
    required String? selectedValue,
    required void Function(String value) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.map((opt) {
        final isSelected = selectedValue == opt['value'];
        return ChoiceChip(
          label: Text(opt['label']!),
          selected: isSelected,
          onSelected: (_) => onSelected(opt['value']!),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расскажи о себе')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Это поможет AI-тренеру составить план именно под тебя.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            _buildSectionTitle('Цель'),
            _buildChoiceChips(
              options: _goals,
              selectedValue: _selectedGoal,
              onSelected: (v) => setState(() => _selectedGoal = v),
            ),
            _buildSectionTitle('Уровень подготовки'),
            _buildChoiceChips(
              options: _levels,
              selectedValue: _selectedLevel,
              onSelected: (v) => setState(() => _selectedLevel = v),
            ),
            _buildSectionTitle('Доступное оборудование'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _equipmentOptions.map((opt) {
                final isSelected = _selectedEquipment.contains(opt['value']);
                return FilterChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedEquipment.add(opt['value']!);
                      } else {
                        _selectedEquipment.remove(opt['value']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            _buildSectionTitle('Есть ограничения по здоровью? (необязательно)'),
            TextField(
              controller: _restrictionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Например: болит колено',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canContinue ? _submit : null,
                child: const Text('Продолжить'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------- ОСНОВНОЕ ПРИЛОЖЕНИЕ ----------

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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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

class ChatMessage {
  final String role; // 'user' или 'assistant'
  final String text;
  ChatMessage(this.role, this.text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      'assistant',
      'Привет! Я твой AI-тренер. Расскажи, как прошла тренировка, или задай вопрос.',
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  bool _isWaiting = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage('user', text));
      _isWaiting = true;
    });
    _controller.clear();

    // Заглушка вместо реального запроса к /chat/message.
    // Когда бэкенд готов — замени этот блок на:
    // final res = await apiClient.sendChatMessage(text);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          'assistant',
          'Это тестовый ответ. Скоро здесь будет настоящий AI-тренер.',
        ));
        _isWaiting = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI-тренер')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (_isWaiting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('тренер пишет...', style: TextStyle(color: Colors.grey)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Напиши тренеру...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
