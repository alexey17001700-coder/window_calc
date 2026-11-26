import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Глобальный ключ вспышки: любой экран может вызвать flashScreen().
final GlobalKey<ScreenFlashState> appFlashKey = GlobalKey<ScreenFlashState>();

/// Запустить мягкую золотую вспышку на весь экран.
void flashScreen() => appFlashKey.currentState?.fire();

/// Мягкая золотая волна: расходится от точки нажатия и растворяется.
class ScreenFlash extends StatefulWidget {
  const ScreenFlash({super.key, required this.child});
  final Widget child;

  @override
  State<ScreenFlash> createState() => ScreenFlashState();
}

class ScreenFlashState extends State<ScreenFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  /// Последняя точка касания (глобальные координаты).
  Offset? _lastPos;

  /// Точка, от которой пошла текущая волна.
  Offset? _fireOrigin;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 720));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Запустить волну от последней точки нажатия.
  void fire() {
    _fireOrigin = _lastPos;
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
                      final align = Alignment(
                        (origin.dx / size.width) * 2 - 1,
                        (origin.dy / size.height) * 2 - 1,
                      );
                      return _wave(align);
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
  Widget _wave(Alignment align) {
    final t = _c.value;
    final fade = (1 - t) * (1 - t);

    // Расширяющееся кольцо: от точки нажатия наружу.
    final double r = 0.10 + t * 0.95;
    const double w = 0.42;
    final double a = (r - w).clamp(0.0, 1.0);
    final double b = (r + w).clamp(0.0, 1.0);

    const int n = 16;
    final stops = <double>[];
    final colors = <Color>[];
    for (var i = 0; i <= n; i++) {
      final f = i / n;
      final s = a + (b - a) * f;
      // Плавный колокол: 0 → 1 → 0, без ступенек и линий.
      final bell = 0.5 - 0.5 * math.cos(2 * math.pi * f);
      stops.add(s);
      colors.add(
          AppColors.gold.withOpacity((fade * bell * 0.55).clamp(0.0, 1.0)));
    }

    // Мягкое ядро в точке нажатия — гаснет быстрее волны.
    final core = (1 - t) * (1 - t) * (1 - t) * 0.30;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: align,
              radius: 2.6,
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
                radius: 0.55,
                colors: [
                  AppColors.goldLight.withOpacity(core),
                  AppColors.gold.withOpacity(core * 0.45),
                  AppColors.gold.withOpacity(0),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
      ],
    );
  }
}
