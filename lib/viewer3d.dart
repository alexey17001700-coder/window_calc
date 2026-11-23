import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Точка в 3D-пространстве.
class _V3 {
  final double x;
  final double y;
  final double z;

  const _V3(this.x, this.y, this.z);
}

/// Примитив сцены: ломаная или полигон.
class _Prim {
  final List<_V3> pts;
  final Color color;
  final double width;
  final bool fill;
  final bool glow;

  const _Prim(
    this.pts,
    this.color, {
    this.width = 1.2,
    this.fill = false,
    this.glow = false,
  });
}

class _DrawItem {
  final List<_V3> pts;
  final _Prim prim;
  final double depth;

  const _DrawItem(this.pts, this.prim, this.depth);
}

/// 3D-сцена заставки: окно ПВХ, вращается само.
class Viewer3D extends StatefulWidget {
  const Viewer3D({super.key});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  List<_Prim>? _prims;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _prims ??= _buildWindow();
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ScenePainter(_prims!, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Геометрия окна: рама, импост, стеклопакеты, ручка, подоконник.
List<_Prim> _buildWindow() {
  const hw = 0.78;
  const hh = 0.84;
  const t = 0.09;
  const z = -0.06;

  const frame = Color(0xFFEFE0B4);
  const glass = Color(0xFF7FB3D5);
  const metal = Color(0xFFDCE6F2);

  final prims = <_Prim>[];

  void rect(
    double x0,
    double y0,
    double x1,
    double y1,
    Color c, {
    double width = 1.3,
    bool glow = false,
    bool fill = false,
    double zz = z,
  }) {
    prims.add(_Prim(
      [
        _V3(x0, y0, zz),
        _V3(x1, y0, zz),
        _V3(x1, y1, zz),
        _V3(x0, y1, zz),
      ],
      c,
      width: width,
      glow: glow,
      fill: fill,
    ));
  }

  // наружная рама
  rect(-hw, -hh, hw, hh, frame, width: 1.7, glow: true);
  // внутренний контур рамы
  rect(-hw + t, -hh + t, hw - t, hh - t, frame, width: 1.1);
  // импост по центру
  rect(-0.03, -hh + t, 0.03, hh - t, frame, width: 1.1);
  // стеклопакеты
  rect(-hw + t + 0.02, -hh + t + 0.02, -0.05, hh - t - 0.02, glass,
      width: 0.9, fill: true, zz: z + 0.01);
  rect(0.05, -hh + t + 0.02, hw - t - 0.02, hh - t - 0.02, glass,
      width: 0.9, fill: true, zz: z + 0.01);
  // ручка
  rect(hw - t - 0.11, -0.06, hw - t - 0.02, 0.06, metal,
      width: 1.5, glow: true, zz: z - 0.05);
  // подоконник
  rect(-hw - 0.09, -hh - 0.11, hw + 0.09, -hh - 0.02, metal,
      width: 1.2, fill: true, zz: z + 0.02);

  return prims;
}

class _ScenePainter extends CustomPainter {
  final List<_Prim> prims;
  final double t;

  _ScenePainter(this.prims, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.shortestSide * 0.32;

    final ay = t * math.pi * 2;
    const ax = 0.20;
    final cosY = math.cos(ay);
    final sinY = math.sin(ay);
    final cosX = math.cos(ax);
    final sinX = math.sin(ax);

    _V3 rot(_V3 p) {
      final x1 = p.x * cosY - p.z * sinY;
      final z1 = p.x * sinY + p.z * cosY;
      final y1 = p.y * cosX - z1 * sinX;
      final z2 = p.y * sinX + z1 * cosX;
      return _V3(x1, y1, z2);
    }

    Offset proj(_V3 p) {
      const d = 3.4;
      final f = d / (d + p.z);
      return Offset(cx + p.x * scale * f, cy - p.y * scale * f);
    }

    final items = <_DrawItem>[];
    for (final pr in prims) {
      final rp = pr.pts.map(rot).toList();
      var sum = 0.0;
      for (final v in rp) {
        sum += v.z;
      }
      items.add(_DrawItem(rp, pr, sum / rp.length));
    }
    items.sort((a, b) => b.depth.compareTo(a.depth));

    for (final it in items) {
      final pts = it.pts.map(proj).toList();
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      if (it.prim.fill) path.close();

      final fog = (1 - (it.depth + 1.5) / 3.0).clamp(0.40, 1.0).toDouble();
      final col = it.prim.color.withOpacity(fog);

      if (it.prim.fill) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = col.withOpacity(0.30),
        );
      }
      if (it.prim.glow) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = it.prim.width * 3.4
            ..color = col.withOpacity(0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = it.prim.width
          ..color = col
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.t != t || !identical(old.prims, prims);
}
