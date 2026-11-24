import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон Almas».
class AppColors {
  // ── базовые (новое поколение кода) ──
  static const bg = Color(0xFF0E1116);
  static const bg2 = Color(0xFF151A22);
  static const card = Color(0xFF1B212B);
  static const line = Color(0xFF2A323F);
  static const text = Color(0xFFEAF0F7);
  static const dim = Color(0xFF93A0B4);
  static const gold = Color(0xFFD9A441);
  static const bronze = Color(0xFFB07A3A);
  static const green = Color(0xFF3FBF7F);
  static const red = Color(0xFFE05B5B);
  static const blue = Color(0xFF4A90D9);

  // ── синие уровни (заставка, мастер, шапки) ──
  static const navy900 = Color(0xFF0E1116);
  static const navy800 = Color(0xFF151A22);
  static const navy700 = Color(0xFF1B2430);

  // ── золото ──
  static const goldLight = Color(0xFFF0C96A);
  static const goldDark = Color(0xFFB07A3A);

  // ── текст ──
  static const textDim = Color(0xFF93A0B4);
  static const textFaint = Color(0xFF6E819A);

  // ── стекло ──
  static const glassTop = Color(0x1AFFFFFF);
  static const glassBottom = Color(0x0DFFFFFF);
  static const glassLine = Color(0x33FFFFFF);

  // ── статусы ──
  static const danger = Color(0xFFE05B5B);
  static const ok = Color(0xFF3FBF7F);

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF0C96A), Color(0xFFD9A441), Color(0xFFB07A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const navyGradient = LinearGradient(
    colors: [Color(0xFF1B2430), Color(0xFF0E1116)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Общие элементы интерфейса.
class AppUi {
  static const double radiusSm = 10;
  static const double radius = 16;
  static const double radiusLg = 26;
  static const double pad = 16;
  static const double gap = 12;
  static const double buttonH = 52;

  static const LinearGradient cardGrad = LinearGradient(
    colors: [Color(0xFF202834), Color(0xFF171D26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  static const LinearGradient goldGrad = AppColors.goldGradient;
  static const LinearGradient bgGrad = AppColors.navyGradient;

  static Widget label(String text, {Color? color, double size = 11}) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? AppColors.dim,
        fontSize: size,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration card({Color? border}) => BoxDecoration(
        gradient: cardGrad,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? AppColors.line),
        boxShadow: cardShadow,
      );
}

/// Темы приложения: тёмная (основная) и светлая.
class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final base = ThemeData(useMaterial3: true, brightness: b);

    return base.copyWith(
      scaffoldBackgroundColor: dark ? AppColors.bg : const Color(0xFFF4F6F9),
      colorScheme: (dark
              ? const ColorScheme.dark(
                  primary: AppColors.gold,
                  secondary: AppColors.bronze,
                  surface: AppColors.card,
                )
              : const ColorScheme.light(
                  primary: AppColors.goldDark,
                  secondary: AppColors.bronze,
                  surface: Colors.white,
                ))
          .copyWith(error: AppColors.danger),
      dividerColor: AppColors.line,
      // Поля ввода — БЕЗ заливки и рамок темы: у мастера своя подложка.
      // Именно из-за `filled: true` + белого fillColor текст был невидим (3.3.2+55).
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textFaint),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.bg2 : Colors.white,
        foregroundColor: dark ? AppColors.text : AppColors.navy900,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: dark ? AppColors.card : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUi.radius),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy900,
          minimumSize: const Size.fromHeight(AppUi.buttonH),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUi.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.bronze),
          minimumSize: const Size.fromHeight(AppUi.buttonH),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUi.radiusSm),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: dark ? AppColors.text : AppColors.navy900,
        displayColor: dark ? AppColors.text : AppColors.navy900,
      ),
    );
  }
}
