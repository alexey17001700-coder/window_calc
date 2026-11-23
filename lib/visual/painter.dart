part of '../window_visual.dart';

const _ink = Color(0xFF0E1A2C);
const _dim = Color(0xFF5B6B80);
const _glassTop = Color(0xFFD8EDFC);
const Color _glassBottom = Color(0xFFB6DBF4);
const _glassLine = Color(0xFF7FB3D5);

bool _sameI(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _sameD(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if ((a[i] - b[i]).abs() > 1e-6) return false;
  }
  return true;
}

bool _sameS(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Чертёж по ГОСТ: обычное окно либо балконный блок.
class _GostPainter extends CustomPainter {
  _GostPainter({
    required this.sashCount,
    required this.modes,
    required this.sectionWidths,
    required this.widthMm,
    required this.heightMm,
    required this.arched,
    required this.parts,
    required this.selected,
    required this.balconyBlock,
    required this.doorMode,
    required this.fixedMode,
    required this.doorWidthMm,
    required this.doorHeightMm,
    required this.fixedWidthMm,
    required this.fixedHeightMm,
    required this.fixedRight,
  });

  final int sashCount;
  final List<int> modes;
  final List<double> sectionWidths;
  final int widthMm;
  final int heightMm;
  final bool arched;
  final List<String> parts;
  final int selected;
  final bool balconyBlock;
  final int doorMode;
  final int fixedMode;
  final int doorWidthMm;
  final int doorHeightMm;
  final int fixedWidthMm;
  final int fixedHeightMm;
  final bool fixedRight;

  @override
  void paint(Canvas canvas, Size size) {
    if (balconyBlock) {
      _paintBalcony(canvas, size);
      return;
    }
    _paintWindow(canvas, size);
  }

  // ---------- ОБЫЧНОЕ ОКНО ----------

  void _paintWindow(Canvas canvas, Size size) {
    final geo = _geo(size, arched: arched, parts: parts);
    _wall(canvas, geo.wall, geo.opening);
    _opening(canvas, geo.opening, arched);
    _frame(canvas, geo.frame);
    _axis(canvas, geo.opening);

    final widths = _normWidths(sashCount, sectionWidths);
    final rects = _sashRects(geo.frame, widths);

    for (var i = 0; i < rects.length; i++) {
      _leaf(canvas, rects[i], modes[i], i == 0, i == selected);
    }

    _parts(canvas, geo);
    _dims(canvas, geo, rects, widths);
  }

  // ---------- БАЛКОННЫЙ БЛОК ----------

  void _paintBalcony(Canvas canvas, Size size) {
    final geo = _balconyGeo(
      size,
      doorW: doorWidthMm,
      doorH: doorHeightMm,
      fixedW: fixedWidthMm,
      fixedH: fixedHeightMm,
      fixedRight: fixedRight,
    );

    _wall(canvas, geo.wall, geo.opening);
    _opening(canvas, geo.opening, false);
    _frame(canvas, geo.frame);
    _axis(canvas, geo.opening);

    _leaf(canvas, geo.door, doorMode, true, false);
    _leaf(canvas, geo.fixed, fixedMode, false, false);
    _panel(canvas, geo.panel);

    _balconyDims(canvas, geo);
  }

  // ---------- ОБЩИЕ ЭЛЕМЕНТЫ ----------

  Paint _stroke(double w, [Color c = _ink]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..color = c;

  void _wall(Canvas canvas, Rect wall, Rect opening) {
    canvas.drawRect(wall, Paint()..color = const Color(0xFFF4F7FB));
    final p = _stroke(0.7, const Color(0xFFB9C6D6));
    canvas.save();
    canvas.clipRect(wall);
    canvas.clipRect(opening, clipOp: ClipOp.difference);
    for (var x = -wall.height; x < wall.width; x += 9) {
      canvas.drawLine(
        Offset(x.toDouble(), wall.bottom),
        Offset(x + wall.height, wall.top),
        p,
      );
    }
    canvas.restore();
  }

  void _opening(Canvas canvas, Rect r, bool arched) {
    final path = _openPath(r, arched);
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(path, _stroke(1.1, _ink));
  }

  void _frame(Canvas canvas, Rect r) {
    canvas.drawRect(r, _stroke(1.3, _ink));
    final inner = r.deflate(math.max(2.0, r.width * 0.035));
    canvas.drawRect(inner, _stroke(0.9, _ink));
  }

  void _leaf(Canvas canvas, Rect r, int mode, bool hingeLeft, bool sel) {
    final m = mode.clamp(0, 3);
    final inner = r.deflate(math.max(2.0, r.width * 0.035));

    final glass = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_glassTop, _glassBottom],
      ).createShader(inner);
    canvas.drawRect(inner, glass);
    canvas.drawRect(inner, _stroke(0.9, _glassLine));
    canvas.drawRect(inner.deflate(1.6), _stroke(0.7, _glassLine));

    _openingMark(canvas, inner, m, hingeLeft);
    _hardware(canvas, inner, m, hingeLeft);
    _sashLetter(canvas, inner, m);

    if (sel) {
      canvas.drawRect(r, _stroke(2.0, AppColors.gold));
    }
  }

  void _openingMark(Canvas canvas, Rect r, int mode, bool hingeLeft) {
    if (mode == 0) return;
    final p = _stroke(0.9, _ink);
    final s = math.min(r.width, r.height) * 0.22;

    if (mode == 1 || mode == 2) {
      final path = Path();
      final cy = r.top + s * 0.7;
      if (hingeLeft) {
        path.moveTo(r.left + s * 0.2, cy);
        path.lineTo(r.left + s * 1.2, cy - s * 0.5);
        path.lineTo(r.left + s * 1.2, cy + s * 0.5);
      } else {
        path.moveTo(r.right - s * 0.2, cy);
        path.lineTo(r.right - s * 1.2, cy - s * 0.5);
        path.lineTo(r.right - s * 1.2, cy + s * 0.5);
      }
      path.close();
      canvas.drawPath(path, p);
    }

    if (mode == 2 || mode == 3) {
      final path = Path();
      final bx = r.center.dx;
      final by = r.bottom - s * 0.2;
      path.moveTo(bx - s * 0.5, by - s);
      path.lineTo(bx + s * 0.5, by - s);
      path.lineTo(bx, by);
      path.close();
      canvas.drawPath(path, p);
    }
  }

  void _hardware(Canvas canvas, Rect r, int mode, bool hingeLeft) {
    if (mode == 0) return;
    final metal = Paint()..color = const Color(0xFF8FA3BC);
    final dark = Paint()..color = const Color(0xFF3B4A5E);

    final hx = hingeLeft ? r.left + 1.5 : r.right - 1.5;
    final hinges = mode == 3 ? <double>[0.86, 0.94] : <double>[0.15, 0.50, 0.85];
    for (final f in hinges) {
      final y = r.top + r.height * f;
      canvas.drawRect(Rect.fromLTWH(hx - 1.5, y - 3, 3, 6), dark);
    }
    if (mode == 2) {
      canvas.drawRect(Rect.fromLTWH(r.center.dx - 3, r.bottom - 3, 6, 3), dark);
    }

    if (mode == 3) {
      canvas.drawRect(
        Rect.fromLTWH(r.left + r.width * 0.2, r.top + 2, r.width * 0.6, 3),
        metal,
      );
    } else {
      final rx = hingeLeft ? r.right - 5 : r.left + 2;
      final ry = r.top + r.height * 0.45;
      canvas.drawRect(Rect.fromLTWH(rx, ry, 3, 12), metal);
      canvas.drawRect(Rect.fromLTWH(rx - 1.5, ry + 10, 6, 3), metal);
    }
  }

  void _sashLetter(Canvas canvas, Rect r, int mode) {
    final tp = TextPainter(
      text: TextSpan(
        text: kSashModeLetter[mode],
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final box = Rect.fromLTWH(r.left + 4, r.top + 4, tp.width + 8, tp.height + 4);
    canvas.drawRect(box, Paint()..color = Colors.white);
    canvas.drawRect(box, _stroke(0.8, _ink));
    tp.paint(canvas, Offset(box.left + 4, box.top + 2));
  }

  void _panel(Canvas canvas, Rect r) {
    if (r.height <= 1) return;
    final inner = r.deflate(math.max(2.0, r.width * 0.035));
    canvas.drawRect(inner, Paint()..color = Colors.white);
    canvas.drawRect(inner, _stroke(0.9, _ink));

    final p = _stroke(0.6, const Color(0xFFE3E9F0));
    canvas.save();
    canvas.clipRect(inner);
    for (var x = inner.left - inner.height; x < inner.right; x += 7) {
      canvas.drawLine(
        Offset(x, inner.bottom),
        Offset(x + inner.height, inner.top),
        p,
      );
    }
    canvas.restore();

    final tp = TextPainter(
      text: const TextSpan(
        text: 'СЭНДВИЧ',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: _dim,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(inner.center.dx - tp.width / 2, inner.center.dy - tp.height / 2),
    );
  }

  void _parts(Canvas canvas, _Geo geo) {
    if (geo.slopes != null) {
      final p = _stroke(0.9, _ink);
      final w = geo.opening.width * 0.06;
      canvas.drawLine(
        geo.opening.topLeft,
        geo.opening.topLeft.translate(-w, 0),
        p,
      );
      canvas.drawLine(
        geo.opening.bottomLeft,
        geo.opening.bottomLeft.translate(-w, 0),
        p,
      );
    }
    if (geo.ebb != null) {
      canvas.drawRect(geo.ebb!, Paint()..color = const Color(0xFFD7DEE8));
      canvas.drawRect(geo.ebb!, _stroke(0.9, _ink));
    }
    if (geo.sill != null) {
      canvas.drawRect(geo.sill!, Paint()..color = const Color(0xFFEFE3C4));
      canvas.drawRect(geo.sill!, _stroke(0.9, _ink));
    }
  }

  // ---------- ОСЕВЫЕ ЛИНИИ ----------

  void _axis(Canvas canvas, Rect r) {
    final p = _stroke(0.8, _dim);
    _dashDot(
      canvas,
      Offset(r.center.dx, r.top - 18),
      Offset(r.center.dx, r.bottom + 18),
      p,
    );
    _dashDot(
      canvas,
      Offset(r.left - 18, r.center.dy),
      Offset(r.right + 18, r.center.dy),
      p,
    );
  }

  void _dashDot(Canvas canvas, Offset a, Offset b, Paint p) {
    const dash = 9.0;
    const dot = 1.6;
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    var t = 0.0;
    while (t < total) {
      final e = math.min(t + dash, total);
      canvas.drawLine(a + dir * t, a + dir * e, p);
      t = e + 4;
      if (t < total) {
        canvas.drawLine(a + dir * t, a + dir * (t + dot), p);
        t += dot + 4;
      }
    }
  }

  // ---------- РАЗМЕРНЫЕ ЛИНИИ ----------

  void _dims(Canvas canvas, _Geo geo, List<Rect> rects, List<double> widths) {
    final r = geo.opening;
    final below = (geo.sill != null || geo.ebb != null) ? 30.0 : 17.0;

    _dimH(canvas, r.left, r.right, r.top - 16, widthMm > 0 ? '$widthMm' : '?');
    _dimV(canvas, r.top, r.bottom, r.left - 16, heightMm > 0 ? '$heightMm' : '?');

    for (var i = 0; i < rects.length; i++) {
      final mm = widthMm > 0 ? (widthMm * widths[i]).round() : 0;
      _dimH(
        canvas,
        rects[i].left,
        rects[i].right,
        r.bottom + below,
        mm > 0 ? '$mm' : '?',
        small: true,
      );
    }

    final inner = geo.frame.deflate(math.max(2.0, geo.frame.width * 0.035));
    final gh = heightMm > 0
        ? (heightMm * (inner.height / geo.frame.height)).round()
        : 0;
    _dimV(
      canvas,
      inner.top,
      inner.bottom,
      r.right + 16,
      gh > 0 ? '$gh' : '?',
      small: true,
      right: true,
    );
  }

  void _balconyDims(Canvas canvas, _BalconyGeo geo) {
    final r = geo.opening;

    _dimH(canvas, r.left, r.right, r.top - 16, '${doorWidthMm + fixedWidthMm}');

    _dimH(
      canvas,
      geo.door.left,
      geo.door.right,
      r.bottom + 18,
      '$doorWidthMm',
      small: true,
    );
    _dimH(
      canvas,
      geo.fixed.left,
      geo.fixed.right,
      r.bottom + 18,
      '$fixedWidthMm',
      small: true,
    );

    _dimV(canvas, geo.door.top, geo.door.bottom, r.left - 16, '$doorHeightMm');
    _dimV(
      canvas,
      geo.fixed.top,
      geo.fixed.bottom,
      r.right + 16,
      '$fixedHeightMm',
      small: true,
      right: true,
    );

    final panelH = doorHeightMm - fixedHeightMm;
    if (panelH > 0) {
      _dimV(
        canvas,
        geo.panel.top,
        geo.panel.bottom,
        r.right + 16,
        '$panelH',
        small: true,
        right: true,
      );
    }

    _caption(canvas, geo.door, 'ДВЕРЬ');
    _caption(canvas, geo.fixed, 'ГЛУХНЯК');
  }

  void _caption(Canvas canvas, Rect r, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: _dim,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(r.center.dx - tp.width / 2, r.bottom + 30),
    );
  }

  void _dimH(
    Canvas canvas,
    double x1,
    double x2,
    double y,
    String label, {
    bool small = false,
  }) {
    final p = _stroke(0.8, _dim);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), p);
    _tick(canvas, Offset(x1, y), true);
    _tick(canvas, Offset(x2, y), true);
    _label(canvas, Offset((x1 + x2) / 2, y - 8), label, small);
  }

  void _dimV(
    Canvas canvas,
    double y1,
    double y2,
    double x,
    String label, {
    bool small = false,
    bool right = false,
  }) {
    final p = _stroke(0.8, _dim);
    canvas.drawLine(Offset(x, y1), Offset(x, y2), p);
    _tick(canvas, Offset(x, y1), false);
    _tick(canvas, Offset(x, y2), false);
    _label(canvas, Offset(x + (right ? 14 : -14), (y1 + y2) / 2), label, small);
  }

  void _tick(Canvas canvas, Offset at, bool horizontal) {
    final p = _stroke(0.8, _dim);
    if (horizontal) {
      canvas.drawLine(at.translate(0, -3), at.translate(0, 3), p);
    } else {
      canvas.drawLine(at.translate(-3, 0), at.translate(3, 0), p);
    }
  }

  void _label(Canvas canvas, Offset at, String text, bool small) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: small ? 7.5 : 9.5,
          fontWeight: FontWeight.w700,
          color: _dim,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(at.dx - tp.width / 2, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GostPainter old) {
    return old.sashCount != sashCount ||
        old.selected != selected ||
        old.arched != arched ||
        old.balconyBlock != balconyBlock ||
        old.doorMode != doorMode ||
        old.fixedMode != fixedMode ||
        old.doorWidthMm != doorWidthMm ||
        old.doorHeightMm != doorHeightMm ||
        old.fixedWidthMm != fixedWidthMm ||
        old.fixedHeightMm != fixedHeightMm ||
        old.fixedRight != fixedRight ||
        old.widthMm != widthMm ||
        old.heightMm != heightMm ||
        !_sameI(old.modes, modes) ||
        !_sameD(old.sectionWidths, sectionWidths) ||
        !_sameS(old.parts, parts);
  }
}
