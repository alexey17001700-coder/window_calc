import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕРТЁЖ ОКНА ПО ГОСТ  ·  v3.4.24
///  Рабочий чертёж, а не картинка:
///   • белый лист, ТОЛЬКО тонкие чёрные линии — без заливок и градиентов;
///   • стена со штриховкой, проём, рама двойной линией;
///   • ОСЕВЫЕ линии штрихпунктиром (вертикальная и горизонтальная);
///   • УГЛОВЫЕ ВЫНОСКИ 90° по четырём углам проёма;
///   • створки с обвязкой и штапиком;
///   • РАЗМЕРНЫЕ ЛИНИИ: габарит сверху и слева, промежуточные — по секциям
///     (нижний ряд) и по высоте стеклопакета / арки (справа), с выносными
///     линиями, стрелками и числами в мм.
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
    this.sectionWidths = const [],
    this.hingeCounts = const [],
  });

  /// Число створок: 1, 2, 3 или 4.
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

  /// Доли ширины секций (сумма ≈ 1.0). Пусто — секции равные.
  final List<double> sectionWidths;

  /// Число петель на каждой створке. По умолчанию 2 — верхняя и нижняя.
  /// Дополнительные петли замерщик добавляет ВРУЧНУЮ (например, на дверь).
  final List<int> hingeCounts;

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
                  sectionWidths: widget.sectionWidths,
                  hingeCounts: widget.hingeCounts,
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
    final cells =
        _sashRects(g.opening.deflate(2), widget.sashes, widget.sectionWidths);
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

/// Доли ширины секций: пусто или не то число — делим поровну.
List<double> _normWidths(int n, List<double> widths) {
  if (widths.length == n) {
    final sum = widths.fold<double>(0, (a, b) => a + b);
    if (sum > 0) return [for (final w in widths) w / sum];
  }
  return List<double>.filled(n, 1.0 / n);
}

/// Прямоугольники секций с УЧЁТОМ ручной ширины (долей).
List<Rect> _sashRects(Rect glass, int n, [List<double>? widths]) {
  final out = <Rect>[];
  final ws = _normWidths(n, widths ?? const []);
  var x = glass.left;
  for (var i = 0; i < n; i++) {
    final w = glass.width * ws[i];
    out.add(Rect.fromLTWH(x, glass.top, w, glass.height));
    x += w;
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
    this.sectionWidths = const [],
    this.hingeCounts = const [],
  });

  final int sashes;
  final bool arched;
  final List<String> parts;
  final List<int> modes;
  final int selected;
  final int widthMm;
  final int heightMm;
  final List<double> sectionWidths;
  final List<int> hingeCounts;

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
    final rects = _sashRects(g.glass, sashes, sectionWidths);
    canvas.save();
    canvas.clipPath(openPath);
    for (var i = 0; i < rects.length; i++) {
      final s = rects[i];
      final o = s.deflate(2.5);
      canvas.drawRect(o, _line(_ink, 1.1));
      final gl = o.deflate(3.5);
      canvas.drawRect(gl, _line(_ink, 0.9));

      _openingMark(canvas, gl, modes[i].clamp(0, 3), hingeLeft: i == 0);
      _hardware(canvas, o, modes[i].clamp(0, 3),
          hingeLeft: i == 0, hinges: _hingesFor(i));
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
    // Габарит по ширине — сверху, с выносными линиями от углов проёма.
    final dimTop = g.wall.top - 15;
    _dimH(canvas, g.opening.left, g.opening.right, dimTop,
        widthMm > 0 ? '$widthMm' : '?');
    _extV(canvas, g.opening.left, g.opening.top, dimTop);
    _extV(canvas, g.opening.right, g.opening.top, dimTop);

    // Габарит по высоте — слева, с выносными линиями.
    final dimLeft = g.wall.left - 17;
    _dimV(canvas, g.opening.top, g.opening.bottom, dimLeft,
        heightMm > 0 ? '$heightMm' : '?');
    _extH(canvas, g.opening.top, g.opening.left, dimLeft);
    _extH(canvas, g.opening.bottom, g.opening.left, dimLeft);

    // Промежуточные размеры по ширине — по каждой секции (нижний ряд).
    if (rects.length > 1) {
      final y = g.wall.bottom + (hasSill || hasDrip ? 30 : 17);
      final ws = _normWidths(sashes, sectionWidths);
      for (var i = 0; i < rects.length; i++) {
        final r = rects[i];
        _dimH(canvas, r.left, r.right, y,
            widthMm > 0 ? '${(widthMm * ws[i]).round()}' : '?',
            small: true, below: true);
        _extV(canvas, r.left, g.opening.bottom, y);
        _extV(canvas, r.right, g.opening.bottom, y);
      }
    }

    // Промежуточный размер по высоте — справа: у фигурного окна это высота
    // арки, у обычного — высота стеклопакета.
    if (heightMm > 0) {
      final x = g.wall.right + 17;
      if (arched) {
        final rad = g.opening.width * 0.5;
        final hArch = (heightMm * rad / g.opening.height).round();
        _dimV(canvas, g.opening.top, g.opening.top + rad, x, '$hArch',
            small: true, right: true);
        _extH(canvas, g.opening.top, g.opening.right, x);
        _extH(canvas, g.opening.top + rad, g.opening.right, x);
      } else {
        final gt = g.frameInner.top;
        final gb = g.frameInner.bottom;
        final hGlass = (heightMm * (gb - gt) / g.opening.height).round();
        _dimV(canvas, gt, gb, x, '$hGlass', small: true, right: true);
        _extH(canvas, gt, g.frameInner.right, x);
        _extH(canvas, gb, g.frameInner.right, x);
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

    // ── ПОВОРОТНАЯ (П) и ПОВОРОТНО-ОТКИДНАЯ (ПО):
    //    УЗКАЯ ВЕРШИНА — К РУЧКЕ, два угла основания — К ПЕТЛЯМ.
    if (mode == 1 || mode == 2) {
      final h = g.width * 0.60;
      final half = g.height * 0.24;
      final Path t;
      if (hingeLeft) {
        // петли слева → ручка справа → вершина справа
        t = Path()
          ..moveTo(g.right - 3, cy)
          ..lineTo(g.right - 3 - h, cy - half)
          ..lineTo(g.right - 3 - h, cy + half)
          ..close();
      } else {
        // петли справа → ручка слева → вершина слева
        t = Path()
          ..moveTo(g.left + 3, cy)
          ..lineTo(g.left + 3 + h, cy - half)
          ..lineTo(g.left + 3 + h, cy + half)
          ..close();
      }
      canvas.drawPath(t, p);
    }

    // ── ОТКИДНАЯ (О) и ПОВОРОТНО-ОТКИДНАЯ (ПО):
    //    вершина ВВЕРХУ на верхней кромке, основание растянуто ВНИЗ
    //    до самой нижней кромки створки.
    if (mode == 2 || mode == 3) {
      final half = g.width * 0.22;
      final t = Path()
        ..moveTo(g.center.dx, g.top + 3)
        ..lineTo(g.center.dx - half, g.bottom - 3)
        ..lineTo(g.center.dx + half, g.bottom - 3)
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

  // ─────────────── ФУРНИТУРА (по типу створки) ───────────────
  //  Г  — глухая:            фурнитуры нет;
  //  П  — поворотная:        петли на одной стороне, ручка напротив;
  //  ПО — поворотно-откидная: петли + ручка + нижняя петля откидывания;
  //  О  — откидная:          петли снизу, ручка сверху.
  void _hardware(Canvas canvas, Rect o, int mode, {required bool hingeLeft}) {
    if (mode == 0) return; // глухая — без фурнитуры

    final ink = Paint()..color = _ink;

    // ── ОТКИДНАЯ: две петли снизу, ручка по верхней обвязке ──
    if (mode == 3) {
      const pw = 12.0;
      canvas.drawRect(
          Rect.fromLTWH(o.center.dx - 12 - pw / 2, o.bottom - 3.4, pw, 3.4), ink);
      canvas.drawRect(
          Rect.fromLTWH(o.center.dx + 12 - pw / 2, o.bottom - 3.4, pw, 3.4), ink);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(o.center.dx - 7, o.top + 1.2, 14, 2.6),
          const Radius.circular(1.3),
        ),
        ink,
      );
      return;
    }

    // ── П и ПО: три петли по стороне петель ──
    final hx = hingeLeft ? o.left : o.right - 3;
    for (final t in const [0.15, 0.50, 0.85]) {
      canvas.drawRect(
        Rect.fromLTWH(hx, o.top + o.height * t - 5, 3, 10),
        ink,
      );
    }

    // ручка на противоположной петлям стороне (площадка + рычаг)
    final rx = hingeLeft ? o.right - 5.4 : o.left + 1.6;
    canvas.drawRect(Rect.fromLTWH(rx, o.center.dy - 4, 3.8, 8), ink);
    canvas.drawRect(Rect.fromLTWH(rx, o.center.dy - 7.5, 2.2, 15), ink);

    // ── ПО: нижняя петля откидывания ──
    if (mode == 2) {
      canvas.drawRect(
        Rect.fromLTWH(o.center.dx - 6, o.bottom - 3.4, 12, 3.4),
        ink,
      );
    }
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

  void _dimV(Canvas canvas, double y1, double y2, double x, String label,
      {bool small = false, bool right = false}) {
    final p = _line(_ink, 0.9);
    canvas.drawLine(Offset(x, y1), Offset(x, y2), p);
    canvas.drawLine(Offset(x - 4, y1), Offset(x + 4, y1), p);
    canvas.drawLine(Offset(x - 4, y2), Offset(x + 4, y2), p);
    _arrowV(canvas, Offset(x, y1), -1);
    _arrowV(canvas, Offset(x, y2), 1);
    _text(canvas, label, Offset(x + (right ? 9 : -9), (y1 + y2) / 2),
        size: small ? 7.5 : 9.5, vertical: true);
  }

  // ─────────────── ВЫНОСНЫЕ ЛИНИИ ───────────────
  /// Выносная линия к горизонтальному размеру (вертикальная).
  void _extV(Canvas canvas, double x, double fromY, double toY) {
    final p = _line(const Color(0xFF8FA3BC), 0.7);
    final dir = toY < fromY ? -1.0 : 1.0;
    canvas.drawLine(Offset(x, fromY), Offset(x, toY + dir * 3), p);
  }

  /// Выносная линия к вертикальному размеру (горизонтальная).
  void _extH(Canvas canvas, double y, double fromX, double toX) {
    final p = _line(const Color(0xFF8FA3BC), 0.7);
    final dir = toX < fromX ? -1.0 : 1.0;
    canvas.drawLine(Offset(fromX, y), Offset(toX + dir * 3, y), p);
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
      !_sameD(old.sectionWidths, sectionWidths) ||
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

  bool _sameD(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
