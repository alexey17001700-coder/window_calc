import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Собственный программный 3D-рендерер: векторы, матрицы поворота,
// перспективная проекция, отрисовка методом художника (сортировка по глубине).
// Без WebView, WebGL и внешних пакетов — сборка APK остаётся стабильной.
// ─────────────────────────────────────────────────────────────────────────────

class _V3 {
  final double x, y, z;
  const _V3(this.x, this.y, this.z);

  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);

  double get len => math.sqrt(x * x + y * y + z * z);

  _V3 get norm {
    final l = len;
    return l == 0 ? const _V3(0, 0, 0) : _V3(x / l, y / l, z / l);
  }

  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
}

class _Prim {
  final List<_V3> pts;
  final Color color;
  final double alpha;
  final bool fill;
  final double width;
  final bool glow;

  const _Prim(
    this.pts,
    this.color, {
    this.alpha = 1.0,
    this.fill = true,
    this.width = 1.0,
    this.glow = false,
  });
}

/// Параллелепипед из 6 граней.
List<_Prim> _box(
  _V3 c,
  _V3 s,
  Color col, {
  double alpha = 1.0,
  bool fill = true,
  double width = 1.0,
  bool glow = false,
}) {
  final hx = s.x / 2, hy = s.y / 2, hz = s.z / 2;
  _V3 p(int x, int y, int z) => _V3(c.x + x * hx, c.y + y * hy, c.z + z * hz);
  final v = <_V3>[
    p(-1, -1, -1), p(1, -1, -1), p(1, 1, -1), p(-1, 1, -1),
    p(-1, -1, 1), p(1, -1, 1), p(1, 1, 1), p(-1, 1, 1),
  ];
  final faces = <List<_V3>>[
    [v[0], v[1], v[2], v[3]],
    [v[5], v[4], v[7], v[6]],
    [v[4], v[0], v[3], v[7]],
    [v[1], v[5], v[6], v[2]],
    [v[3], v[2], v[6], v[7]],
    [v[4], v[5], v[1], v[0]],
  ];
  return faces
      .map((f) => _Prim(f, col, alpha: alpha, fill: fill, width: width, glow: glow))
      .toList();
}

List<_Prim> _scale(List<_Prim> src, double k) => src
    .map((p) => _Prim(
          p.pts.map((v) => v * k).toList(),
          p.color,
          alpha: p.alpha,
          fill: p.fill,
          width: p.width,
          glow: p.glow,
        ))
    .toList();

// ── Модель окна ──────────────────────────────────────────────────────────────

const _kWinScale = 0.60;

List<_Prim> _windowPrims() {
  final out = <_Prim>[];
  const hw = 0.78, hh = 0.84, d = 0.10;
  const frame = Color(0xFFE9EEF5);
  const frameDark = Color(0xFFB9C4D2);
  const glass = Color(0xFFB6DBF4);
  const gold = Color(0xFFC9A227);
  const metal = Color(0xFF8E9AA8);

  // рама — четыре бруса
  out.addAll(_box(const _V3(-(hw - 0.06), 0, 0), const _V3(0.12, hh * 2, d), frame));
  out.addAll(_box(const _V3(hw - 0.06, 0, 0), const _V3(0.12, hh * 2, d), frame));
  out.addAll(_box(const _V3(0, hh - 0.06, 0), const _V3(hw * 2, 0.12, d), frame));
  out.addAll(_box(const _V3(0, -(hh - 0.06), 0), const _V3(hw * 2, 0.12, d), frame));

  // центральный импост
  out.addAll(_box(const _V3(0, 0, 0), const _V3(0.09, hh * 2 - 0.24, d), frameDark));

  // стеклопакеты (лицо смотрит в −Z)
  out.addAll(_box(const _V3(-(hw / 2 - 0.02), 0, 0.015),
      const _V3(hw - 0.20, hh * 2 - 0.26, 0.02), glass, alpha: 0.40));
  out.addAll(_box(const _V3(hw / 2 - 0.02, 0, 0.015),
      const _V3(hw - 0.20, hh * 2 - 0.26, 0.02), glass, alpha: 0.40));

  // ручка
  out.addAll(_box(const _V3(-0.075, -0.06, -0.085), const _V3(0.05, 0.22, 0.05), gold, glow: true));

  // петли
  out.addAll(_box(const _V3(-(hw - 0.06), hh * 0.62, -0.075), const _V3(0.07, 0.10, 0.05), metal));
  out.addAll(_box(const _V3(-(hw - 0.06), -hh * 0.62, -0.075), const _V3(0.07, 0.10, 0.05), metal));

  // подоконник + отлив
  out.addAll(_box(const _V3(0, -(hh + 0.045), -0.10), const _V3(hw * 2 + 0.16, 0.05, 0.34), frame));
  out.addAll(_box(const _V3(0, -(hh + 0.09), -0.16), const _V3(hw * 2 + 0.10, 0.03, 0.26), metal));

  return _scale(out, _kWinScale);
}

// ── Инструменты ──────────────────────────────────────────────────────────────

List<_Prim> _tape() {
  final out = <_Prim>[];
  const body = Color(0xFFE8B10A);
  const dark = Color(0xFF1A1A1A);
  const steel = Color(0xFFC8D2DC);
  out.addAll(_box(const _V3(0, 0, 0), const _V3(0.26, 0.26, 0.12), body));
  out.addAll(_box(const _V3(0, -0.11, 0), const _V3(0.26, 0.05, 0.12), dark));
  out.addAll(_box(const _V3(0, 0.11, 0), const _V3(0.26, 0.05, 0.12), dark));
  out.addAll(_box(const _V3(0.30, 0, 0), const _V3(0.36, 0.07, 0.03), steel));
  return out;
}

List<_Prim> _level() {
  final out = <_Prim>[];
  const alu = Color(0xFFD5DCE4);
  const dark = Color(0xFF6E7A88);
  const liquid = Color(0xFF2FA84F);
  out.addAll(_box(const _V3(0, 0, 0), const _V3(0.62, 0.10, 0.07), alu));
  out.addAll(_box(const _V3(0, -0.05, 0), const _V3(0.62, 0.02, 0.07), dark));
  out.addAll(_box(const _V3(0, 0, -0.04), const _V3(0.16, 0.05, 0.02), liquid, glow: true));
  out.addAll(_box(const _V3(-0.22, 0, -0.04), const _V3(0.09, 0.05, 0.02), liquid, glow: true));
  out.addAll(_box(const _V3(0.22, 0, -0.04), const _V3(0.09, 0.05, 0.02), liquid, glow: true));
  return out;
}

List<_Prim> _pencil() {
  final out = <_Prim>[];
  const body = Color(0xFFE8B10A);
  const wood = Color(0xFFD9B98A);
  const graphite = Color(0xFF2B2B2B);
  const metal = Color(0xFFB9C4D2);
  const eraser = Color(0xFFE86A8A);
  out.addAll(_box(const _V3(0, 0, 0), const _V3(0.10, 0.52, 0.10), body));
  out.addAll(_box(const _V3(0, -0.30, 0), const _V3(0.08, 0.10, 0.08), wood));
  out.addAll(_box(const _V3(0, -0.37, 0), const _V3(0.04, 0.06, 0.04), graphite));
  out.addAll(_box(const _V3(0, 0.29, 0), const _V3(0.11, 0.05, 0.11), metal));
  out.addAll(_box(const _V3(0, 0.35, 0), const _V3(0.10, 0.08, 0.10), eraser));
  return out;
}

/// Своя орбита у каждого инструмента: три независимых наклона (X · Y · Z).
List<_Prim> _place(List<_Prim> local, _V3 pos, double rx, double ry, double rz) {
  final cx = math.cos(rx), sx = math.sin(rx);
  final cy = math.cos(ry), sy = math.sin(ry);
  final cz = math.cos(rz), sz = math.sin(rz);

  _V3 f(_V3 p) {
    var x = p.x, y = p.y, z = p.z;
    final y1 = y * cx - z * sx;
    final z1 = y * sx + z * cx;
    y = y1;
    z = z1;
    final x2 = x * cy + z * sy;
    final z2 = -x * sy + z * cy;
    x = x2;
    z = z2;
    final x3 = x * cz - y * sz;
    final y3 = x * sz + y * cz;
    x = x3;
    y = y3;
    return _V3(x + pos.x, y + pos.y, z + pos.z);
  }

  return local
      .map((p) => _Prim(
            p.pts.map(f).toList(),
            p.color,
            alpha: p.alpha,
            fill: p.fill,
            width: p.width,
            glow: p.glow,
          ))
      .toList();
}

List<_Prim> _instrumentPrims(double t) {
  final out = <_Prim>[];
  final a = t * math.pi * 2;

  final p1 = _V3(math.cos(a) * 1.30, math.sin(a) * 0.62, math.sin(a) * 0.85);
  out.addAll(_place(_tape(), p1, 0.55, 0, 0.25));

  final b = a + 2.1;
  final p2 = _V3(math.cos(b) * 1.42, math.sin(b) * 0.70, math.sin(b) * 0.95);
  out.addAll(_place(_level(), p2, -0.45, 0.90, 0.75));

  final c = a + 4.2;
  final p3 = _V3(math.cos(c) * 1.36, math.sin(c) * 0.66, math.sin(c) * 0.90);
  out.addAll(_place(_pencil(), p3, 0.85, -0.70, -0.35));

  return out;
}

// ── Отрисовка ────────────────────────────────────────────────────────────────

class _Draw {
  final List<_V3> pts;
  final _Prim prim;
  final double depth;
  final double lum;

  const _Draw(this.pts, this.prim, this.depth, this.lum);
}

Color _shade(Color c, double l) {
  final r = (c.red * l).clamp(0, 255).round();
  final g = (c.green * l).clamp(0, 255).round();
  final b = (c.blue * l).clamp(0, 255).round();
  return Color.fromARGB(c.alpha, r, g, b);
}

class _ScenePainter extends CustomPainter {
  final double t;
  final List<_Prim> windowPrims;

  const _ScenePainter(this.t, this.windowPrims);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final focal = size.shortestSide * 0.95;
    const camZ = -2.9;

    final ang = t * math.pi * 2;
    const tiltX = -0.22;
    final cosY = math.cos(ang), sinY = math.sin(ang);
    final cosX = math.cos(tiltX), sinX = math.sin(tiltX);

    _V3 rot(_V3 p) {
      final x1 = p.x * cosY + p.z * sinY;
      final z1 = -p.x * sinY + p.z * cosY;
      final y2 = p.y * cosX - z1 * sinX;
      final z2 = p.y * sinX + z1 * cosX;
      return _V3(x1, y2, z2);
    }

    final light = const _V3(-0.4, 0.7, -0.6).norm;
    final all = <_Prim>[...windowPrims, ..._instrumentPrims(t)];

    final items = <_Draw>[];
    for (final pr in all) {
      final rp = pr.pts.map(rot).toList();
      var depth = 0.0;
      for (final p in rp) {
        depth += p.z;
      }
      depth /= rp.length;
      final n = (rp[1] - rp[0]).cross(rp[2] - rp[0]).norm;
      final lum = 0.45 + 0.55 * n.dot(light).abs();
      items.add(_Draw(rp, pr, depth, lum));
    }
    items.sort((a, b) => b.depth.compareTo(a.depth));

    for (final it in items) {
      final path = Path();
      var started = false;
      for (final p in it.pts) {
        final dz = p.z - camZ;
        if (dz <= 0.05) continue;
        final s = focal / dz;
        final sx = cx + p.x * s;
        final sy = cy - p.y * s;
        if (!started) {
          path.moveTo(sx, sy);
          started = true;
        } else {
          path.lineTo(sx, sy);
        }
      }
      if (!started) continue;
      path.close();

      final col = _shade(it.prim.color, it.lum);

      if (it.prim.glow) {
        canvas.drawPath(
          path,
          Paint()
            ..color = col.withOpacity(0.30 * it.prim.alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      if (it.prim.fill) {
        canvas.drawPath(
          path,
          Paint()
            ..color = col.withOpacity(it.prim.alpha)
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = col.withOpacity(math.min(1.0, it.prim.alpha + 0.25))
          ..style = PaintingStyle.stroke
          ..strokeWidth = it.prim.width,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t;
}

/// Заставка: окно вращается само, инструменты летают по своим орбитам.
class Viewer3D extends StatefulWidget {
  const Viewer3D({super.key});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Prim> _prims;

  @override
  void initState() {
    super.initState();
    _prims = _windowPrims();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 26))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _ScenePainter(_c.value, _prims),
          size: Size.infinite,
        ),
      ),
    );
  }
}
