// mobile/lib/core/navigation/fade_route.dart

import 'package:flutter/material.dart';

/// Плавный переход между экранами с fade-анимацией.
/// Используется вместо стандартного MaterialPageRoute.
final class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        );
}
