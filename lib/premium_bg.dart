import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Премиальный фон: глубокий градиент, плывущие орбы и парящие частицы.
class PremiumBg extends StatefulWidget {
  const PremiumBg({super.key});

  @override
  State<PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<PremiumBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _BgPainter(_c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;

  _BgPainter(this.t);

  static double _hash(int i, int k) {
    final v = math.sin(i * 12.9898 + k * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy900, AppColors.navy800, Color(0xFF0B1526)],
        ).createShader(rect),
    );

    void orb(double cx, double cy, double r, Color c, double phase) {
      final dx = math.sin((t + phase) * math.pi * 2) * 0.06;
      final dy = math.cos((t + phase) * math.pi * 2) * 0.05;
      final center = Offset(size.width * (cx + dx), size.height * (cy + dy));
      final radius = size.shortestSide * r;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [c.withOpacity(0.15), c.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    orb(0.20, 0.24, 0.42, AppColors.gold, 0.0);
    orb(0.82, 0.38, 0.38, const Color(0xFF3E7BB8), 0.33);
    orb(0.55, 0.86, 0.40, const Color(0xFF8A6A2A), 0.66);

    final p = Paint();
    for (var i = 0; i < 46; i++) {
      final bx = _hash(i, 1);
      final by = _hash(i, 2);
      final sp = 0.35 + _hash(i, 3) * 0.9;
      final y = (by - (t * sp) % 1.0 + 1.0) % 1.0;
      final x = (bx + math.sin((t + bx) * math.pi * 2) * 0.02) % 1.0;
      final r = 0.6 + _hash(i, 4) * 1.6;
      p.color = (i % 7 == 0 ? AppColors.gold : const Color(0xFF9FB4CC))
          .withOpacity(0.10 + _hash(i, 5) * 0.22);
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
