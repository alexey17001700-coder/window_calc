import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон Almas».
class AppColors {
  AppColors._();

  static const Color navy900 = Color(0xFF060B14);
  static const Color navy800 = Color(0xFF0A1220);
  static const Color navy700 = Color(0xFF0E1A2C);
  static const Color card = Color(0xFF0C1626);
  static const Color border = Color(0xFF1B2C44);

  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFEFE0B4);
  static const Color goldDark = Color(0xFF9E7B2A);

  static const Color text = Color(0xFFE8EEF7);
  static const Color textDim = Color(0xFF7E93AC);
  static const Color textFaint = Color(0xFF44586F);

  static const Color glassTop = Color(0xFFD8EDFC);
  static const Color glassBottom = Color(0xFFB6DBF4);
  static const Color glassLine = Color(0xFF7FB3D5);

  static const Color danger = Color(0xFFE05A5A);
  static const Color ok = Color(0xFF4CC38A);
}

/// Общие размеры интерфейса.
class AppUi {
  AppUi._();

  static const double radius = 16;
  static const double radiusLg = 26;
  static const double pad = 16;
  static const double gap = 12;
  static const double buttonH = 52;
}

/// Тёмная тема приложения.
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.navy900,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.gold,
      secondary: AppColors.goldLight,
      surface: AppColors.navy800,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy900,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.gold),
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 15,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      hintStyle: TextStyle(color: AppColors.textDim, fontSize: 14),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.navy700,
      contentTextStyle: TextStyle(color: AppColors.text, fontSize: 13),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
