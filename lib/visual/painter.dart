part of '../window_visual.dart';

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

    // ── СТЕНА (штриховка убрана — чистый контур) ──
    canvas.drawRect(g.wall, _line(_ink, 1.2));

    // ── ПРОЁМ ──
    final openPath = _openPath(g.opening, arched);
    canvas.drawPath(openPath, _line(_ink, 1.3));

    // ── РАМА (ОДНА линия — штапик убран, контур упрощён) ──
    canvas.drawRect(g.frameOuter, _line(_ink, 1.3));

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
      // обвязка створки — ОДНА линия, штапик не рисуем
      canvas.drawRect(o, _line(_ink, 1.1));
      final gl = o.deflate(1.6);
      // стеклопакет — ГОЛУБОЙ: заливка + голубой контур (стекло видно сразу)
      final glR = RRect.fromRectAndRadius(gl, const Radius.circular(2));
      canvas.drawRRect(
        glR,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD8EDFC), Color(0xFFB6DBF4)],
          ).createShader(gl),
      );
      canvas.drawRRect(glR, _line(const Color(0xFF7FB3D5), 0.9));

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
  //  ПО — поворотно-откидная: петли на стороне, ручка напротив;
  //  О  — откидная:          петли на стороне, ручка сверху.
  //  ПЕТЛИ — ТОЛЬКО СЛЕВА ИЛИ СПРАВА, СНИЗУ ПЕТЕЛЬ НЕТ.
  /// Сколько петель у створки i. По умолчанию 2 (верхняя и нижняя).
  int _hingesFor(int i) {
    if (hingeCounts.length == sashes) return hingeCounts[i].clamp(2, 6);
    return 2;
  }

  /// Положения петель по высоте створки (доли 0..1).
  /// 2 петли — верхняя и нижняя; больше — равномерно между ними.
  List<double> _hingePositions(int n) {
    if (n <= 2) return const [0.10, 0.90];
    final out = <double>[];
    for (var i = 0; i < n; i++) {
      out.add(0.10 + 0.80 * i / (n - 1));
    }
    return out;
  }

  void _hardware(Canvas canvas, Rect o, int mode,
      {required bool hingeLeft, int hinges = 2}) {
    if (mode == 0) return; // глухая — без фурнитуры

    final ink = Paint()..color = _ink;
    final n = hinges.clamp(2, 6);

    // ── ПЕТЛИ — ТОЛЬКО ПО СТОРОНЕ (слева или справа), СНИЗУ ПЕТЕЛЬ НЕТ ──
    //    Работает одинаково для П, ПО и О: сторона петель зависит
    //    от направления открывания. Нижних петель не рисуем.
    final hx = hingeLeft ? o.left : o.right - 3;
    for (final t in _hingePositions(n)) {
      canvas.drawRect(
        Rect.fromLTWH(hx, o.top + o.height * t - 5, 3, 10),
        ink,
      );
    }

    // ── РУЧКА ──
    if (mode == 3) {
      // откидная — ручка сверху по центру
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(o.center.dx - 7, o.top + 1.2, 14, 2.6),
          const Radius.circular(1.3),
        ),
        ink,
      );
    } else {
      // поворотная / поворотно-откидная — ручка напротив петель
      final rx = hingeLeft ? o.right - 5.4 : o.left + 1.6;
      canvas.drawRect(Rect.fromLTWH(rx, o.center.dy - 4, 3.8, 8), ink);
      canvas.drawRect(Rect.fromLTWH(rx, o.center.dy - 7.5, 2.2, 15), ink);
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
      !_sameInt(old.hingeCounts, hingeCounts) ||
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