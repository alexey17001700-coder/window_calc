import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон Almas».
class AppColors {
  AppColors._();

  static const Color navy900 = Color(0xFF060B14);
  static const Color navy800 = Color(0xFF0A1220);
  static const Color navy700 = Color(0xFF0E1A2C);
  static const Color card = Color(0xFF0C1626);
  static const Color border = Color(0xFF1B2C44);

  /// Тонкая линия рамок (псевдоним [border] — имя, которое ждут виджеты).
  static const Color line = Color(0xFF1B2C44);

  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFEFE0B4);
  static const Color goldDark = Color(0xFF9E7B2A);

  /// Тёплый бронзовый акцент (плитки иконок дерева).
  static const Color bronze = Color(0xFF8A6A2A);

  static const Color text = Color(0xFFE8EEF7);
  static const Color textDim = Color(0xFF7E93AC);
  static const Color textFaint = Color(0xFF44586F);

  static const Color glassTop = Color(0xFFD8EDFC);
  static const Color glassBottom = Color(0xFFB6DBF4);
  static const Color glassLine = Color(0xFF7FB3D5);

  static const Color danger = Color(0xFFE05A5A);
  static const Color ok = Color(0xFF4CC38A);

  /// Градиент золота — кнопки, плитки, номера изделий в смете и листе.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );

  /// Градиент тёмной шапки мастера.
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy700, navy900],
  );
}

/// Общие размеры и градиенты интерфейса.
class AppUi {
  AppUi._();

  static const double radius = 16;
  static const double radiusLg = 26;
  static const double radiusSm = 13;
  static const double pad = 16;
  static const double gap = 12;
  static const double buttonH = 52;

  /// Градиент карточки мастера.
  static const LinearGradient cardGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF152740), Color(0xFF0B1524)],
  );

  /// Тень карточки мастера.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black54, blurRadius: 26, offset: Offset(0, 12)),
  ];

  /// Градиент золотой кнопки.
  static const LinearGradient goldGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
  );

  /// Градиент фона экрана.
  static const LinearGradient bgGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navy900, AppColors.navy800, Color(0xFF0B1526)],
  );

  /// Подпись поля с разрядкой.
  static Widget label(String text, {Color? color, double size = 9}) => Text(
        text,
        style: TextStyle(
          color: color ?? AppColors.textDim,
          fontSize: size,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w600,
        ),
      );

  /// Заголовок раздела.
  static Widget sectionTitle(BuildContext context, String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
        ),
      );
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
