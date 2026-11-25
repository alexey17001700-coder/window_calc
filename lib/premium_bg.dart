import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Премиальный живой фон: градиент + плывущие орбы + парящие частицы.
class PremiumBg extends StatefulWidget {
  const PremiumBg({super.key, this.child});

  final Widget? child;

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
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(
                painter: _BgPainter(_c.value),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);

  final double t;

  static const int _particles = 46;

  double _hash(int i, int k) {
    final v = math.sin((i + 1) * 12.9898 + k * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // глубокий градиент
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1830), AppColors.bg, Color(0xFF02050A)],
        ).createShader(rect),
    );

    // три плывущих орба
    _orb(canvas, size, AppColors.gold, 0.0, 0.42, 0.30, 0.05);
    _orb(canvas, size, AppColors.blue, 2.1, 0.55, 0.26, 0.04);
    _orb(canvas, size, AppColors.bronze, 4.3, 0.36, 0.24, 0.045);

    // парящие частицы
    final p = Paint();
    for (var i = 0; i < _particles; i++) {
      final sx = _hash(i, 1);
      final sy = _hash(i, 2);
      final sp = 0.35 + _hash(i, 3) * 0.8;
      final ph = (t * 0.55 * sp + sy) % 1.0;
      final y = (1.0 - ph) * (size.height + 60) - 30;
      final wob = math.sin((t * 6.28 * sp) + sx * 6.28) * 14;
      final x = sx * size.width + wob;
      final r = 0.6 + _hash(i, 4) * 1.7;
      final a = (0.04 + _hash(i, 5) * 0.12) * (1 - (ph - 0.5).abs() * 1.2);
      p.color = (i % 7 == 0 ? AppColors.gold : const Color(0xFFB9D4F2))
          .withOpacity(a.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _orb(
    Canvas canvas,
    Size size,
    Color color,
    double phase,
    double cx,
    double cy,
    double alpha,
  ) {
    final dx = math.sin(t * 6.28 + phase) * size.width * 0.10;
    final dy = math.cos(t * 6.28 * 0.8 + phase) * size.height * 0.06;
    final center = Offset(size.width * cx + dx, size.height * cy + dy);
    final radius = size.shortestSide * 0.55;
    final shader = RadialGradient(
      colors: [color.withOpacity(alpha), color.withOpacity(0.0)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}