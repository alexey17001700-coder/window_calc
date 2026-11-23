part of '../window_visual.dart';

/// Геометрия обычного чертежа (окно / дверь).
class _Geo {
  _Geo({
    required this.wall,
    required this.opening,
    required this.frame,
    this.sashes = const [],
    this.sill,
    this.ebb,
    this.slopes,
  });

  final Rect wall;
  final Rect opening;
  final Rect frame;
  final List<Rect> sashes;
  final Rect? sill;
  final Rect? ebb;
  final Rect? slopes;
}

/// Доли ширины секций. Пусто или неверное число — делим поровну.
List<double> _normWidths(int n, List<double> widths) {
  if (n <= 0) return const <double>[];
  if (widths.length != n) return List<double>.filled(n, 1 / n);
  final sum = widths.fold<double>(0, (a, b) => a + b);
  if (sum <= 0) return List<double>.filled(n, 1 / n);
  return widths.map((w) => w / sum).toList();
}

/// Прямоугольники секций по долям ширины.
List<Rect> _sashRects(Rect frame, List<double> widths) {
  final out = <Rect>[];
  var x = frame.left;
  for (final w in widths) {
    final rw = frame.width * w;
    out.add(Rect.fromLTWH(x, frame.top, rw, frame.height));
    x += rw;
  }
  return out;
}

/// Контур проёма (для фигурного — с дугой сверху).
Path _openPath(Rect r, bool arched) {
  final p = Path();
  if (!arched) {
    p.addRect(r);
    return p;
  }
  final radius = r.width / 2;
  p.moveTo(r.left, r.bottom);
  p.lineTo(r.left, r.top + radius);
  p.arcToPoint(
    Offset(r.right, r.top + radius),
    radius: Radius.circular(radius),
    clockwise: true,
  );
  p.lineTo(r.right, r.bottom);
  p.close();
  return p;
}

/// Геометрия обычного окна: проём, рама, комплектация.
_Geo _geo(Size size, {required bool arched, required List<String> parts}) {
  final padX = size.width * 0.14;
  final padY = size.height * 0.18;
  final availW = size.width - padX * 2;
  final availH = size.height - padY * 2;

  final hasSill = parts.any((p) => p.contains('ПОДОКОННИК'));
  final hasEbb = parts.any((p) => p.contains('ОТЛИВ'));
  final hasSlopes = parts.any((p) => p.contains('ОТКОС'));

  final bh = availH * ((hasSill || hasEbb) ? 0.86 : 1.0);
  final bw = math.min(availW, bh * (arched ? 0.95 : 1.30));

  final frame = Rect.fromLTWH(
    (size.width - bw) / 2,
    padY + (availH - bh) * 0.35,
    bw,
    bh,
  );

  final opening = frame.inflate(math.max(2.0, bw * 0.02));
  final wall = Rect.fromLTWH(0, 0, size.width, size.height);

  Rect? sill;
  Rect? ebb;
  if (hasSill) {
    sill = Rect.fromLTWH(
      frame.left - bw * 0.06,
      frame.bottom + bh * 0.03,
      bw * 1.12,
      bh * 0.06,
    );
  }
  if (hasEbb) {
    ebb = Rect.fromLTWH(
      frame.left - bw * 0.04,
      frame.bottom + bh * 0.01,
      bw * 1.08,
      bh * 0.045,
    );
  }

  return _Geo(
    wall: wall,
    opening: opening,
    frame: frame,
    sill: sill,
    ebb: ebb,
    slopes: hasSlopes ? opening : null,
  );
}

/// Геометрия балконного блока: дверь + боковая колонна
/// (глухняк сверху, сэндвич-панель снизу).
class _BalconyGeo {
  _BalconyGeo({
    required this.wall,
    required this.opening,
    required this.frame,
    required this.door,
    required this.column,
    required this.fixed,
    required this.panel,
    required this.fixedRight,
  });

  final Rect wall;
  final Rect opening;
  final Rect frame;
  final Rect door;
  final Rect column;
  final Rect fixed;
  final Rect panel;
  final bool fixedRight;
}

_BalconyGeo _balconyGeo(
  Size size, {
  required int doorW,
  required int doorH,
  required int fixedW,
  required int fixedH,
  required bool fixedRight,
}) {
  final totalW = (doorW + fixedW).clamp(1, 100000).toDouble();
  final totalH = doorH.clamp(1, 100000).toDouble();

  final padX = size.width * 0.15;
  final padY = size.height * 0.16;
  final availW = size.width - padX * 2;
  final availH = size.height - padY * 2;

  final k = math.min(availW / totalW, availH / totalH);
  final bw = totalW * k;
  final bh = totalH * k;

  final frame = Rect.fromLTWH(
    (size.width - bw) / 2,
    (size.height - bh) / 2,
    bw,
    bh,
  );

  final wall = Rect.fromLTWH(0, 0, size.width, size.height);
  final opening = frame.inflate(math.max(2.0, bw * 0.02));

  final doorWpx = bw * (doorW / totalW);
  final fixedWpx = bw - doorWpx;

  final Rect door;
  final Rect column;
  if (fixedRight) {
    door = Rect.fromLTWH(frame.left, frame.top, doorWpx, bh);
    column = Rect.fromLTWH(frame.left + doorWpx, frame.top, fixedWpx, bh);
  } else {
    column = Rect.fromLTWH(frame.left, frame.top, fixedWpx, bh);
    door = Rect.fromLTWH(frame.left + fixedWpx, frame.top, doorWpx, bh);
  }

  final fixedHpx = (bh * (fixedH / totalH)).clamp(0.0, bh).toDouble();
  final fixed = Rect.fromLTWH(column.left, column.top, column.width, fixedHpx);
  final panel = Rect.fromLTWH(
    column.left,
    column.top + fixedHpx,
    column.width,
    bh - fixedHpx,
  );

  return _BalconyGeo(
    wall: wall,
    opening: opening,
    frame: frame,
    door: door,
    column: column,
    fixed: fixed,
    panel: panel,
    fixedRight: fixedRight,
  );
}
