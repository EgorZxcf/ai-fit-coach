// mobile/lib/features/progress/services/progress_photo_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Сохраняет фото прогресса в постоянную папку приложения,
/// так как путь, который отдаёт image_picker, указывает на
/// временный файл и может быть удалён системой.
abstract final class ProgressPhotoService {
  static const _folderName = 'progress_photos';

  static Future<Directory> _photosDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Копирует файл из временного пути image_picker в постоянное
  /// хранилище и возвращает новый путь для сохранения в ProgressEntry.
  static Future<String> persist(String temporaryPath) async {
    final dir = await _photosDir();
    final extension = temporaryPath.split('.').last;
    final fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final savedPath = '${dir.path}/$fileName';
    await File(temporaryPath).copy(savedPath);
    return savedPath;
  }

  /// Удаляет файл фото с диска (например, если запись удаляют).
  static Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
