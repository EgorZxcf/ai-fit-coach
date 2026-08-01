// mobile/lib/features/progress/models/progress_entry.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Модель одной записи прогресса пользователя.
final class ProgressEntry {
  final DateTime date;
  final double? weightKg;
  final bool workoutCompleted;

  const ProgressEntry({
    required this.date,
    this.weightKg,
    required this.workoutCompleted,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        workoutCompleted: json['workout_completed'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight_kg': weightKg,
        'workout_completed': workoutCompleted,
      };
}

/// Локальное хранилище записей прогресса (независимо от бэкенда).
/// Используется как основной источник правды, пока /progress
/// эндпоинт не готов или недоступен — API вызывается best-effort,
/// но UI всегда работает с локальной копией.
class ProgressStorage {
  static const _key = 'progress_entries_v1';

  static Future<List<ProgressEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<ProgressEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> add(ProgressEntry entry) async {
    final current = await load();
    current.add(entry);
    await saveAll(current);
  }
}