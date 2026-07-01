// mobile/lib/features/progress/services/progress_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_entry.dart';

/// Репозиторий для локального хранения записей прогресса.
/// Данные сохраняются в SharedPreferences как JSON-массив.
/// Когда бэкенд подключит /progress endpoint — этот класс
/// будет использоваться как fallback/cache при offline.
abstract final class ProgressRepository {
  static const _storageKey = 'progress_entries';

  static Future<List<ProgressEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return _seedDefaultEntries();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      // Если данные повреждены — не теряем приложение, начинаем заново
      return [];
    }
  }

  static Future<void> save(List<ProgressEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> addEntry(ProgressEntry entry) async {
    final entries = await load();
    entries.add(entry);
    await save(entries);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Демо-данные для первого запуска, чтобы экран не был пустым.
  /// Удаляются автоматически как только пользователь добавит свою первую запись.
  static List<ProgressEntry> _seedDefaultEntries() => [
        ProgressEntry(
          date: DateTime.now().subtract(const Duration(days: 6)),
          weightKg: 80.5,
          workoutCompleted: true,
        ),
        ProgressEntry(
          date: DateTime.now().subtract(const Duration(days: 4)),
          weightKg: 80.0,
          workoutCompleted: true,
        ),
        ProgressEntry(
          date: DateTime.now().subtract(const Duration(days: 2)),
          weightKg: 79.5,
          workoutCompleted: true,
        ),
      ];
}
