import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Лёгкий программный 3D-рендерер.
///
/// Не использует WebView, WebGL и внешние пакеты — только математика
/// и CustomPainter. Работает офлайн, не требует разрешений и не тянет
/// за собой тяжёлые зависимости, поэтому сборка APK остаётся стабильной.
///
/// Модель — стилизованное окно с импостом и подоконником, собранное
/// из параллелепипедов. Рисуется методом художника (сортировка по глубине).

class _V3 {
  final double x, y, z;
  const _V3(this.x, this.y, this.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;
  _V3 cross(_V3 o) => _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get len => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = len;
    return l == 0 ? const _V3(0, 0, 0) : _V3(x / l, y / l, z / l);
  }
}

class _Face {
  final List<_V3> pts;
  final Color color;
  final bool glass;
  _Face(this.pts, this.color, {this.glass = false});
}

class _DrawFace {
  final List<Offset> pts;
  final Color color;
  final double depth;
  final bool glass;
  _DrawFace(this.pts, this.color, this.depth, this.glass);
}

/// Палитра премиального интерфейса.
const _gold = Color(0xFFC9A227);
const _goldDeep = Color(0xFF8A6E14);
const _glassCol = Color(0xFF7FC4E8);

List<_Face> _buildModel() {
  final faces = <_Face>[];

  void box(double cx, double cy, double cz, double sx, double sy, double sz, Color c) {
    final x0 = cx - sx / 2, x1 = cx + sx / 2;
    final y0 = cy - sy / 2, y1 = cy + sy / 2;
    final z0 = cz - sz / 2, z1 = cz + sz / 2;
    _V3 v(double x, double y, double z) => _V3(x, y, z);
    faces.add(_Face([v(x0, y0, z1), v(x1, y0, z1), v(x1, y1, z1), v(x0, y1, z1)], c));
    faces.add(_Face([v(x1, y0, z0), v(x0, y0, z0), v(x0, y1, z0), v(x1, y1, z0)], c));
    faces.add(_Face([v(x0, y0, z0), v(x1, y0, z0), v(x1, y0, z1), v(x0, y0, z1)], c));
    faces.add(_Face([v(x0, y1, z1), v(x1, y1, z1), v(x1, y1, z0), v(x0, y1, z0)], c));
    faces.add(_Face([v(x0, y0, z0), v(x0, y0, z1), v(x0, y1, z1), v(x0, y1, z0)], c));
    faces.add(_Face([v(x1, y0, z1), v(x1, y0, z0), v(x1, y1, z0), v(x1, y1, z1)], c));
  }

  void pane(double x0, double x1, double y0, double y1) {
    const z = 0.02;
    faces.add(_Face([
      _V3(x0, y0, z),
      _V3(x1, y0, z),
      _V3(x1, y1, z),
      _V3(x0, y1, z),
    ], _glassCol, glass: true));
  }

  // Рама: стойки и обвязки
  box(-1.23, 0, 0, 0.14, 2.9, 0.34, _gold);
  box(1.23, 0, 0, 0.14, 2.9, 0.34, _gold);
  box(0, 1.38, 0, 2.6, 0.14, 0.34, _gold);
  box(0, -1.38, 0, 2.6, 0.14, 0.34, _gold);

  // Импосты
  box(0, 0, 0, 0.11, 2.62, 0.30, _goldDeep);
  box(0, 0.45, 0, 2.36, 0.11, 0.30, _goldDeep);

  // Подоконник
  box(0, -1.52, 0.06, 3.0, 0.12, 0.62, _goldDeep);

  // Стеклопакеты
  pane(-1.16, -0.055, 0.505, 1.31);
  pane(-1.16, -0.055, -1.31, 0.395);
  pane(0.055, 1.16, 0.505, 1.31);
  pane(0.055, 1.16, -1.31, 0.395);

  return faces;
}

Color _shade(Color c, double k) => Color.fromARGB(
      c.alpha,
      (c.red * k).clamp(0, 255).round(),
      (c.green * k).clamp(0, 255).round(),
      (c.blue * k).clamp(0, 255).round(),
    );

class _Scene3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final List<_Face> faces;
  _Scene3DPainter(this.yaw, this.pitch, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    const camZ = -7.2;
    final f = size.shortestSide * 1.05;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final light = const _V3(0.45, 0.78, 0.44).unit;

    final cyw = math.cos(yaw), syw = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);

    _V3 rot(_V3 p) {
      final x1 = p.x * cyw + p.z * syw;
      final z1 = -p.x * syw + p.z * cyw;
      final y1 = p.y * cp - z1 * sp;
      final z2 = p.y * sp + z1 * cp;
      return _V3(x1, y1, z2);
    }

    Offset proj(_V3 p) {
      final d = p.z - camZ;
      final s = f / (d <= 0.2 ? 0.2 : d);
      return Offset(cx + p.x * s, cy - p.y * s);
    }

    final items = <_DrawFace>[];
    for (final fc in faces) {
      final rp = fc.pts.map(rot).toList();
      final c = _V3(
        rp.fold<double>(0, (a, p) => a + p.x) / rp.length,
        rp.fold<double>(0, (a, p) => a + p.y) / rp.length,
        rp.fold<double>(0, (a, p) => a + p.z) / rp.length,
      );
      final n = (rp[1] - rp[0]).cross(rp[2] - rp[0]).unit;
      final k = 0.34 + 0.66 * n.dot(light).abs();
      items.add(_DrawFace(
        rp.map(proj).toList(),
        _shade(fc.color, k),
        c.z - camZ,
        fc.glass,
      ));
    }

    items.sort((a, b) => b.depth.compareTo(a.depth));

    for (final it in items) {
      final path = Path()..moveTo(it.pts[0].dx, it.pts[0].dy);
      for (var i = 1; i < it.pts.length; i++) {
        path.lineTo(it.pts[i].dx, it.pts[i].dy);
      }
      path.close();

      if (it.glass) {
        canvas.drawPath(
          path,
          Paint()
            ..color = it.color.withOpacity(0.30)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFBFE6FA).withOpacity(0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1,
        );
      } else {
        canvas.drawPath(path, Paint()..color = it.color..style = PaintingStyle.fill);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0x33000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Scene3DPainter old) =>
      old.yaw != yaw || old.pitch != pitch;
}

/// Виджет 3D-просмотра окна: авто-вращение + поворот пальцем.
class Viewer3D extends StatefulWidget {
  const Viewer3D({super.key});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Face> _faces;
  double _dragYaw = 0;
  double _dragPitch = 0;

  @override
  void initState() {
    super.initState();
    _faces = _buildModel();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) {
        setState(() {
          _dragYaw += d.delta.dx * 0.011;
          _dragPitch = (_dragPitch - d.delta.dy * 0.008).clamp(-0.75, 0.75);
        });
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final auto = math.sin(_c.value * math.pi * 2) * 0.55;
          return CustomPaint(
            painter: _Scene3DPainter(-0.5 + _dragYaw + auto, 0.20 + _dragPitch, _faces),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}
