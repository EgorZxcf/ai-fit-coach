// mobile/lib/features/profile/models/user_profile.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Профиль пользователя: физические параметры для расчётов
/// (норма калорий, темп прогресса) и персонализации ИИ-чата.
/// Хранится локально; при готовности бэкенд-эндпоинта /profile
/// достаточно добавить sync в ProfileStorage.save().
class UserProfile {
  final int? age;
  final double? heightCm;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final String? gender; // 'male' | 'female' | null

  const UserProfile({
    this.age,
    this.heightCm,
    this.currentWeightKg,
    this.targetWeightKg,
    this.gender,
  });

  UserProfile copyWith({
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? gender,
  }) =>
      UserProfile(
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        currentWeightKg: currentWeightKg ?? this.currentWeightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        gender: gender ?? this.gender,
      );

  /// Индекс массы тела. null если не хватает данных.
  double? get bmi {
    if (heightCm == null || currentWeightKg == null || heightCm == 0) {
      return null;
    }
    final heightM = heightCm! / 100;
    return currentWeightKg! / (heightM * heightM);
  }

  bool get isComplete =>
      age != null && heightCm != null && currentWeightKg != null;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] as int?,
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
        targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
        gender: json['gender'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'age': age,
        'height_cm': heightCm,
        'current_weight_kg': currentWeightKg,
        'target_weight_kg': targetWeightKg,
        'gender': gender,
      };
}

class ProfileStorage {
  static const _key = 'user_profile_v1';

  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  static Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
