import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕРТЁЖ ОКНА ПО ГОСТ  ·  v3.4.20
///  Рабочий чертёж, а не картинка:
///   • белый лист, ТОЛЬКО тонкие чёрные линии — без заливок и градиентов;
///   • стена со штриховкой, проём, рама двойной линией;
///   • ОСЕВЫЕ линии штрихпунктиром (вертикальная и горизонтальная);
///   • УГЛОВЫЕ ВЫНОСКИ 90° по четырём углам проёма;
///   • створки с обвязкой и штапиком, размерные линии со стрелками.
///  СТВОРКИ КЛИКАБЕЛЬНЫ: нажатие меняет обозначение открывания
///  по кругу (глухая → поворотная → поворотно-откидная → откидная
///  → снова глухая) — как на реальном чертеже.
/// ═══════════════════════════════════════════════════════════════════

/// Обозначения створок — циклически сменяются по нажатию.
/// 0 — Г (глухая), 1 — П (поворотная), 2 — ПО (поворотно-откидная),
/// 3 — О (откидная).
const List<String> kSashModeNames = [
  'ГЛУХАЯ',
  'ПОВОРОТНАЯ',
  'ПОВОРОТНО-ОТКИДНАЯ',
  'ОТКИДНАЯ',
];

/// Буквенные обозначения по ГОСТ — рисуются прямо на створке.
const List<String> kSashModeLetter = ['Г', 'П', 'ПО', 'О'];

/// Короткие подписи для плашек под чертежом.
const List<String> kSashModeShort = [
  'Г · ГЛУХАЯ',
  'П · ПОВОР.',
  'ПО · ПОВ.-ОТКИД.',
  'О · ОТКИД.',
];

class WindowVisual extends StatefulWidget {
  const WindowVisual({
    super.key,
    required this.sashes,
    required this.arched,
    required this.selectedGlass,
    required this.onGlass,
    this.parts = const [],
    this.sashModes = const [],
    this.onSashTap,
    this.widthMm = 0,
    this.heightMm = 0,
  });

  /// Число створок: 1, 2 или 3.
  final int sashes;

  /// Фигурное окно (арочный верх).
  final bool arched;

  /// Выбранный стеклопакет (-1 — не выбран).
  final int selectedGlass;

  /// Нажатие на стеклопакет.
  final ValueChanged<int> onGlass;

  /// Отмеченная комплектация (влияет на чертёж).
  final List<String> parts;

  /// Обозначение каждой створки (индекс в kSashModeNames).
  final List<int> sashModes;

  /// Нажатие на створку — сменить обозначение.
  final ValueChanged<int>? onSashTap;

  /// Габарит по ширине, мм (0 — неизвестно).
  final int widthMm;

  /// Габарит по высоте, мм (0 — неизвестно).
  final int heightMm;

  @override
  State<WindowVisual> createState() => _WindowVisualState();
}

class _WindowVisualState extends State<WindowVisual> {
  /// Подсвеченная створка.
  int _sel = 0;

  List<int> get _modes => widget.sashModes.length == widget.sashes
      ? widget.sashModes
      : List<int>.filled(widget.sashes, 1);

  void _tap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _sel = i);
    widget.onSashTap?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final modes = _modes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── ЗАГОЛОВОК ЧЕРТЕЖА ──
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
              'ЧЕРТЁЖ · ГОСТ',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'СЕКЦИЯ ${_sel + 1} · ${kSashModeNames[modes[_sel].clamp(0, 3)]}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E93AC),
                ),
              ),
            ),
            const Icon(Icons.touch_app_rounded,
                size: 13, color: Color(0xFF7E93AC)),
          ],
        ),
        const SizedBox(height: 10),

        // ── САМ ЧЕРТЁЖ ──
        LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxWidth / 1.16);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final i = _hit(size, d.localPosition);
                if (i >= 0) _tap(i);
              },
              child: CustomPaint(
                size: size,
                painter: _GostPainter(
                  sashes: widget.sashes,
                  arched: widget.arched,
                  parts: widget.parts,
                  modes: modes,
                  selected: _sel,
                  widthMm: widget.widthMm,
                  heightMm: widget.heightMm,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // ── ОБОЗНАЧЕНИЯ СТВОРОК ──
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < widget.sashes; i++)
              _SashChip(
                index: i,
                name: kSashModeShort[modes[i].clamp(0, 3)],
                selected: _sel == i,
                onTap: () => _tap(i),
              ),
          ],
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

        // ── ВЫБОР ПОД ЧЕРТЕЖОМ ──
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

  /// Какая СЕКЦИЯ под пальцем.
  /// Секция — вся ячейка проёма целиком (рама + обвязка + штапик + стекло),
  /// поэтому попадание считается по проёму, а не по стеклу: палец может
  /// промахнуться мимо стекла на профиль — секция всё равно определится.
  int _hit(Size size, Offset p) {
    final g = _geo(size);
    // Палец вне проёма (стена, поле листа) — не наша секция.
    if (!_openPath(g.opening, widget.arched).contains(p)) return -1;
    final cells = _sashRects(g.opening.deflate(2), widget.sashes);
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].inflate(4).contains(p)) return i;
    }
    // Попал в проём, но между ячейками (арка) — берём ближайшую по X.
    var best = 0;
    var dist = double.infinity;
    for (var i = 0; i < cells.length; i++) {
      final d = (cells[i].center.dx - p.dx).abs();
      if (d < dist) {
        dist = d;
        best = i;
      }
    }
    return best;
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПЛАШКА СТВОРКИ (номер + обозначение по ГОСТ)
/// ═══════════════════════════════════════════════════════════════════
class _SashChip extends StatelessWidget {
  const _SashChip({
    required this.index,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12233A) : const Color(0xFF0A1220),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected
                ? AppColors.gold.withOpacity(0.80)
                : const Color(0xFF1B2C44),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
///  ГЕОМЕТРИЯ ЧЕРТЕЖА (общая для рисования и попадания пальцем)
/// ═══════════════════════════════════════════════════════════════════
class _Geo {
  const _Geo(this.wall, this.opening, this.frameOuter, this.frameInner,
      this.glass);
  final Rect wall;
  final Rect opening;
  final Rect frameOuter;
  final Rect frameInner;
  final Rect glass;
}

_Geo _geo(Size s) {
  final wall = Rect.fromLTWH(
    44,
    30,
    math.max(20, s.width - 62),
    math.max(20, s.height - 70),
  );
  final opening = wall.deflate(11);
  final frameOuter = opening.deflate(5);
  final frameInner = frameOuter.deflate(4.5);
  return _Geo(wall, opening, frameOuter, frameInner, frameInner);
}

List<Rect> _sashRects(Rect glass, int n) {
  final out = <Rect>[];
  final w = glass.width / n;
  for (var i = 0; i < n; i++) {
    out.add(Rect.fromLTWH(glass.left + i * w, glass.top, w, glass.height));
  }
  return out;
}

Path _openPath(Rect r, bool arched) {
  if (!arched) return Path()..addRect(r);
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

/// ═══════════════════════════════════════════════════════════════════
///  ХУДОЖНИК ЧЕРТЕЖА
/// ═══════════════════════════════════════════════════════════════════
class _GostPainter extends CustomPainter {
  _GostPainter({
    required this.sashes,
    required this.arched,
    required this.parts,
    required this.modes,
    required this.selected,
    required this.widthMm,
    required this.heightMm,
  });

  final int sashes;
  final bool arched;
  final List<String> parts;
  final List<int> modes;
  final int selected;
  final int widthMm;
  final int heightMm;

  static const _ink = Color(0xFF16233A);
  static const _paper = Color(0xFFF7F9FC);
  static const _axis = Color(0xFF5B6B80);

  Paint _line(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..color = c;

  @override
  void paint(Canvas canvas, Size size) {
    final g = _geo(size);

    // ── ЛИСТ ──
    final sheet = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    canvas.drawRRect(sheet, Paint()..color = _paper);
    canvas.drawRRect(
      sheet,
      _line(const Color(0xFFC9D4E2), 1),
    );

    // ── СТЕНА СО ШТРИХОВКОЙ ──
    _hatch(canvas, g.wall);
    canvas.drawRect(g.wall, _line(_ink, 1.2));

    // ── ПРОЁМ ──
    final openPath = _openPath(g.opening, arched);
    canvas.drawPath(openPath, _line(_ink, 1.3));

    // ── РАМА (двойная линия) ──
    canvas.drawRect(g.frameOuter, _line(_ink, 1.2));
    canvas.drawRect(g.frameInner, _line(_ink, 1.0));

    // ── ОСЕВЫЕ ЛИНИИ (штрихпунктир) ──
    _axisV(canvas, g.opening.center.dx, g.wall.top - 18, g.wall.bottom + 18);
    _axisH(canvas, g.opening.center.dy, g.wall.left - 18, g.wall.right + 18);

    // ── СТВОРКИ ──
    final rects = _sashRects(g.glass, sashes);
    canvas.save();
    canvas.clipPath(openPath);
    for (var i = 0; i < rects.length; i++) {
      final s = rects[i];
      final o = s.deflate(2.5);
      canvas.drawRect(o, _line(_ink, 1.1));
      final gl = o.deflate(3.5);
      canvas.drawRect(gl, _line(_ink, 0.9));

      _openingMark(canvas, gl, modes[i].clamp(0, 3), hingeLeft: i == 0);
      _handle(canvas, o, hingeLeft: i == 0);
      _sashLetter(canvas, gl, modes[i].clamp(0, 3));

      if (i == selected) {
        canvas.drawRect(
          s.deflate(1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..color = AppColors.gold,
        );
      }
    }
    canvas.restore();

    // ── УГЛОВЫЕ ВЫНОСКИ 90° ──
    _corner90(canvas, g.opening.topLeft, 1, 1);
    _corner90(canvas, g.opening.topRight, -1, 1);
    _corner90(canvas, g.opening.bottomLeft, 1, -1);
    _corner90(canvas, g.opening.bottomRight, -1, -1);

    // ── КОМПЛЕКТАЦИЯ НА ЧЕРТЕЖЕ ──
    final hasSill = parts.contains('С ПОДОКОННИКОМ');
    final hasDrip = parts.contains('С ОТЛИВОМ');
    if (parts.contains('С ОТКОСАМИ')) _otkos(canvas, g);
    if (hasSill) _sill(canvas, g.opening, g.opening.bottom);
    if (hasDrip) {
      _drip(canvas, g.opening,
          g.opening.bottom + (hasSill ? 9 : 0));
    }

    // ── РАЗМЕРНЫЕ ЛИНИИ ──
    _dimH(canvas, g.opening.left, g.opening.right, g.wall.top - 15,
        widthMm > 0 ? '$widthMm' : '?');
    _dimV(canvas, g.opening.top, g.opening.bottom, g.wall.left - 17,
        heightMm > 0 ? '$heightMm' : '?');

    if (rects.length > 1 && widthMm > 0) {
      final y = g.wall.bottom + 17;
      for (final r in rects) {
        _dimH(canvas, r.left, r.right, y,
            '${(widthMm / rects.length).round()}',
            small: true, below: true);
      }
    }

    // ── ПОДПИСЬ ЛИСТА ──
    _text(canvas, 'РАЗМЕРЫ В ММ', Offset(g.wall.left, size.height - 12),
        size: 7.5, color: const Color(0xFF7E93AC), alignLeft: true);
  }

  // ─────────────── ОСЕВАЯ ЛИНИЯ (штрихпунктир) ───────────────
  void _axisV(Canvas canvas, double x, double y1, double y2) =>
      _dashDot(canvas, Offset(x, y1), Offset(x, y2));

  void _axisH(Canvas canvas, double y, double x1, double x2) =>
      _dashDot(canvas, Offset(x1, y), Offset(x2, y));

  void _dashDot(Canvas canvas, Offset a, Offset b) {
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    final p = _line(_axis, 0.8);
    double t = 0;
    while (t < total) {
      final dash = math.min(9.0, total - t);
      canvas.drawLine(a + dir * t, a + dir * (t + dash), p);
      t += dash + 3;
      if (t >= total) break;
      final dot = math.min(1.6, total - t);
      canvas.drawLine(a + dir * t, a + dir * (t + dot), p);
      t += dot + 3;
    }
  }

  // ─────────────── УГЛОВАЯ ВЫНОСКА 90° ───────────────
  void _corner90(Canvas canvas, Offset c, int sx, int sy) {
    const d = 9.0;
    final p = _line(_ink, 0.9);
    canvas.drawLine(c, Offset(c.dx + sx * d, c.dy), p);
    canvas.drawLine(c, Offset(c.dx, c.dy + sy * d), p);
  }

  // ─────────────── ШТРИХОВКА СТЕНЫ ───────────────
  void _hatch(Canvas canvas, Rect r) {
    canvas.save();
    canvas.clipRect(r);
    final p = Paint()
      ..color = const Color(0xFF8FA3BC).withOpacity(0.55)
      ..strokeWidth = 0.9;
    for (double x = r.left - r.height; x < r.right + r.height; x += 7) {
      canvas.drawLine(Offset(x, r.bottom), Offset(x + r.height, r.top), p);
    }
    canvas.restore();
  }

  // ─────────────── ОБОЗНАЧЕНИЕ ОТКРЫВАНИЯ (ГОСТ) ───────────────
  void _openingMark(Canvas canvas, Rect g, int mode,
      {required bool hingeLeft}) {
    final p = _line(_ink, 1.2);
    final cy = g.center.dy;

    // поворотная (П) и поворотно-откидная (ПО): вершина — к петлям
    if (mode == 1 || mode == 2) {
      final h = g.width * 0.60;
      final half = g.height * 0.24;
      final Path t;
      if (hingeLeft) {
        t = Path()
          ..moveTo(g.left + 3, cy)
          ..lineTo(g.left + 3 + h, cy - half)
          ..lineTo(g.left + 3 + h, cy + half)
          ..close();
      } else {
        t = Path()
          ..moveTo(g.right - 3, cy)
          ..lineTo(g.right - 3 - h, cy - half)
          ..lineTo(g.right - 3 - h, cy + half)
          ..close();
      }
      canvas.drawPath(t, p);
    }

    // откидная (О) и поворотно-откидная (ПО): вершина вниз
    if (mode == 2 || mode == 3) {
      final hh = g.height * 0.58;
      final half = g.width * 0.22;
      final t = Path()
        ..moveTo(g.center.dx, g.bottom - 3)
        ..lineTo(g.center.dx - half, g.bottom - 3 - hh)
        ..lineTo(g.center.dx + half, g.bottom - 3 - hh)
        ..close();
      canvas.drawPath(t, p);
    }

  }

  // ─────────────── БУКВЕННОЕ ОБОЗНАЧЕНИЕ СТВОРКИ (Г/П/ПО/О) ───────────────
  void _sashLetter(Canvas canvas, Rect g, int mode) {
    final s = kSashModeLetter[mode.clamp(0, 3)];
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: _ink,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // рамка-плашка в левом верхнем углу стекла
    final box = Rect.fromLTWH(
      g.left + 4,
      g.top + 4,
      tp.width + 10,
      tp.height + 5,
    );
    canvas.drawRect(box, Paint()..color = _paper);
    canvas.drawRect(box, _line(_ink, 1.0));
    tp.paint(canvas, Offset(box.left + 5, box.top + 2.5));
  }

  // ─────────────── РУЧКА ───────────────
  void _handle(Canvas canvas, Rect o, {required bool hingeLeft}) {
    final x = hingeLeft ? o.right - 4 : o.left + 1.6;
    canvas.drawRect(
      Rect.fromLTWH(x, o.center.dy - 7, 2.4, 14),
      Paint()..color = _ink,
    );
  }

  // ─────────────── ОТКОСЫ ───────────────
  void _otkos(Canvas canvas, _Geo g) {
    final left = Path()
      ..moveTo(g.wall.left, g.opening.top)
      ..lineTo(g.opening.left, g.opening.top + 10)
      ..lineTo(g.opening.left, g.opening.bottom - 10)
      ..lineTo(g.wall.left, g.opening.bottom)
      ..close();
    final right = Path()
      ..moveTo(g.wall.right, g.opening.top)
      ..lineTo(g.opening.right, g.opening.top + 10)
      ..lineTo(g.opening.right, g.opening.bottom - 10)
      ..lineTo(g.wall.right, g.opening.bottom)
      ..close();
    for (final p in [left, right]) {
      canvas.drawPath(p, Paint()..color = const Color(0xFFDCE4EE));
      canvas.drawPath(p, _line(_ink, 1.0));
    }
  }

  // ─────────────── ПОДОКОННИК ───────────────
  void _sill(Canvas canvas, Rect win, double top) {
    final r = Rect.fromLTWH(win.left - 8, top, win.width + 16, 9);
    canvas.drawRect(r, Paint()..color = const Color(0xFFEFF3F8));
    canvas.drawRect(r, _line(_ink, 1.1));
    canvas.drawLine(
      Offset(r.left, r.top + 3.2),
      Offset(r.right, r.top + 3.2),
      _line(_ink, 0.7),
    );
  }

  // ─────────────── ОТЛИВ ───────────────
  void _drip(Canvas canvas, Rect win, double top) {
    final p = Path()
      ..moveTo(win.left - 10, top)
      ..lineTo(win.right + 10, top + 2)
      ..lineTo(win.right + 10, top + 8)
      ..lineTo(win.left - 10, top + 8)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFE4EAF2));
    canvas.drawPath(p, _line(_ink, 1.1));
  }

  // ─────────────── РАЗМЕРЫ ───────────────
  void _dimH(Canvas canvas, double x1, double x2, double y, String label,
      {bool small = false, bool below = false}) {
    final p = _line(_ink, 0.9);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), p);
    canvas.drawLine(Offset(x1, y - 4), Offset(x1, y + 4), p);
    canvas.drawLine(Offset(x2, y - 4), Offset(x2, y + 4), p);
    _arrow(canvas, Offset(x1, y), -1);
    _arrow(canvas, Offset(x2, y), 1);
    _text(
      canvas,
      label,
      Offset((x1 + x2) / 2, y + (below ? 9 : -8)),
      size: small ? 7.5 : 9.5,
    );
  }

  void _dimV(Canvas canvas, double y1, double y2, double x, String label) {
    final p = _line(_ink, 0.9);
    canvas.drawLine(Offset(x, y1), Offset(x, y2), p);
    canvas.drawLine(Offset(x - 4, y1), Offset(x + 4, y1), p);
    canvas.drawLine(Offset(x - 4, y2), Offset(x + 4, y2), p);
    _arrowV(canvas, Offset(x, y1), -1);
    _arrowV(canvas, Offset(x, y2), 1);
    _text(canvas, label, Offset(x - 9, (y1 + y2) / 2),
        size: 9.5, vertical: true);
  }

  void _arrow(Canvas canvas, Offset tip, int dir) {
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + dir * 7, tip.dy - 2.6)
        ..lineTo(tip.dx + dir * 7, tip.dy + 2.6)
        ..close(),
      Paint()..color = _ink,
    );
  }

  void _arrowV(Canvas canvas, Offset tip, int dir) {
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 2.6, tip.dy + dir * 7)
        ..lineTo(tip.dx + 2.6, tip.dy + dir * 7)
        ..close(),
      Paint()..color = _ink,
    );
  }

  void _text(Canvas canvas, String s, Offset center,
      {double size = 9.5,
      Color color = _ink,
      bool vertical = false,
      bool alignLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (vertical) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      return;
    }
    final dx = alignLeft ? center.dx : center.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GostPainter old) =>
      old.sashes != sashes ||
      old.arched != arched ||
      old.selected != selected ||
      old.widthMm != widthMm ||
      old.heightMm != heightMm ||
      !_same(old.parts, parts) ||
      !_sameInt(old.modes, modes);

  bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _sameInt(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
