import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ВИЗУАЛЬНОЕ ОКНО  ·  v3.4.16
///  После выбора типа дома показываем САМО окно (нарисованное) и под
///  ним — выбор стеклопакета. Створки и арка берутся из выбранного вида.
/// ═══════════════════════════════════════════════════════════════════
class WindowVisual extends StatefulWidget {
  const WindowVisual({
    super.key,
    required this.sashes,
    required this.arched,
    required this.selectedGlass,
    required this.onGlass,
  });

  /// Число створок: 1, 2 или 3.
  final int sashes;

  /// Фигурное окно (арочный верх).
  final bool arched;

  /// Выбранный стеклопакет (-1 — не выбран).
  final int selectedGlass;

  /// Нажатие на стеклопакет.
  final ValueChanged<int> onGlass;

  @override
  State<WindowVisual> createState() => _WindowVisualState();
}

class _WindowVisualState extends State<WindowVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── САМО ОКНО ──
        SizedBox(
          height: 208,
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.arched ? 0.94 : 1.16,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(
                  painter: _WindowPainter(
                    sashes: widget.sashes,
                    arched: widget.arched,
                    t: _c.value,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── ПОДПИСЬ ──
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'СТЕКЛОПАКЕТ',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'выберите наполнение',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E93AC),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ── ВЫБОР ПОД ОКНОМ ──
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < glassTypes.length; i++)
                  SizedBox(
                    width: w,
                    child: _GlassChip(
                      node: glassTypes[i],
                      selected: widget.selectedGlass == i,
                      onTap: () => widget.onGlass(i),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  КАРТОЧКА СТЕКЛОПАКЕТА (сжимается при нажатии)
/// ═══════════════════════════════════════════════════════════════════
class _GlassChip extends StatefulWidget {
  const _GlassChip({
    required this.node,
    required this.selected,
    required this.onTap,
  });

  final WorkNode node;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends State<_GlassChip> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: Duration(milliseconds: _down ? 90 : 190),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF12233A) : const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: sel
                  ? AppColors.gold.withOpacity(0.78)
                  : const Color(0xFF1B2C44),
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.node.icon, size: 16, color: AppColors.gold),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.node.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
              ),
              if (sel)
                const Icon(Icons.check_rounded,
                    size: 14, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  РИСУНОК ОКНА: золотая рамка, стекло, импосты, ручки, арка
/// ═══════════════════════════════════════════════════════════════════
class _WindowPainter extends CustomPainter {
  _WindowPainter({
    required this.sashes,
    required this.arched,
    required this.t,
  });

  final int sashes;
  final bool arched;
  final double t;

  Path _shape(Rect r) {
    if (!arched) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(9)));
    }
    final rad = r.width * 0.5;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, r.top + rad)
      ..arcToPoint(
        Offset(r.right, r.top + rad),
        radius: Radius.circular(rad),
        clockwise: true,
      )
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final path = _shape(r);

    // Тень окна
    canvas.drawPath(
      path.shift(const Offset(0, 7)),
      Paint()
        ..color = Colors.black.withOpacity(0.50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.save();
    canvas.clipPath(path);

    // Стекло
    canvas.drawRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          const [Color(0xFF1D3E62), Color(0xFF0D1F34), Color(0xFF17324F)],
          const [0.0, 0.55, 1.0],
        ),
    );

    // Отражение неба сверху
    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.34),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, r.top),
          Offset(0, r.top + r.height * 0.34),
          [Colors.white.withOpacity(0.09), Colors.white.withOpacity(0.0)],
        ),
    );

    // Пробегающий блик по стеклу
    final sx = r.left + (t * 1.5 - 0.25) * r.width;
    final sw = r.width * 0.20;
    canvas.drawRect(
      Rect.fromLTWH(sx, r.top, sw, r.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(sx, r.top),
          Offset(sx + sw, r.bottom),
          [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );

    // Импосты между створками
    final mull = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..color = AppColors.gold.withOpacity(0.55);
    for (var i = 1; i < sashes; i++) {
      final x = r.left + r.width * i / sashes;
      canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), mull);
    }

    // Ручки у импостов
    final handle = Paint()..color = AppColors.gold.withOpacity(0.85);
    for (var i = 1; i < sashes; i++) {
      final x = r.left + r.width * i / sashes;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x - 5, r.center.dy),
            width: 3.2,
            height: 16,
          ),
          const Radius.circular(2),
        ),
        handle,
      );
    }

    canvas.restore();

    // Золотая рамка
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          [AppColors.gold, AppColors.bronze, AppColors.gold],
        ),
    );

    // Тонкий блик по рамке
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _WindowPainter old) =>
      old.t != t || old.sashes != sashes || old.arched != arched;
}
