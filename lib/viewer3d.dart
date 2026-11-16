import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Лёгкий программный 3D-рендерер премиального окна.
///
/// Без WebView, WebGL и внешних пакетов — только математика и CustomPainter.
/// Работает офлайн, не требует разрешений, сборка APK остаётся стабильной.
///
/// Модель: рама с фаской, импост, створки с обвязками, стеклопакеты с бликом,
/// петли, золотая ручка, подоконник с капельником.
/// Поверх 3D — парящие инструменты и размерные линии (чертёжный слой).

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
  final bool glint;
  _Face(this.pts, this.color, {this.glass = false, this.glint = false});
}

class _DrawFace {
  final List<Offset> pts;
  final Color color;
  final double depth;
  final bool glass;
  final bool glint;
  _DrawFace(this.pts, this.color, this.depth, this.glass, this.glint);
}

// ─── Палитра ────────────────────────────────────────────────────────────────
const _gold = Color(0xFFC9A227);
const _goldLight = Color(0xFFE3C55A);
const _goldDeep = Color(0xFF8A6E14);
const _goldSash = Color(0xFFB08D2A);
const _metal = Color(0xFF2B3038);
const _metalLight = Color(0xFF4A525E);
const _glassCol = Color(0xFF7FC4E8);

// ─── Габариты модели ────────────────────────────────────────────────────────
const _W = 1.30; // полуширина окна
const _H = 1.45; // полувысота окна
const _FW = 0.15; // толщина профиля рамы
const _FD = 0.36; // глубина рамы
const _ST = 0.075; // толщина обвязки створки
const _SD = 0.30; // глубина створки

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

  /// Диагональный блик на стеклопакете.
  void glint(double x0, double x1, double y0, double y1) {
    final w = x1 - x0, h = y1 - y0;
    if (w < 0.22 || h < 0.22) return;
    const z = 0.035;
    final xa = x0 + w * 0.14, xb = x0 + w * 0.34;
    faces.add(_Face([
      _V3(xa, y0 + h * 0.06, z),
      _V3(xb, y0 + h * 0.06, z),
      _V3(xb + w * 0.26, y1 - h * 0.06, z),
      _V3(xa + w * 0.26, y1 - h * 0.06, z),
    ], const Color(0xFFFFFFFF), glint: true));
  }

  // ── Рама ──────────────────────────────────────────────────────────────
  box(-_W + _FW / 2, 0, 0, _FW, _H * 2, _FD, _gold);
  box(_W - _FW / 2, 0, 0, _FW, _H * 2, _FD, _gold);
  box(0, _H - _FW / 2, 0, _W * 2 - _FW * 2, _FW, _FD, _gold);
  box(0, -_H + _FW / 2, 0, _W * 2 - _FW * 2, _FW, _FD, _gold);

  // ── Фаска (внутренний контур рамы) ────────────────────────────────────
  const lip = 0.05;
  const lipD = _FD - 0.12;
  box(-_W + _FW + lip / 2, 0, 0.03, lip, _H * 2 - _FW * 2, lipD, _goldLight);
  box(_W - _FW - lip / 2, 0, 0.03, lip, _H * 2 - _FW * 2, lipD, _goldLight);
  box(0, _H - _FW - lip / 2, 0.03, _W * 2 - _FW * 2, lip, lipD, _goldLight);
  box(0, -_H + _FW + lip / 2, 0.03, _W * 2 - _FW * 2, lip, lipD, _goldLight);

  // ── Импосты ───────────────────────────────────────────────────────────
  box(0, 0.02, 0, 0.11, _H * 2 - _FW * 2, 0.32, _goldDeep);
  box(0, 0.45, 0, _W * 2 - _FW * 2, 0.11, 0.32, _goldDeep);

  // ── Створки ───────────────────────────────────────────────────────────
  final lx0 = -_W + _FW, lx1 = -0.055;
  final rx0 = 0.055, rx1 = _W - _FW;
  final uy0 = 0.505, uy1 = _H - _FW;
  final ly0 = -_H + _FW, ly1 = 0.395;

  void sash(double x0, double x1, double y0, double y1, {bool handle = false}) {
    // обвязки створки
    box((x0 + x1) / 2, y1 - _ST / 2, 0.03, x1 - x0, _ST, _SD, _goldSash);
    box((x0 + x1) / 2, y0 + _ST / 2, 0.03, x1 - x0, _ST, _SD, _goldSash);
    box(x0 + _ST / 2, (y0 + y1) / 2, 0.03, _ST, y1 - y0, _SD, _goldSash);
    box(x1 - _ST / 2, (y0 + y1) / 2, 0.03, _ST, y1 - y0, _SD, _goldSash);

    // стеклопакет + блик
    pane(x0 + _ST, x1 - _ST, y0 + _ST, y1 - _ST);
    glint(x0 + _ST, x1 - _ST, y0 + _ST, y1 - _ST);

    // петли (тёмный металл) — на левой стороне створки
    final hx = x0 + _ST / 2;
    for (final k in const [0.10, 0.90]) {
      final hy = y0 + (y1 - y0) * k;
      box(hx, hy, 0.20, 0.055, 0.20, 0.055, _metal);
      box(hx, hy, 0.235, 0.03, 0.13, 0.03, _metalLight);
    }

    // ручка (золото/бронза) — на правой стороне створки
    if (handle) {
      final mx = x1 - _ST / 2;
      final my = (y0 + y1) / 2;
      box(mx, my, 0.205, 0.075, 0.26, 0.05, _goldDeep); // площадка
      box(mx, my, 0.30, 0.05, 0.07, 0.17, _gold); // рычаг
      box(mx, my + 0.09, 0.30, 0.045, 0.05, 0.13, _goldLight); // упор
    }
  }

  sash(lx0, lx1, uy0, uy1);
  sash(lx0, lx1, ly0, ly1);
  sash(rx0, rx1, uy0, uy1);
  sash(rx0, rx1, ly0, ly1, handle: true);

  // ── Подоконник ────────────────────────────────────────────────────────
  box(0, -_H - 0.10, 0.10, _W * 2 + 0.34, 0.14, 0.74, _goldDeep);
  box(0, -_H - 0.19, 0.34, _W * 2 + 0.28, 0.06, 0.22, _gold);

  return faces;
}

Color _shade(Color c, double k) => Color.fromARGB(
      c.alpha,
      (c.red * k).clamp(0, 255).round(),
      (c.green * k).clamp(0, 255).round(),
      (c.blue * k).clamp(0, 255).round(),
    );

// ─── 3D-слой ────────────────────────────────────────────────────────────────
class _Scene3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final List<_Face> faces;
  _Scene3DPainter(this.yaw, this.pitch, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    const camZ = -7.6;
    final f = size.shortestSide * 1.02;
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
        _shade(fc.color, fc.glint ? 1.0 : k),
        c.z - camZ,
        fc.glass,
        fc.glint,
      ));
    }

    items.sort((a, b) => b.depth.compareTo(a.depth));

    for (final it in items) {
      final path = Path()..moveTo(it.pts[0].dx, it.pts[0].dy);
      for (var i = 1; i < it.pts.length; i++) {
        path.lineTo(it.pts[i].dx, it.pts[i].dy);
      }
      path.close();

      if (it.glint) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..style = PaintingStyle.fill,
        );
      } else if (it.glass) {
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

// ─── Чертёжный слой (парящие элементы) ──────────────────────────────────────
class _OverlayPainter extends CustomPainter {
  final double t;
  _OverlayPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final s = (size.shortestSide / 320).clamp(0.55, 2.2);
    final w = size.width, h = size.height;
    final ph = t * math.pi * 2;

    double lev(double phase, double amp) => math.sin(ph + phase) * h * amp;

    // размерные линии, имитирующие чертёж
    _dimH(canvas, w * 0.25, w * 0.75, h * 0.130 + lev(0.0, 0.012), '1300', s);
    _dimV(canvas, w * 0.860, h * 0.300 + lev(1.7, 0.010),
        h * 0.620 + lev(1.7, 0.010), '1400', s);

    // парящие инструменты (асинхронная левитация)
    _tape(canvas, Offset(w * 0.130, h * 0.300 + lev(0.6, 0.022)), s);
    _pencil(canvas, Offset(w * 0.870, h * 0.760 + lev(2.4, 0.026)), s,
        -0.55 + math.sin(ph + 2.4) * 0.10);
    _level(canvas, Offset(w * 0.170, h * 0.760 + lev(4.1, 0.020)), s);
  }

  void _text(Canvas c, String s, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _dimH(Canvas c, double x0, double x1, double y, String label, double s) {
    final p = Paint()
      ..color = _gold.withOpacity(0.55)
      ..strokeWidth = 1.1 * s;
    c.drawLine(Offset(x0, y), Offset(x1, y), p);
    c.drawLine(Offset(x0, y - 5 * s), Offset(x0, y + 5 * s), p);
    c.drawLine(Offset(x1, y - 5 * s), Offset(x1, y + 5 * s), p);
    _text(c, label, Offset((x0 + x1) / 2, y - 14 * s), 13 * s, _goldLight);
  }

  void _dimV(Canvas c, double x, double y0, double y1, String label, double s) {
    final p = Paint()
      ..color = _gold.withOpacity(0.55)
      ..strokeWidth = 1.1 * s;
    c.drawLine(Offset(x, y0), Offset(x, y1), p);
    c.drawLine(Offset(x - 5 * s, y0), Offset(x + 5 * s, y0), p);
    c.drawLine(Offset(x - 5 * s, y1), Offset(x + 5 * s, y1), p);
    _text(c, label, Offset(x + 26 * s, (y0 + y1) / 2), 13 * s, _goldLight);
  }

  /// Рулетка.
  void _tape(Canvas c, Offset o, double s) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: 48 * s, height: 36 * s),
      Radius.circular(10 * s),
    );
    c.drawRRect(body, Paint()..color = const Color(0xFF16233A));
    c.drawRRect(
      body,
      Paint()
        ..color = _gold.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx - 5 * s, o.dy + 14 * s, 10 * s, 30 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = _gold.withOpacity(0.45),
    );
    c.drawCircle(o, 10 * s, Paint()..color = _gold.withOpacity(0.22));
    c.drawCircle(
      o,
      10 * s,
      Paint()
        ..color = _gold.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * s,
    );
    c.drawCircle(o, 3.4 * s, Paint()..color = _gold.withOpacity(0.75));
  }

  /// Карандаш.
  void _pencil(Canvas c, Offset o, double s, double angle) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(angle);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 78 * s, height: 12 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = _gold.withOpacity(0.85),
    );
    final tip = Path()
      ..moveTo(39 * s, -6 * s)
      ..lineTo(52 * s, 0)
      ..lineTo(39 * s, 6 * s)
      ..close();
    c.drawPath(tip, Paint()..color = const Color(0xFFE8E2D0));
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-39 * s, -6 * s, 9 * s, 12 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = const Color(0xFFB08D57),
    );
    c.restore();
  }

  /// Строительный уровень.
  void _level(Canvas c, Offset o, double s) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: 100 * s, height: 22 * s),
      Radius.circular(6 * s),
    );
    c.drawRRect(body, Paint()..color = const Color(0xFF16233A));
    c.drawRRect(
      body,
      Paint()
        ..color = _gold.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: o, width: 36 * s, height: 10 * s),
        Radius.circular(5 * s),
      ),
      Paint()..color = const Color(0xFF7FC4E8).withOpacity(0.30),
    );
    c.drawCircle(o, 3.6 * s, Paint()..color = const Color(0xFFBFE6FA).withOpacity(0.9));
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => old.t != t;
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
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _Scene3DPainter(
                    -0.5 + _dragYaw + auto,
                    0.20 + _dragPitch,
                    _faces,
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _OverlayPainter(_c.value)),
              ),
            ],
          );
        },
      ),
    );
  }
}
