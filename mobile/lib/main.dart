// mobile/lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'features/auth/screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Прозрачный статус-бар
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Инициализация сервисов
  await NotificationService.initialize();

  runApp(const VexorApp());
}

class VexorApp extends StatelessWidget {
  const VexorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vexor',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}
