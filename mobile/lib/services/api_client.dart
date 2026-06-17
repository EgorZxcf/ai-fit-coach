// Путь в репозитории: mobile/lib/services/api_client.dart
// Методы соответствуют docs/api-contract.md. Когда друг задеплоит бэкенд — поменяй baseUrl.
// Добавь в pubspec.yaml под dependencies: http: ^1.2.0

import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://TODO-backend-url.onrender.com';

class ApiClient {
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> generatePlan() async {
    final res = await http.post(
      Uri.parse('$baseUrl/plans/generate'),
      headers: _headers,
      body: jsonEncode({}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/message'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logProgress({
    required String date,
    required double weightKg,
    required bool workoutCompleted,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/progress/log'),
      headers: _headers,
      body: jsonEncode({
        'date': date,
        'weight_kg': weightKg,
        'workout_completed': workoutCompleted,
      }),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
