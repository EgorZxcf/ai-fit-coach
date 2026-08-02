// mobile/lib/features/progress/models/progress_entry.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Замеры тела в рамках одной записи прогресса — все поля опциональны,
/// пользователь заполняет только то, что измерил.
final class BodyMeasurements {
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? bicepCm;

  const BodyMeasurements({
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.bicepCm,
  });

  bool get isEmpty =>
      waistCm == null && chestCm == null && hipsCm == null && bicepCm == null;

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) => BodyMeasurements(
        waistCm: (json['waist_cm'] as num?)?.toDouble(),
        chestCm: (json['chest_cm'] as num?)?.toDouble(),
        hipsCm: (json['hips_cm'] as num?)?.toDouble(),
        bicepCm: (json['bicep_cm'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'waist_cm': waistCm,
        'chest_cm': chestCm,
        'hips_cm': hipsCm,
        'bicep_cm': bicepCm,
      };
}

/// Модель одной записи прогресса пользователя.
final class ProgressEntry {
  final DateTime date;
  final double? weightKg;
  final bool workoutCompleted;
  final String? photoPath;
  final BodyMeasurements? measurements;

  const ProgressEntry({
    required this.date,
    this.weightKg,
    required this.workoutCompleted,
    this.photoPath,
    this.measurements,
  });

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
  bool get hasMeasurements => measurements != null && !measurements!.isEmpty;

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        workoutCompleted: json['workout_completed'] as bool,
        photoPath: json['photo_path'] as String?,
        measurements: json['measurements'] != null
            ? BodyMeasurements.fromJson(json['measurements'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight_kg': weightKg,
        'workout_completed': workoutCompleted,
        'photo_path': photoPath,
        'measurements': measurements?.toJson(),
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