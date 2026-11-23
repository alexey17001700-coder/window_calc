import 'package:flutter/material.dart';

/// Палитра приложения «Замерщик окон Almas».
class AppColors {
  static const navy900 = Color(0xFF070C16);
  static const navy800 = Color(0xFF0A1220);
  static const navy700 = Color(0xFF0E1A2C);
  static const card = Color(0xFF0B1524);
  static const line = Color(0xFF1B2C44);

  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFEFE0B4);
  static const goldDark = Color(0xFF9E7B2A);
  static const goldSoft = Color(0xFFDCBB66);

  static const text = Color(0xFFE8EEF7);
  static const textDim = Color(0xFF7E93AC);
  static const textFaint = Color(0xFF44586F);

  static const glass = Color(0xFFB6DBF4);
  static const glassDeep = Color(0xFF7FB3D5);
  static const danger = Color(0xFFE05A5A);
}

/// Общие размеры, градиенты и тени интерфейса.
class AppUi {
  static const radius = 26.0;
  static const radiusSm = 14.0;
  static const pad = 18.0;
  static const buttonH = 52.0;

  static const currency = '₽';

  static const goldGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
  );

  static const cardGrad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.navy700, AppColors.navy800],
  );

  static const bgGrad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1526), AppColors.navy900, Color(0xFF04070D)],
  );

  static const cardShadow = <BoxShadow>[
    BoxShadow(color: Color(0xCC000000), blurRadius: 34, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x33C9A227), blurRadius: 26, offset: Offset(0, 8)),
  ];

  static const softShadow = <BoxShadow>[
    BoxShadow(color: Color(0x99000000), blurRadius: 22, offset: Offset(0, 10)),
  ];
}
