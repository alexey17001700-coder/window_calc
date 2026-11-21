part of 'onboarding.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПРОБЕГАЮЩИЙ БЛИК ПО КАРТОЧКЕ
/// ═══════════════════════════════════════════════════════════════════
class _ShinePainter extends CustomPainter {
  _ShinePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final x = (t * 1.6 - 0.3) * size.width;
    final w = size.width * 0.22;
    final rect = Rect.fromLTWH(x, 0, w, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, 0),
          Offset(x + w, size.height),
          [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.045),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ShinePainter old) => old.t != t;
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ ФОН — тёмный градиент, золотые орбы, парящие частицы
/// ═══════════════════════════════════════════════════════════════════
class _PremiumBg extends StatefulWidget {
  const _PremiumBg();

  @override
  State<_PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<_PremiumBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
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
        builder: (_, __) => CustomPaint(painter: _BgPainter(_c.value)),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // База — глубокий графитово-синий
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1522), Color(0xFF060C16)],
        ).createShader(rect),
    );

    // Три медленно плывущих орба
    _orb(canvas, size, 0.22, 0.18, 0.55, AppColors.gold, 0.16, 0.0);
    _orb(canvas, size, 0.82, 0.72, 0.62, const Color(0xFF2E6FB8), 0.18, 0.33);
    _orb(canvas, size, 0.50, 0.95, 0.48, AppColors.bronze, 0.12, 0.66);

    // Парящие частицы
    final p = Paint();
    for (var i = 0; i < 46; i++) {
      final seed = i * 7.13;
      final bx = (math.sin(seed) * 0.5 + 0.5);
      final by = (math.cos(seed * 1.7) * 0.5 + 0.5);
      final drift = math.sin(t * math.pi * 2 + seed) * 0.035;
      final x = (bx + drift) * size.width;
      final y = ((by - t * 0.06) % 1.0) * size.height;
      final r = 0.7 + (i % 4) * 0.55;
      final a = 0.10 + (i % 5) * 0.055;
      p.color = (i % 3 == 0 ? AppColors.gold : const Color(0xFF9FB0C6))
          .withOpacity(a);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _orb(Canvas canvas, Size size, double cx, double cy, double r,
      Color color, double alpha, double phase) {
    final ang = t * math.pi * 2 + phase * math.pi * 2;
    final ox = cx + math.sin(ang) * 0.06;
    final oy = cy + math.cos(ang * 0.8) * 0.05;
    final center = Offset(ox * size.width, oy * size.height);
    final radius = r * size.width;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          color.withOpacity(alpha),
          color.withOpacity(0.0),
        ]),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
