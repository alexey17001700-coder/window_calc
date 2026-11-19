import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ВИЗУАЛЬНОЕ ОКНО  ·  v3.4.18
///  Нарисовано РЕАЛЬНОЕ окно: проём в стене, толстый профиль, створки
///  со своими обвязками, штапик, стеклопакет с отражением неба, ручки.
///  Комплектация влияет на рисунок:
///    • «С ПОДОКОННИКОМ» → рисуется подоконник;
///    • «С ОТЛИВОМ»      → рисуется отлив (капельник);
///    • «С ОТКОСАМИ»     → рисуются боковые откосы.
///  Под окном — выбор стеклопакета.
/// ═══════════════════════════════════════════════════════════════════
class WindowVisual extends StatefulWidget {
  const WindowVisual({
    super.key,
    required this.sashes,
    required this.arched,
    required this.selectedGlass,
    required this.onGlass,
    this.parts = const [],
  });

  /// Число створок: 1, 2 или 3.
  final int sashes;

  /// Фигурное окно (арочный верх).
  final bool arched;

  /// Выбранный стеклопакет (-1 — не выбран).
  final int selectedGlass;

  /// Нажатие на стеклопакет.
  final ValueChanged<int> onGlass;

  /// Отмеченная комплектация (влияет на рисунок окна).
  final List<String> parts;

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
          height: 236,
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.arched ? 0.95 : 1.30,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => CustomPaint(
                  painter: _WindowPainter(
                    sashes: widget.sashes,
                    arched: widget.arched,
                    parts: widget.parts,
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
///  РИСУНОК ОКНА
///  Проём → профиль → створки (обвязка + штапик + стеклопакет + ручка)
///  → подоконник / отлив / откосы по комплектации.
/// ═══════════════════════════════════════════════════════════════════
class _WindowPainter extends CustomPainter {
  _WindowPainter({
    required this.sashes,
    required this.arched,
    required this.parts,
    required this.t,
  });

  final int sashes;
  final bool arched;
  final List<String> parts;
  final double t;

  // ── палитра профиля (тёплый бело-золотой ПВХ) ──
  static const _profLight = Color(0xFFF7EDCB);
  static const _profMid = Color(0xFFDCBB66);
  static const _profDeep = Color(0xFF9E7B2A);
  static const _profEdge = Color(0xFFEFE0B4);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final needSill = parts.contains('С ПОДОКОННИКОМ');
    final needDrip = parts.contains('С ОТЛИВОМ');
    final needOtkos = parts.contains('С ОТКОСАМИ');

    // ── ПРОЁМ В СТЕНЕ ──
    final wall = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(w, h),
          const [Color(0xFF182742), Color(0xFF0A1220)],
        ),
    );
    canvas.drawRRect(
      wall,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.gold.withOpacity(0.16),
    );

    // ── ГЕОМЕТРИЯ ОКНА ──
    final bottomBand = 6.0 + (needSill ? 12 : 0) + (needDrip ? 13 : 0);
    final mx = w * ((needSill || needDrip) ? 0.125 : 0.105);
    final mt = h * 0.075;
    final win = Rect.fromLTWH(
      mx,
      mt,
      w - mx * 2,
      h - mt - bottomBand - h * 0.05,
    );
    final fb = (win.width * 0.052).clamp(6.5, 14.0); // толщина профиля рамы
    final sb = (fb * 0.80).clamp(4.0, 11.0); // обвязка створки
    final shape = _shape(win, arched);

    // ── ОТКОСЫ (по комплектации) ──
    if (needOtkos) {
      _otkos(canvas, Rect.fromLTWH(0, win.top - h * 0.03, win.left,
          win.height + h * 0.06), left: true);
      _otkos(
          canvas,
          Rect.fromLTWH(win.right, win.top - h * 0.03,
              w - win.right, win.height + h * 0.06),
          left: false);
    }

    // ── ТЕНЬ ОКНА ──
    canvas.drawPath(
      shape.shift(Offset(0, 7)),
      Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // ── РАМА (сплошной профиль) ──
    _fillProfile(canvas, win, shape);
    // фаска по передней кромке рамы
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Colors.white.withOpacity(0.30),
    );

    // ── СТВОРКИ ──
    final glass = win.deflate(fb);
    final sw = glass.width / sashes;
    canvas.save();
    canvas.clipPath(shape);

    for (var i = 0; i < sashes; i++) {
      final sash = Rect.fromLTWH(glass.left + i * sw, glass.top, sw, glass.height);

      // обвязка створки — тот же профиль, чуть темнее
      canvas.drawRect(
        sash,
        Paint()
          ..shader = ui.Gradient.linear(
            sash.topLeft,
            sash.bottomRight,
            const [_profEdge, _profMid, _profDeep],
            const [0.0, 0.55, 1.0],
          ),
      );
      // штапик — тонкая светлая рамка вокруг стеклопакета
      final sg = sash.deflate(sb);
      canvas.drawRect(
        sg.inflate(1.4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withOpacity(0.34),
      );
      // стеклопакет
      _glassPane(canvas, sg);
      // ручка
      _handle(canvas, sash, sb);
    }

    // внутренняя тень по периметру стекла — глубина
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = fb * 1.6
        ..color = Colors.black.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();

    // ── КОНТУР РАМЫ ──
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = ui.Gradient.linear(
          win.topLeft,
          win.bottomRight,
          [AppColors.gold, AppColors.bronze, AppColors.gold],
        ),
    );

    // ── ПОДОКОННИК / ОТЛИВ / БАЗА ──
    final sillTop = win.bottom - 2;
    final sillH = 11.0;
    if (needDrip) _drip(canvas, win, needSill ? sillTop + sillH - 3 : sillTop);
    if (needSill) _sill(canvas, win, sillTop, sillH);
    if (!needSill && !needDrip) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(win.left - w * 0.01, win.bottom - 1.5,
              win.width + w * 0.02, 3.5),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF2A3B54),
      );
    }
  }

  // ───────────────────── ФОРМА ОКНА ─────────────────────
  Path _shape(Rect r, bool arc) {
    if (!arc) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)));
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

  // ───────────────────── ПРОФИЛЬ ─────────────────────
  void _fillProfile(Canvas canvas, Rect r, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topLeft,
          r.bottomRight,
          const [_profLight, _profMid, _profDeep, _profEdge],
          const [0.0, 0.34, 0.72, 1.0],
        ),
    );
  }

  // ───────────────────── СТЕКЛО ─────────────────────
  void _glassPane(Canvas canvas, Rect g) {
    // сам стеклопакет — небо и глубина
    canvas.drawRect(
      g,
      Paint()
        ..shader = ui.Gradient.linear(
          g.topLeft,
          g.bottomRight,
          const [Color(0xFF2F6392), Color(0xFF102741), Color(0xFF1C3D60)],
          const [0.0, 0.62, 1.0],
        ),
    );
    // отражение неба сверху
    canvas.drawRect(
      Rect.fromLTWH(g.left, g.top, g.width, g.height * 0.44),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, g.top),
          Offset(0, g.top + g.height * 0.44),
          [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.0)],
        ),
    );
    // диагональный блик (движется)
    final sx = g.left + (t * 1.5 - 0.25) * g.width;
    final sw = g.width * 0.24;
    canvas.drawRect(
      Rect.fromLTWH(sx, g.top, sw, g.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(sx, g.top),
          Offset(sx + sw, g.bottom),
          [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.13),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );
    // вторая тонкая полоса — «двойной» отблеск стеклопакета
    canvas.drawRect(
      Rect.fromLTWH(g.left + g.width * 0.08, g.top,
          g.width * 0.055, g.height * 0.7),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, g.top),
          Offset(0, g.top + g.height * 0.7),
          [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );
  }

  // ───────────────────── РУЧКА ─────────────────────
  void _handle(Canvas canvas, Rect sash, double band) {
    final x = sash.right - band * 0.60;
    final cy = sash.center.dy;
    // площадка
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, cy), width: band * 0.70, height: 24),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFAEB7C2),
    );
    // рычаг (уходит на стекло)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x - band * 0.95, cy),
          width: band * 1.55,
          height: 4.4,
        ),
        const Radius.circular(2.2),
      ),
      Paint()..color = const Color(0xFFDCE2E9),
    );
    // блик на рычаге
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x - band * 0.95, cy - 1.3),
          width: band * 1.4,
          height: 1.2,
        ),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.white.withOpacity(0.75),
    );
    // ось
    canvas.drawCircle(
        Offset(x, cy), 2.4, Paint()..color = const Color(0xFF7C858F));
  }

  // ───────────────────── ОТКОСЫ ─────────────────────
  void _otkos(Canvas canvas, Rect r, {required bool left}) {
    final slant = r.width * 0.42;
    final p = Path();
    if (left) {
      p
        ..moveTo(r.left, r.top)
        ..lineTo(r.right, r.top + slant)
        ..lineTo(r.right, r.bottom - slant)
        ..lineTo(r.left, r.bottom)
        ..close();
    } else {
      p
        ..moveTo(r.right, r.top)
        ..lineTo(r.left, r.top + slant)
        ..lineTo(r.left, r.bottom - slant)
        ..lineTo(r.right, r.bottom)
        ..close();
    }
    canvas.drawPath(
      p,
      Paint()
        ..shader = ui.Gradient.linear(
          left ? Offset(r.left, 0) : Offset(r.right, 0),
          left ? Offset(r.right, 0) : Offset(r.left, 0),
          const [Color(0xFF2B3E5A), Color(0xFFCFD8E2)],
        ),
    );
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.18),
    );
  }

  // ───────────────────── ПОДОКОННИК ─────────────────────
  void _sill(Canvas canvas, Rect win, double top, double height) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(win.left - win.width * 0.045, top,
          win.width + win.width * 0.09, height),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          r.outerRect.topLeft,
          r.outerRect.bottomRight,
          const [Color(0xFFF3F6FA), Color(0xFFC3CDD9), Color(0xFF8E9BAA)],
          const [0.0, 0.55, 1.0],
        ),
    );
    // блик по верхней кромке
    canvas.drawLine(
      Offset(r.outerRect.left + 1, r.outerRect.top + 1.2),
      Offset(r.outerRect.right - 1, r.outerRect.top + 1.2),
      Paint()
        ..strokeWidth = 1.4
        ..color = Colors.white.withOpacity(0.70),
    );
    // передняя кромка
    canvas.drawLine(
      Offset(r.outerRect.left + 1, r.outerRect.bottom - 2.4),
      Offset(r.outerRect.right - 1, r.outerRect.bottom - 2.4),
      Paint()
        ..strokeWidth = 1.2
        ..color = Colors.black.withOpacity(0.28),
    );
  }

  // ───────────────────── ОТЛИВ (КАПЕЛЬНИК) ─────────────────────
  void _drip(Canvas canvas, Rect win, double top) {
    final dx = win.width * 0.035;
    final hh = 9.5;
    final p = Path()
      ..moveTo(win.left - dx, top)
      ..lineTo(win.right + dx, top + 2.2)
      ..lineTo(win.right + dx, top + hh)
      ..lineTo(win.left - dx, top + hh)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(win.left, top),
          Offset(win.right, top + hh),
          const [Color(0xFFB8C3CF), Color(0xFF7C8896), Color(0xFF5D6875)],
          const [0.0, 0.5, 1.0],
        ),
    );
    // блик по кромке отлива
    canvas.drawLine(
      Offset(win.left - dx + 1, top + 1.2),
      Offset(win.right + dx - 1, top + 3.2),
      Paint()
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.60),
    );
    // загиб (капельник)
    canvas.drawLine(
      Offset(win.left - dx + 1, top + hh - 1.4),
      Offset(win.right + dx - 1, top + hh - 1.4),
      Paint()
        ..strokeWidth = 1.4
        ..color = Colors.black.withOpacity(0.34),
    );
  }

  @override
  bool shouldRepaint(covariant _WindowPainter old) =>
      old.t != t ||
      old.sashes != sashes ||
      old.arched != arched ||
      !_same(old.parts, parts);

  bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
