// mobile/lib/core/constants/api_constants.dart

/// Константы для работы с API.
/// Менять baseUrl только здесь — не в коде сервисов.
abstract final class ApiConstants {
  static const String baseUrl = 'https://vexor-backend-84uf.onrender.com';
  static const Duration timeout = Duration(seconds: 30);

  // Auth
  static const String register = '/register';
  static const String login = '/login';

  // Plan
  static const String generatePlan = '/plans/generate';
  static const String currentPlan = '/plans/current';

  // Chat
  static const String chatMessage = '/chat/message';
  static const String chatHistory = '/chat/history';

  // Progress
  static const String progressLog = '/progress/log';
  static const String progress = '/progress';

  // Billing
  static const String billingVerify = '/billing/verify';
  static const String billingStatus = '/billing/status';
}
