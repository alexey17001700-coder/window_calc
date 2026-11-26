import 'package:flutter/material.dart';

import 'theme.dart';

/// Глобальный ключ вспышки: любой экран может вызвать flashScreen().
final GlobalKey<ScreenFlashState> appFlashKey = GlobalKey<ScreenFlashState>();

/// Запустить мягкую золотую вспышку на весь экран.
void flashScreen() => appFlashKey.currentState?.fire();

/// Мягкая золотая вспышка на весь экран при нажатии кнопки.
class ScreenFlash extends StatefulWidget {
  const ScreenFlash({super.key, required this.child});
  final Widget child;

  @override
  State<ScreenFlash> createState() => ScreenFlashState();
}

class ScreenFlashState extends State<ScreenFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 620));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Запустить вспышку (мягкое золотое свечение, гаснет само).
  void fire() => _c.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                if (_c.value == 0) return const SizedBox.shrink();
                final t = _c.value;
                final o = (1 - t) * (1 - t) * 0.42;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.15,
                      colors: [
                        AppColors.gold.withOpacity(o),
                        AppColors.goldLight.withOpacity(o * 0.5),
                        AppColors.gold.withOpacity(o * 0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
