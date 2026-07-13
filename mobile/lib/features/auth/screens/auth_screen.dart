// mobile/lib/features/auth/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/fade_route.dart';
import '../../../core/widgets/vexor_logo.dart';
import '../../../core/widgets/snackbar_helper.dart';
import '../../../services/api_client.dart';
import '../widgets/feature_chip.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../root_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPasswordConfirmController = TextEditingController();

  bool _loginPasswordVisible = false;
  bool _regPasswordVisible = false;
  bool _regPasswordConfirmVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logoController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regPasswordConfirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  Future<void> _navigateAfterAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      FadeRoute(
        page: onboardingDone ? const RootScreen() : const OnboardingScreen(),
      ),
    );
  }

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.showError(context, 'Заполни все поля');
      return;
    }
    if (!_isValidEmail(email)) {
      SnackbarHelper.showError(context, 'Некорректный email');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiClient.instance.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case ApiSuccess(:final data):
        final token = data['access_token'] as String?;
        if (token == null) {
          SnackbarHelper.showError(context, 'Неверный ответ сервера');
          return;
        }
        await ApiClient.instance.saveToken(token);
        await _navigateAfterAuth();
      case ApiError(:final message):
        SnackbarHelper.showError(context, message);
    }
  }

  Future<void> _register() async {
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final confirm = _regPasswordConfirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      SnackbarHelper.showError(context, 'Заполни все поля');
      return;
    }
    if (!_isValidEmail(email)) {
      SnackbarHelper.showError(context, 'Некорректный email');
      return;
    }
    if (password.length < 6) {
      SnackbarHelper.showError(context, 'Пароль минимум 6 символов');
      return;
    }
    if (password != confirm) {
      SnackbarHelper.showError(context, 'Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiClient.instance.register(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case ApiSuccess():
        SnackbarHelper.showSuccess(context, 'Аккаунт создан! Войди в систему.');
        _tabController.animateTo(0);
        _regEmailController.clear();
        _regPasswordController.clear();
        _regPasswordConfirmController.clear();
      case ApiError(:final message):
        SnackbarHelper.showError(context, message);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !passwordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF131920), Color(0xFF0A0E17)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      // Логотип
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _logoAnimation,
                            child: const VexorLogo(size: 88),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vexor',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Твой персональный AI-тренер',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Вкладки
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.black,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Войти'),
                            Tab(text: 'Регистрация'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Форма
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Вход
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _loginEmailController,
                                  hint: 'example@mail.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                const Text('Пароль',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _loginPasswordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  passwordVisible: _loginPasswordVisible,
                                  onTogglePassword: () => setState(() =>
                                      _loginPasswordVisible =
                                          !_loginPasswordVisible),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text('Забыл пароль?',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12)),
                                  ),
                                ),
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary))
                                    : FilledButton(
                                        onPressed: _login,
                                        child: const Text('Войти')),
                              ],
                            ),
                            // Регистрация
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _regEmailController,
                                  hint: 'example@mail.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),
                                const Text('Пароль',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _regPasswordController,
                                  hint: 'Минимум 6 символов',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  passwordVisible: _regPasswordVisible,
                                  onTogglePassword: () => setState(() =>
                                      _regPasswordVisible =
                                          !_regPasswordVisible),
                                ),
                                const SizedBox(height: 12),
                                const Text('Повтори пароль',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _regPasswordConfirmController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  passwordVisible: _regPasswordConfirmVisible,
                                  onTogglePassword: () => setState(() =>
                                      _regPasswordConfirmVisible =
                                          !_regPasswordConfirmVisible),
                                ),
                                const SizedBox(height: 14),
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary))
                                    : FilledButton(
                                        onPressed: _register,
                                        child: const Text('Создать аккаунт')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Нижняя часть — фичи и дисклеймер прижаты к низу
                  Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FeatureChip(
                              icon: Icons.smart_toy_outlined,
                              label: 'AI-тренер'),
                          FeatureChip(
                              icon: Icons.show_chart, label: 'Прогресс'),
                          FeatureChip(
                              icon: Icons.fitness_center, label: 'Планы'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Нажимая кнопку, ты соглашаешься с условиями использования.\nПриложение не заменяет консультацию врача.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
