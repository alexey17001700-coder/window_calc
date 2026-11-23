import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

/// Живой фон: тёмный градиент + плавно поднимающиеся пузыри.
class PremiumBg extends StatefulWidget {
  final Widget child;
  const PremiumBg({super.key, required this.child});

  @override
  State<PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<PremiumBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final List<_Bubble> _bubbles = [];
  final Random _rnd = Random(7);

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 18; i++) {
      _bubbles.add(_Bubble(
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        r: 6 + _rnd.nextDouble() * 26,
        speed: 0.2 + _rnd.nextDouble() * 0.6,
        alpha: 0.04 + _rnd.nextDouble() * 0.08,
      ));
    }
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
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
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.navyGradient),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _BubblePainter(_bubbles, _c.value),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Bubble {
  final double x;
  final double y;
  final double r;
  final double speed;
  final double alpha;
  _Bubble({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.alpha,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double t;
  _BubblePainter(this.bubbles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bubbles) {
      var y = (b.y - t * b.speed) % 1.0;
      if (y < 0) y += 1.0;
      final paint = Paint()
        ..color = AppColors.gold.withOpacity(b.alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(b.x * size.width, y * size.height), b.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.t != t;
}
