import 'package:flutter/material.dart';

/// Премиальная палитра приложения.
/// Глубокий графитово-синий + золото/бронза.
class AppColors {
  // Тёмная база
  static const navy900 = Color(0xFF0B1522);
  static const navy800 = Color(0xFF0F1B2D);
  static const navy700 = Color(0xFF16263D);
  static const navy600 = Color(0xFF1E3252);
  static const navy500 = Color(0xFF2A4468);

  // Золото / бронза
  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFE0BE55);
  static const goldDark = Color(0xFF9A7A18);
  static const bronze = Color(0xFFB08D57);

  // Светлая тема
  static const paper = Color(0xFFF7F8FA);
  static const paperCard = Color(0xFFFFFFFF);
  static const ink = Color(0xFF14202E);
  static const inkSoft = Color(0xFF5A6B80);
  static const line = Color(0xFFE2E6EC);

  // Служебные
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFC0392B);
  static const info = Color(0xFF2D6CDF);

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy800, navy900],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );
}

/// Единая тема приложения.
class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy800,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: AppColors.navy900,
        surface: AppColors.paperCard,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      textTheme: _text(AppColors.ink, AppColors.inkSoft),
      cardTheme: _card(Colors.white),
      appBarTheme: _appBar(AppColors.navy800, Colors.white),
      inputDecorationTheme: _input(false),
      filledButtonTheme: _filled(AppColors.navy800, Colors.white),
      outlinedButtonTheme: _outlined(AppColors.gold),
      chipTheme: _chip(),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: _snack(),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.navy900,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.navy900,
        surface: AppColors.navy800,
        onSurface: Color(0xFFEAF0F8),
        error: Color(0xFFE05A4A),
      ),
      textTheme: _text(const Color(0xFFEAF0F8), const Color(0xFF9FB0C6)),
      cardTheme: _card(AppColors.navy800),
      appBarTheme: _appBar(AppColors.navy900, Colors.white),
      inputDecorationTheme: _input(true),
      filledButtonTheme: _filled(AppColors.gold, AppColors.navy900),
      outlinedButtonTheme: _outlined(AppColors.gold),
      chipTheme: _chip(),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF22344F),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: _snack(),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.navy800,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  // ── Типографика ────────────────────────────────────────────────
  static TextTheme _text(Color main, Color soft) => TextTheme(
        displaySmall: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: main),
        headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: main),
        headlineSmall: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: main),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: main),
        titleMedium: TextStyle(
            fontSize: 15.5, fontWeight: FontWeight.w700, color: main),
        titleSmall: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: main),
        bodyLarge: TextStyle(fontSize: 15, height: 1.35, color: main),
        bodyMedium: TextStyle(fontSize: 13.5, height: 1.35, color: soft),
        bodySmall: TextStyle(fontSize: 12, height: 1.3, color: soft),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: main),
        labelMedium: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: soft),
      );

  // ── Компоненты ─────────────────────────────────────────────────
  static CardTheme _card(Color bg) => CardTheme(
        color: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.16),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      );

  static AppBarTheme _appBar(Color bg, Color fg) => AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: fg,
        ),
      );

  static InputDecorationTheme _input(bool dark) => InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.navy700 : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: dark ? const Color(0xFF6E819A) : const Color(0xFF9AA8B8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF2A3F5C) : AppColors.line,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF2A3F5C) : AppColors.line,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
      );

  static FilledButtonThemeData _filled(Color bg, Color fg) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlined(Color c) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: c.withOpacity(0.55), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      );

  static ChipThemeData _chip() => ChipThemeData(
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: AppColors.gold, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        labelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.gold,
        ),
      );

  static SnackBarThemeData _snack() => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy800,
        contentTextStyle: const TextStyle(
            fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );
}

/// Общие премиальные элементы, используемые на всех экранах.
class AppUi {
  /// Заголовок раздела: золотая черта + КАПС + линия до края.
  static Widget sectionTitle(BuildContext context, String text) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: dark ? AppColors.goldLight : AppColors.bronze,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: dark ? const Color(0xFF22344F) : AppColors.line,
            ),
          ),
        ],
      ),
    );
  }

  /// Тёмная градиентная панель (итоги, суммы).
  static Widget darkPanel({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy900.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Капс-лейбл.
  static Widget label(String text, {Color? color, double size = 11}) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: color ?? const Color(0xFF8FA2B8),
      ),
    );
  }
}
