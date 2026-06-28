// mobile/lib/core/widgets/vexor_logo.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Логотип Vexor — буква V с молнией на зелёном фоне.
/// Используется на экране авторизации, онбординга и в настройках.
class VexorLogo extends StatelessWidget {
  final double size;

  const VexorLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'V',
            style: TextStyle(
              color: Colors.black,
              fontSize: size * 0.58,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -1,
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            right: size * 0.18,
            child: Icon(
              Icons.bolt,
              color: Colors.white.withOpacity(0.75),
              size: size * 0.28,
            ),
          ),
        ],
      ),
    );
  }
}
