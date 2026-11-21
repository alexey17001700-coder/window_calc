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