// Путь в репозитории: mobile/lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AiFitCoachApp());
}

// ---------- ТЕМА ----------

class AppTheme {
  static const primary = Color(0xFF00C896);
  static const primaryDark = Color(0xFF00A87E);
  static const background = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D27);
  static const surfaceCard = Color(0xFF222535);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9DA3B4);
  static const danger = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFB347);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primary,
          surface: surface,
          onPrimary: Colors.black,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary, fontSize: 20,
            fontWeight: FontWeight.w700, letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primary,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: textSecondary, fontSize: 11),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black, size: 22);
            }
            return const IconThemeData(color: textSecondary, size: 22);
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceCard,
          hintStyle: const TextStyle(color: textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: surfaceCard, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceCard,
          selectedColor: primary,
          labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
          side: const BorderSide(color: Color(0xFF2E3247)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          checkmarkColor: Colors.black,
          showCheckmark: true,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primary : textSecondary),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primary.withOpacity(0.3) : surfaceCard),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
          bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        ),
      );
}

class AiFitCoachApp extends StatelessWidget {
  const AiFitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Fit Coach',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
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
  final _goals = const [
    {'value': 'weight_loss', 'label': 'Снижение веса', 'icon': '🔥'},
    {'value': 'muscle_gain', 'label': 'Набор массы', 'icon': '💪'},
    {'value': 'endurance', 'label': 'Выносливость', 'icon': '🏃'},
  ];
  final _levels = const [
    {'value': 'beginner', 'label': 'Новичок'},
    {'value': 'intermediate', 'label': 'Средний'},
    {'value': 'advanced', 'label': 'Продвинутый'},
  ];
  final _equipmentOptions = const [
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

  @override
  void dispose() {
    _restrictionsController.dispose();
    super.dispose();
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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
                    colors: [AppTheme.primary.withOpacity(0.15), Colors.transparent],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.fitness_center, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Fit Coach', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('Настроим план под тебя', style: Theme.of(context).textTheme.bodySmall),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppTheme.primary : const Color(0xFF2E3247),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(g['icon']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Text(g['label']!, style: TextStyle(
                            color: selected ? AppTheme.primary : AppTheme.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 15,
                          )),
                          const Spacer(),
                          if (selected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
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
                      onTap: () => setState(() => _selectedLevel = l['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: i < _levels.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppTheme.primary : const Color(0xFF2E3247),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(l['label']!, textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? AppTheme.primary : AppTheme.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          )),
                      ),
                    ),
                  );
                }),
              ),
              _section('Оборудование'),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _equipmentOptions.map((opt) {
                  final sel = _selectedEquipment.contains(opt['value']);
                  return FilterChip(
                    label: Text(opt['label']!),
                    selected: sel,
                    onSelected: (val) => setState(() {
                      val ? _selectedEquipment.add(opt['value']!) : _selectedEquipment.remove(opt['value']!);
                    }),
                  );
                }).toList(),
              ),
              _section('Ограничения (необязательно)'),
              TextField(
                controller: _restrictionsController,
                maxLines: 2,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Например: болит колено'),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _canContinue
                    ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootScreen()))
                    : null,
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

// ---------- ROOT ----------

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  final _screens = const [PlanScreen(), ChatScreen(), ProgressScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'План'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Чат'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Прогресс'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

// ---------- ПЛАН ----------

class Exercise {
  final String name;
  final String sets;
  final String muscles;
  final IconData icon;
  bool done;
  Exercise({required this.name, required this.sets, required this.muscles, required this.icon, this.done = false});
}

class WorkoutDay {
  final String day;
  final String label;
  final String type;
  final List<Exercise> exercises;
  WorkoutDay({required this.day, required this.label, required this.type, required this.exercises});
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedDay = 0;

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
  Widget build(BuildContext context) {
    final today = _plan[_selectedDay];
    final isRest = today.exercises.isEmpty;
    final doneCount = today.exercises.where((e) => e.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('План'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Text('Моковый план', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Выбор дня недели
          Container(
            height: 72,
            color: AppTheme.background,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _plan.length,
              itemBuilder: (context, i) {
                final d = _plan[i];
                final selected = _selectedDay == i;
                final hasExercises = d.exercises.isNotEmpty;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: 52,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppTheme.primary : const Color(0xFF2E3247),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d.day,
                          style: TextStyle(
                            color: selected ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.w700, fontSize: 14,
                          )),
                        const SizedBox(height: 4),
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Colors.black.withOpacity(0.4)
                                : hasExercises
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Контент дня
          Expanded(
            child: isRest
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('😴', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        const Text('День отдыха', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('${today.label} — восстановление', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
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
                            colors: [AppTheme.primary.withOpacity(0.15), AppTheme.surfaceCard],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(today.label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(today.type, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text('${today.exercises.length} упражнений', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            // Прогресс круг
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 52, height: 52,
                                  child: CircularProgressIndicator(
                                    value: today.exercises.isEmpty ? 0 : doneCount / today.exercises.length,
                                    backgroundColor: AppTheme.surface,
                                    color: AppTheme.primary,
                                    strokeWidth: 4,
                                  ),
                                ),
                                Text('$doneCount/${today.exercises.length}',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Список упражнений
                      ...today.exercises.map((ex) => GestureDetector(
                        onTap: () => setState(() => ex.done = !ex.done),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ex.done ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ex.done ? AppTheme.primary.withOpacity(0.4) : const Color(0xFF2E3247),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: ex.done ? AppTheme.primary : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  ex.done ? Icons.check : ex.icon,
                                  color: ex.done ? Colors.black : AppTheme.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.name, style: TextStyle(
                                      color: ex.done ? AppTheme.primary : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600, fontSize: 14,
                                      decoration: ex.done ? TextDecoration.lineThrough : null,
                                      decorationColor: AppTheme.primary,
                                    )),
                                    const SizedBox(height: 2),
                                    Text(ex.muscles, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(ex.sets, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------- ЧАТ ----------

class ChatMessage {
  final String role;
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
    ChatMessage('assistant', 'Привет! Я твой AI-тренер 💪\nРасскажи, как прошла тренировка, или задай вопрос.'),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isWaiting = false;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage('user', text));
      _isWaiting = true;
    });
    _controller.clear();
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage('assistant', 'Это тестовый ответ. Скоро здесь будет настоящий AI-тренер 🤖'));
        _isWaiting = false;
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI-тренер', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text(_isWaiting ? 'пишет...' : 'онлайн',
                  style: TextStyle(fontSize: 11, color: _isWaiting ? AppTheme.warning : AppTheme.primary)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primary, size: 16),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primary : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                          ),
                          child: Text(msg.text, style: TextStyle(
                            color: isUser ? Colors.black : AppTheme.textPrimary,
                            fontSize: 14, height: 1.4,
                          )),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 4),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(hintText: 'Напиши тренеру...'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                    ),
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

// ---------- ПРОГРЕСС ----------

class ProgressEntry {
  final DateTime date;
  final double? weightKg;
  final bool workoutCompleted;
  ProgressEntry({required this.date, this.weightKg, required this.workoutCompleted});
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<ProgressEntry> _entries = [
    ProgressEntry(date: DateTime.now().subtract(const Duration(days: 4)), weightKg: 80.0, workoutCompleted: true),
    ProgressEntry(date: DateTime.now().subtract(const Duration(days: 2)), weightKg: 79.5, workoutCompleted: true),
    ProgressEntry(date: DateTime.now().subtract(const Duration(days: 1)), weightKg: 79.2, workoutCompleted: false),
  ];

  final TextEditingController _weightController = TextEditingController();
  bool _workoutDone = true;

  void _addEntry() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    setState(() {
      _entries.add(ProgressEntry(date: DateTime.now(), weightKg: weight, workoutCompleted: _workoutDone));
      _weightController.clear();
      _workoutDone = true;
    });
    Navigator.pop(context);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Запись за сегодня', style: TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Вес (кг)', hintText: '79.5', suffixText: 'кг',
                  labelStyle: TextStyle(color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('Тренировка выполнена', style: TextStyle(color: AppTheme.textPrimary)),
                  value: _workoutDone,
                  onChanged: (val) => setS(() => _workoutDone = val),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _addEntry, child: const Text('Сохранить')),
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
    return '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _entries.where((e) => e.workoutCompleted).length;
    final weights = _entries.where((e) => e.weightKg != null).map((e) => e.weightKg!).toList();
    final weightDelta = weights.length >= 2 ? weights.last - weights.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Добавить', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.local_fire_department, iconColor: AppTheme.warning, label: 'Тренировок', value: '$completed')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.monitor_weight_outlined, iconColor: AppTheme.primary,
                label: 'Изменение веса',
                value: weightDelta != null ? '${weightDelta > 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} кг' : '—',
                valueColor: weightDelta == null ? null : weightDelta <= 0 ? AppTheme.primary : AppTheme.danger,
              )),
            ],
          ),
          const SizedBox(height: 24),
          const Text('История', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._entries.reversed.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: e.workoutCompleted ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: e.workoutCompleted ? AppTheme.primary.withOpacity(0.15) : AppTheme.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.workoutCompleted ? Icons.check : Icons.close,
                    color: e.workoutCompleted ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(e.date), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(e.workoutCompleted ? 'Тренировка выполнена' : 'Тренировка пропущена',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (e.weightKg != null)
                  Text('${e.weightKg!.toStringAsFixed(1)} кг',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          )),
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
  const _StatCard({required this.icon, required this.iconColor, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: valueColor ?? AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------- НАСТРОЙКИ ----------

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Пользователь', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Бесплатный план', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(icon: Icons.workspace_premium_outlined, label: 'Подписка Premium', color: AppTheme.warning),
          _SettingsTile(icon: Icons.logout, label: 'Выйти', color: AppTheme.danger),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingsTile({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
        onTap: () {},
      ),
    );
  }
}
