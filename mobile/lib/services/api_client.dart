// mobile/lib/services/api_client.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Результат API запроса — либо данные либо ошибка.
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiError(this.message, {this.statusCode});
}

/// HTTP клиент для работы с Vexor backend API.
/// Хранит токен авторизации и добавляет его в заголовки автоматически.
final class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<ApiResult<Map<String, dynamic>>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiSuccess(data);
      }
      return ApiError(
        data['detail']?.toString() ?? 'Ошибка сервера',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return const ApiError('Превышено время ожидания. Попробуй снова.');
    } catch (e) {
      return ApiError('Нет соединения с сервером.');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _get(String path) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiSuccess(data);
      }
      return ApiError(
        data['detail']?.toString() ?? 'Ошибка сервера',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return const ApiError('Превышено время ожидания. Попробуй снова.');
    } catch (e) {
      return ApiError('Нет соединения с сервером.');
    }
  }

  // Auth
  Future<ApiResult<Map<String, dynamic>>> register(
    String email,
    String password,
  ) => _post(ApiConstants.register, {'email': email, 'password': password});

  Future<ApiResult<Map<String, dynamic>>> login(
    String email,
    String password,
  ) => _post(ApiConstants.login, {'email': email, 'password': password});

  // Chat
  Future<ApiResult<Map<String, dynamic>>> sendMessage(String message) =>
      _post(ApiConstants.chatMessage, {'message': message});

  // Progress
  Future<ApiResult<Map<String, dynamic>>> logProgress({
    required String date,
    required double weightKg,
    required bool workoutCompleted,
  }) => _post(ApiConstants.progressLog, {
        'date': date,
        'weight_kg': weightKg,
        'workout_completed': workoutCompleted,
      });

  Future<ApiResult<Map<String, dynamic>>> getProgress() =>
      _get(ApiConstants.progress);
}
