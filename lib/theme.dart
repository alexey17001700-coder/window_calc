import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон Almas».
class AppColors {
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
