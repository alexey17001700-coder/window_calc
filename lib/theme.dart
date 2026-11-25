import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон · Алмаз».
class AppColors {
  static const bg = Color(0xFF050A12);
  static const bg2 = Color(0xFF0A1424);
  static const card = Color(0xFF0E1B2E);
  static const card2 = Color(0xFF122238);
  static const line = Color(0xFF1B2C44);

  static const text = Color(0xFFEAF1FA);
  static const dim = Color(0xFF9FB1C6);
  static const faint = Color(0xFF5B6B80);

  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFEFE0B4);
  static const goldDark = Color(0xFF9E7B2A);
  static const bronze = Color(0xFFB87333);

  static const green = Color(0xFF3FBF7F);
  static const red = Color(0xFFE0574A);
  static const blue = Color(0xFF3E7BB8);

  // алиасы старой палитры — чтобы не ломать вызовы
  static const navy900 = bg;
  static const navy800 = bg2;
  static const navy700 = card;
  static const border = line;
  static const textDim = dim;
  static const textFaint = faint;
  static const danger = red;
  static const ok = green;

  static const glassTop = Color(0xFFD8EDFC);
  static const glassBottom = Color(0xFFB6DBF4);
  static const glassLine = Color(0xFF7FB3D5);
}

/// Размеры, градиенты и мелкие сборщики разметки.
class AppUi {
  static const double radiusSm = 12;
  static const double radius = 18;
  static const double radiusLg = 26;
  static const double pad = 16;
  static const double gap = 12;
  static const double buttonH = 52;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C1830), AppColors.bg, Color(0xFF02050A)],
  );

  static const LinearGradient cardGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.card2, AppColors.card],
  );

  // алиасы
  static const LinearGradient goldGrad = goldGradient;
  static const LinearGradient bgGrad = navyGradient;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0xCC000000), blurRadius: 34, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x1FC9A227), blurRadius: 26, spreadRadius: 1),
  ];

  static Widget label(String s, {Color color = AppColors.dim}) {
    return Text(
      s,
      style: TextStyle(
        fontSize: 10,
        height: 1.2,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  static Widget sectionTitle(String s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            s,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  static Widget card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: cardGrad,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: const Color(0x4DC9A227), width: 1),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }
}

/// Тёмная тема с золотым акцентом.
ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.gold,
    secondary: AppColors.goldLight,
    surface: AppColors.card,
    error: AppColors.red,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
    ),
    // ВАЖНО: без заливки и рамок — иначе поля наследуют белую подложку темы
    // (баг 3.3.2+55, текст становился невидимым).
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      hintStyle: TextStyle(color: AppColors.faint, fontSize: 14),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.text, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.dim, fontSize: 12),
    ),
    dividerColor: AppColors.line,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.card2,
      contentTextStyle: TextStyle(color: AppColors.text, fontSize: 13),
      behavior: SnackBarBehavior.floating,
    ),
  );
}