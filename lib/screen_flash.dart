import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Глобальный ключ вспышки: любой экран может вызвать flashScreen().
final GlobalKey<ScreenFlashState> appFlashKey = GlobalKey<ScreenFlashState>();

/// Запустить мягкую золотую волну.
/// [origin] — глобальная точка старта (обычно центр кнопки).
/// Если не задана — берётся последняя точка касания.
void flashScreen([Offset? origin]) => appFlashKey.currentState?.fire(origin);

/// Центр виджета в глобальных координатах — волна идёт «прямо от кнопки».
Offset? flashOriginOf(BuildContext context) {
  final ro = context.findRenderObject();
  if (ro is RenderBox && ro.hasSize) {
    return ro.localToGlobal(ro.size.center(Offset.zero));
  }
  return null;
}

/// Центр виджета по его ключу — то же самое, но без доступа к контексту.
Offset? flashOriginOfKey(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return null;
  return flashOriginOf(ctx);
}

/// Мягкая золотая волна: расходится от кнопки и растворяется без граней.
class ScreenFlash extends StatefulWidget {
  const ScreenFlash({super.key, required this.child});
  final Widget child;

  @override
  State<ScreenFlash> createState() => ScreenFlashState();
}

class ScreenFlashState extends State<ScreenFlash>
    with SingleTickerProviderStateMixin {
  /// Медленная волна: 2.6 с от нажатия до полного растворения.
  late final AnimationController _c;

  /// Плавное расширение: мягкий разгон и очень мягкое торможение.
  late final Animation<double> _spread;

  /// Последняя точка касания (глобальные координаты).
  Offset? _lastPos;

  /// Точка, от которой пошла текущая волна.
  Offset? _fireOrigin;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _spread = CurvedAnimation(parent: _c, curve: Curves.easeOutSine);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Запустить волну от центра кнопки (или от последнего касания).
  void fire([Offset? origin]) {
    _fireOrigin = origin ?? _lastPos;
    _c.forward(from: 0);
  }

  Offset _localOrigin(Size size) {
    final g = _fireOrigin;
    if (g == null) return Offset(size.width / 2, size.height / 2);
    final ro = context.findRenderObject();
    if (ro is RenderBox && ro.hasSize) return ro.globalToLocal(g);
    return Offset(size.width / 2, size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _lastPos = e.position,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  if (_c.value == 0) return const SizedBox.shrink();
                  return LayoutBuilder(
                    builder: (ctx, cons) {
                      final size = Size(cons.maxWidth, cons.maxHeight);
                      if (size.width <= 0 || size.height <= 0) {
                        return const SizedBox.shrink();
                      }
                      final origin = _localOrigin(size);
                      return _wave(origin, size);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Мягкая волна без резких граней: плавный «колокол» яркости.
  /// [center] — точка старта в координатах виджета, [size] — размер области.
  /// Радиус волны ограничен ~130 px: чуть больше кнопки, экран не заливает.
  Widget _wave(Offset center, Size size) {
    final t = _spread.value; // плавное расширение
    final life = _c.value; // линейное время для затухания

    // Растворение: мягко в начале, ровно в ноль в конце — без обрыва.
    final fade = math.pow(1 - life, 2.2).toDouble() * (1 - 0.25 * life);

    final double shortest = math.min(size.width, size.height);
    if (shortest <= 0) return const SizedBox.shrink();

    // Предел расхождения и ширина мягкой полосы — в пикселях.
    const double maxR = 130.0; // дальше кнопки в ~2 раза и стоп
    const double ringPx = 26.0; // широкая полоса — граней не видно
    final double ringR = 8.0 + t * maxR; // текущий радиус кольца

    // Радиус градиента с запасом под полосу, переводим в доли shortestSide.
    final double gradPx = maxR + ringPx * 2;
    final double radius = gradPx / shortest;

    // Точка старта в Alignment (-1..1) — координаты виджета в доли размера.
    final Alignment align = Alignment(
      (center.dx / size.width) * 2 - 1,
      (center.dy / size.height) * 2 - 1,
    );

    final double a = ((ringR - ringPx) / gradPx).clamp(0.0, 1.0);
    final double b = ((ringR + ringPx) / gradPx).clamp(0.0, 1.0);

    const int n = 28;
    final stops = <double>[];
    final colors = <Color>[];
    for (var i = 0; i <= n; i++) {
      final f = i / n;
      final s = a + (b - a) * f;
      // Плавный колокол: 0 → 1 → 0, без ступенек и линий.
      final bell = 0.5 - 0.5 * math.cos(2 * math.pi * f);
      final soft = math.pow(bell, 1.6).toDouble();
      stops.add(s);
      colors.add(
          AppColors.gold.withOpacity((fade * soft * 0.40).clamp(0.0, 1.0)));
    }

    // Мягкое ядро в точке старта — гаснет медленнее волны.
    final core = math.pow(1 - life, 1.6).toDouble() * 0.30;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: align,
              radius: radius,
              colors: colors,
              stops: stops,
            ),
          ),
        ),
        if (core > 0.004)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: align,
                radius: 0.35,
                colors: [
                  AppColors.goldLight.withOpacity(core),
                  AppColors.gold.withOpacity(core * 0.40),
                  AppColors.gold.withOpacity(0),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
      ],
    );
  }
}
