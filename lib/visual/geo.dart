part of '../window_visual.dart';

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

/// ═══════════════════════════════════════════════════════════════════
///  ГЕОМЕТРИЯ БАЛКОННОГО БЛОКА
///  Дверь слева (на всю высоту) + боковая колонна справа:
///  сверху — глухой стеклопакет, снизу — сэндвич-панель.
/// ═══════════════════════════════════════════════════════════════════
class _BalconyGeo {
  const _BalconyGeo({
    required this.wall,
    required this.opening,
    required this.frameOuter,
    required this.door,
    required this.side,
    required this.fixed,
    required this.panel,
  });

  final Rect wall;
  final Rect opening;
  final Rect frameOuter;

  /// Створка ДВЕРИ — на всю высоту блока.
  final Rect door;

  /// Боковая колонна целиком (глухняк + панель).
  final Rect side;

  /// Глухой стеклопакет сверху колонны.
  final Rect fixed;

  /// Сэндвич-панель снизу колонны.
  final Rect panel;
}

/// doorFrac — доля ширины двери от общей ширины блока,
/// fixedFrac — доля высоты глухняка от высоты блока.
_BalconyGeo _balconyGeo(Size s, double doorFrac, double fixedFrac) {
  final wall = Rect.fromLTWH(
    44,
    30,
    math.max(20, s.width - 62),
    math.max(20, s.height - 70),
  );
  final opening = wall.deflate(11);
  final frameOuter = opening.deflate(5);
  final inner = frameOuter.deflate(4.5);
  final dw = doorFrac.clamp(0.25, 0.75);
  final door = Rect.fromLTWH(
    inner.left,
    inner.top,
    inner.width * dw,
    inner.height,
  );
  final side = Rect.fromLTWH(
    door.right,
    inner.top,
    inner.width * (1 - dw),
    inner.height,
  );
  final fh = fixedFrac.clamp(0.10, 0.90);
  final fixed = Rect.fromLTWH(
    side.left,
    side.top,
    side.width,
    inner.height * fh,
  );
  final panel = Rect.fromLTWH(
    side.left,
    fixed.bottom,
    side.width,
    inner.height * (1 - fh),
  );
  return _BalconyGeo(
    wall: wall,
    opening: opening,
    frameOuter: frameOuter,
    door: door,
    side: side,
    fixed: fixed,
    panel: panel,
  );
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