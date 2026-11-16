import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Премиальный программный 3D-рендерер.
///
/// Без WebView, WebGL и внешних пакетов — чистая математика + CustomPainter.
/// Работает офлайн, не требует разрешений, сборка APK остаётся стабильной.
///
/// Сцена:
///  • окно из ПВХ — тонкая белая рама, голубоватые стеклопакеты с бликами,
///    серебристая ручка, тёмные петли, подоконник с отливом;
///  • инструменты (рулетка, уровень, карандаш) — реалистичные сплошные
///    объёмы в своих цветах, летают по СВОИМ наклонным орбитам вокруг окна;
///  • единая сортировка по глубине: инструмент за окном скрывается за рамой,
///    перед окном — рисуется поверх.

// ═══════════════════════════ ВЕКТОР ═══════════════════════════

class _V3 {
  final double x, y, z;
  const _V3(this.x, this.y, this.z);
  _V3 operator +(_V3 o) => _V3(x + o.x, y + o.y, z + o.z);
  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);
  _V3 operator *(double s) => _V3(x * s, y * s, z * s);
  double get len => math.sqrt(x * x + y * y + z * z);
  _V3 get unit {
    final l = len;
    return l == 0 ? const _V3(0, 0, 0) : _V3(x / l, y / l, z / l);
  }

  static _V3 cross(_V3 a, _V3 b) =>
      _V3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
  static double dot(_V3 a, _V3 b) => a.x * b.x + a.y * b.y + a.z * b.z;
}

_V3 _rotX(_V3 p, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V3(p.x, p.y * c - p.z * s, p.y * s + p.z * c);
}

_V3 _rotY(_V3 p, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V3(p.x * c + p.z * s, p.y, -p.x * s + p.z * c);
}

_V3 _rotZ(_V3 p, double a) {
  final c = math.cos(a), s = math.sin(a);
  return _V3(p.x * c - p.y * s, p.x * s + p.y * c, p.z);
}

// ═══════════════════════════ ПРИМИТИВ ═══════════════════════════

class _Prim {
  final List<_V3> pts;
  final Color color;
  final double alpha;
  final bool fill;
  final double stroke;
  final bool glow;
  final bool glass;
  _Prim(
    this.pts,
    this.color, {
    this.alpha = 1,
    this.fill = true,
    this.stroke = 1,
    this.glow = false,
    this.glass = false,
  });
}

/// Позиция + поворот для сборки деталей в локальных координатах.
class _Place {
  final _V3 t;
  final double rx, ry, rz;
  const _Place(this.t, {this.rx = 0, this.ry = 0, this.rz = 0});

  _V3 apply(_V3 p) {
    var q = p;
    if (rz != 0) q = _rotZ(q, rz);
    if (rx != 0) q = _rotX(q, rx);
    if (ry != 0) q = _rotY(q, ry);
    return q + t;
  }
}

const _boxFaces = <List<int>>[
  [0, 1, 3, 2],
  [4, 5, 7, 6],
  [0, 2, 6, 4],
  [1, 3, 7, 5],
  [0, 1, 5, 4],
  [2, 3, 7, 6],
];

const _boxEdges = <List<int>>[
  [0, 1], [1, 3], [3, 2], [2, 0],
  [4, 5], [5, 7], [7, 6], [6, 4],
  [0, 4], [1, 5], [2, 6], [3, 7],
];

void _box(
  List<_Prim> out,
  _V3 c,
  _V3 s,
  Color col, {
  double alpha = 1,
  _Place? pl,
  bool wire = false,
  double stroke = 1,
  bool glow = false,
}) {
  final hx = s.x / 2, hy = s.y / 2, hz = s.z / 2;
  final local = <_V3>[
    _V3(-hx, -hy, -hz), _V3(hx, -hy, -hz), _V3(-hx, hy, -hz), _V3(hx, hy, -hz),
    _V3(-hx, -hy, hz), _V3(hx, -hy, hz), _V3(-hx, hy, hz), _V3(hx, hy, hz),
  ];
  final p = local.map((v) => (pl == null ? v : pl.apply(v)) + c).toList();
  if (wire) {
    for (final e in _boxEdges) {
      out.add(_Prim([p[e[0]], p[e[1]]], col,
          alpha: alpha, fill: false, stroke: stroke, glow: glow));
    }
  } else {
    for (final f in _boxFaces) {
      out.add(_Prim([p[f[0]], p[f[1]], p[f[2]], p[f[3]]], col, alpha: alpha));
    }
  }
}

/// Призма вдоль оси X — каркасный стиль.
void _prism(
  List<_Prim> out,
  _V3 c,
  double r,
  double len,
  int sides,
  Color col, {
  double alpha = 1,
  _Place? pl,
  double stroke = 1.2,
  bool glow = true,
  bool fill = false,
}) {
  final a0 = <_V3>[], a1 = <_V3>[];
  for (var i = 0; i < sides; i++) {
    final ang = i / sides * math.pi * 2;
    final y = math.cos(ang) * r, z = math.sin(ang) * r;
    a0.add(_V3(-len / 2, y, z));
    a1.add(_V3(len / 2, y, z));
  }
  _V3 w(_V3 v) => (pl == null ? v : pl.apply(v)) + c;
  for (var i = 0; i < sides; i++) {
    final j = (i + 1) % sides;
    out.add(_Prim([w(a0[i]), w(a0[j])], col,
        alpha: alpha, fill: false, stroke: stroke, glow: glow));
    out.add(_Prim([w(a1[i]), w(a1[j])], col,
        alpha: alpha, fill: false, stroke: stroke, glow: glow));
    out.add(_Prim([w(a0[i]), w(a1[i])], col,
        alpha: alpha * 0.65, fill: false, stroke: stroke * 0.75, glow: glow));
    // Сплошная заливка боковой грани — нужна для реалистичных инструментов.
    if (fill) {
      out.add(_Prim([w(a0[i]), w(a0[j]), w(a1[j]), w(a1[i])], col, alpha: alpha));
    }
  }
  if (fill) {
    out.add(_Prim(a0.map(w).toList(), col, alpha: alpha));
    out.add(_Prim(a1.map(w).toList(), col, alpha: alpha));
  }
}

/// Конус (острие карандаша).
void _cone(
  List<_Prim> out,
  _V3 c,
  double r,
  double len,
  int sides,
  Color col, {
  double alpha = 1,
  _Place? pl,
  double stroke = 1.2,
  bool glow = true,
  bool fill = false,
}) {
  final ring = <_V3>[];
  for (var i = 0; i < sides; i++) {
    final ang = i / sides * math.pi * 2;
    ring.add(_V3(-len / 2, math.cos(ang) * r, math.sin(ang) * r));
  }
  final apex = _V3(len / 2, 0, 0);
  _V3 w(_V3 v) => (pl == null ? v : pl.apply(v)) + c;
  for (var i = 0; i < sides; i++) {
    final j = (i + 1) % sides;
    out.add(_Prim([w(ring[i]), w(ring[j])], col,
        alpha: alpha, fill: false, stroke: stroke, glow: glow));
    out.add(_Prim([w(ring[i]), w(apex)], col,
        alpha: alpha, fill: false, stroke: stroke, glow: glow));
    if (fill) {
      out.add(_Prim([w(ring[i]), w(ring[j]), w(apex)], col, alpha: alpha));
    }
  }
  if (fill) {
    out.add(_Prim(ring.map(w).toList(), col, alpha: alpha));
  }
}

// ═══════════════════════════ ПАЛИТРА ═══════════════════════════

const _pvc = Color(0xFFF7F9FC);
const _pvcShade = Color(0xFFD3DCE7);
const _pvcInner = Color(0xFFEDF1F6);
const _pvcGroove = Color(0xFFA9B6C6);
const _glassCol = Color(0xFF7FC0E6);
const _silver = Color(0xFFD8DDE5);
const _silverDark = Color(0xFF8E97A3);
const _darkMetal = Color(0xFF39414B);
const _sillCol = Color(0xFFE8ECF1);

// Инструменты рисуются сплошными объёмами в реальных цветах
// (жёлтая рулетка, алюминиевый уровень, жёлтый карандаш) — палитра
// задаётся локально в _buildTools.

// ═══════════════════════════ ОКНО ═══════════════════════════

const _W = 1.30; // полуширина
const _H = 1.40; // полувысота
const _D = 0.075; // глубина профиля (тонкий ПВХ)

void _buildWindow(List<_Prim> out) {
  // ВАЖНО: «лицо» окна смотрит в −Z (к камере). Все выступающие детали —
  // ручка, петли, штапик, отлив — идут в минус по Z, иначе они уходят
  // за стекло и окно выглядит плоским.
  const fw = 0.078; // толщина профиля рамы
  const st = 0.048; // обвязка створки
  const sd = 0.058; // глубина створки
  const bead = 0.017; // штапик
  const fz = -_D / 2; // передняя плоскость профиля

  // ── Рама: наружные стенки профиля ────────────────────────────────
  _box(out, const _V3(-_W + fw / 2, 0, 0), const _V3(fw, _H * 2, _D), _pvc);
  _box(out, const _V3(_W - fw / 2, 0, 0), const _V3(fw, _H * 2, _D), _pvc);
  _box(out, const _V3(0, _H - fw / 2, 0), const _V3(_W * 2 - fw * 2, fw, _D), _pvc);
  _box(out, const _V3(0, -_H + fw / 2, 0), const _V3(_W * 2 - fw * 2, fw, _D), _pvc);

  // ── Внутренняя стенка профиля (уходит вглубь, даёт объём) ────────
  const iw = 0.020;
  const iz = _D / 2 + 0.004;
  _box(out, const _V3(-_W + fw + iw / 2, 0, iz),
      const _V3(iw, _H * 2 - fw * 2, 0.030), _pvcShade);
  _box(out, const _V3(_W - fw - iw / 2, 0, iz),
      const _V3(iw, _H * 2 - fw * 2, 0.030), _pvcShade);
  _box(out, const _V3(0, _H - fw - iw / 2, iz),
      const _V3(_W * 2 - fw * 2, iw, 0.030), _pvcShade);
  _box(out, const _V3(0, -_H + fw + iw / 2, iz),
      const _V3(_W * 2 - fw * 2, iw, 0.030), _pvcShade);

  // ── Фаска по передней кромке профиля ─────────────────────────────
  const lip = 0.020;
  const lipZ = fz - 0.004;
  _box(out, const _V3(-_W + fw - lip / 2, 0, lipZ),
      const _V3(lip, _H * 2 - fw * 2, 0.010), _pvcInner);
  _box(out, const _V3(_W - fw + lip / 2, 0, lipZ),
      const _V3(lip, _H * 2 - fw * 2, 0.010), _pvcInner);
  _box(out, const _V3(0, _H - fw + lip / 2, lipZ),
      const _V3(_W * 2 - fw * 2, lip, 0.010), _pvcInner);
  _box(out, const _V3(0, -_H + fw - lip / 2, lipZ),
      const _V3(_W * 2 - fw * 2, lip, 0.010), _pvcInner);

  // ── Воздушная камера профиля (тёмная канавка по центру бруса) ────
  const chW = 0.013;
  _box(out, const _V3(-_W + fw * 0.5, 0, lipZ),
      const _V3(chW, _H * 2 - fw * 2, 0.006), _pvcGroove);
  _box(out, const _V3(_W - fw * 0.5, 0, lipZ),
      const _V3(chW, _H * 2 - fw * 2, 0.006), _pvcGroove);
  _box(out, const _V3(0, _H - fw * 0.5, lipZ),
      const _V3(_W * 2 - fw * 2, chW, 0.006), _pvcGroove);
  _box(out, const _V3(0, -_H + fw * 0.5, lipZ),
      const _V3(_W * 2 - fw * 2, chW, 0.006), _pvcGroove);

  // ── Импост по центру ─────────────────────────────────────────────
  _box(out, const _V3(0, 0, 0), const _V3(0.064, _H * 2 - fw * 2, _D), _pvc);
  _box(out, const _V3(0, 0, lipZ), const _V3(0.015, _H * 2 - fw * 2, 0.008),
      _pvcGroove);

  // ── Створки ──────────────────────────────────────────────────────
  final lx0 = -_W + fw, lx1 = -0.032;
  final rx0 = 0.032, rx1 = _W - fw;

  void sash(double x0, double x1, {required bool handle}) {
    final cx = (x0 + x1) / 2;
    final wdt = x1 - x0;
    final gx0 = x0 + st, gx1 = x1 - st;
    final gy0 = -_H + fw + st, gy1 = _H - fw - st;
    final gw = gx1 - gx0, gh = gy1 - gy0;

    // обвязки створки
    _box(out, _V3(cx, _H - fw - st / 2, -0.014), _V3(wdt, st, sd), _pvc);
    _box(out, _V3(cx, -_H + fw + st / 2, -0.014), _V3(wdt, st, sd), _pvc);
    _box(out, _V3(x0 + st / 2, 0, -0.014), _V3(st, _H * 2 - fw * 2, sd), _pvc);
    _box(out, _V3(x1 - st / 2, 0, -0.014), _V3(st, _H * 2 - fw * 2, sd), _pvc);

    // штапик вокруг стеклопакета
    _box(out, _V3(cx, gy1 + bead / 2, -0.030),
        _V3(gw + bead * 2, bead, 0.020), _pvcInner);
    _box(out, _V3(cx, gy0 - bead / 2, -0.030),
        _V3(gw + bead * 2, bead, 0.020), _pvcInner);
    _box(out, _V3(gx0 - bead / 2, 0, -0.030),
        _V3(bead, gh, 0.020), _pvcInner);
    _box(out, _V3(gx1 + bead / 2, 0, -0.030),
        _V3(bead, gh, 0.020), _pvcInner);

    // стеклопакет — основа
    out.add(_Prim([
      _V3(gx0, gy0, -0.022),
      _V3(gx1, gy0, -0.022),
      _V3(gx1, gy1, -0.022),
      _V3(gx0, gy1, -0.022),
    ], _glassCol, alpha: 0.30, glass: true));

    // градиент неба: сверху плотнее, снизу прозрачнее
    const rows = 3;
    for (var i = 0; i < rows; i++) {
      final y0 = gy0 + gh * i / rows;
      final y1 = gy0 + gh * (i + 1) / rows;
      out.add(_Prim([
        _V3(gx0, y0, -0.023),
        _V3(gx1, y0, -0.023),
        _V3(gx1, y1, -0.023),
        _V3(gx0, y1, -0.023),
      ], const Color(0xFFB9E4FA), alpha: 0.22 - 0.035 * i));
    }

    // двойной блик
    if (gw > 0.2 && gh > 0.2) {
      out.add(_Prim([
        _V3(gx0 + gw * 0.14, gy0 + gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.30, gy0 + gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.56, gy1 - gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.40, gy1 - gh * 0.06, -0.032),
      ], const Color(0xFFFFFFFF), alpha: 0.20));
      out.add(_Prim([
        _V3(gx0 + gw * 0.62, gy0 + gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.70, gy0 + gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.92, gy1 - gh * 0.06, -0.032),
        _V3(gx0 + gw * 0.84, gy1 - gh * 0.06, -0.032),
      ], const Color(0xFFFFFFFF), alpha: 0.10));
    }

    // петли — тёмный металл с серебристой осью, две на створку
    final hx = x0 + st / 2;
    for (final k in const [0.10, 0.90]) {
      final hy = gy0 + gh * k;
      _box(out, _V3(hx, hy, -0.034), const _V3(0.034, 0.125, 0.036), _darkMetal);
      _box(out, _V3(hx, hy, -0.054), const _V3(0.022, 0.080, 0.022), _silverDark);
    }

    // ручка — серебристая, с противоположной от петель стороны
    if (handle) {
      final mx = x1 - st / 2;
      _box(out, _V3(mx, -0.02, -0.040), const _V3(0.030, 0.150, 0.022),
          _silverDark);
      _box(out, _V3(mx - 0.016, -0.02, -0.082), const _V3(0.024, 0.056, 0.072),
          _silver);
      _box(out, _V3(mx - 0.016, -0.082, -0.082), const _V3(0.022, 0.036, 0.058),
          _silver);
    }
  }

  sash(lx0, lx1, handle: false);
  sash(rx0, rx1, handle: true);

  // ── Подоконник с отливом (выступает к камере) ────────────────────
  _box(out, const _V3(0, -_H - 0.036, -0.058),
      const _V3(_W * 2 + 0.30, 0.072, _D + 0.20), _sillCol);
  _box(out, const _V3(0, -_H - 0.092, -(_D / 2 + 0.085)),
      const _V3(_W * 2 + 0.26, 0.040, 0.060), _pvcShade);
  _box(out, const _V3(0, -_H - 0.006, -(_D / 2 + 0.070)),
      const _V3(_W * 2 + 0.30, 0.014, 0.040), _pvcInner);
}

/// Масштаб модели окна. Уменьшен, чтобы инструменты на орбитах
/// (радиус 1.16–1.46) не пролетали сквозь раму и стеклопакеты.
const _winScale = 0.60;

/// Пропорциональное масштабирование готовых примитивов от центра сцены.
void _scalePrims(List<_Prim> list, double s) {
  for (var i = 0; i < list.length; i++) {
    final p = list[i];
    list[i] = _Prim(
      p.pts.map((v) => _V3(v.x * s, v.y * s, v.z * s)).toList(),
      p.color,
      alpha: p.alpha,
      fill: p.fill,
      stroke: p.stroke,
      glow: p.glow,
      glass: p.glass,
    );
  }
}

// ═══════════════════════════ ИНСТРУМЕНТЫ ═══════════════════════════

/// Точка на наклонной орбите. У каждого инструмента СВОЯ плоскость:
/// три независимых наклона (X, Y, Z) дают уникальную траекторию в 3D.
_V3 _orbit(double r, double tx, double ty, double tz, double a) {
  var p = _V3(math.cos(a) * r, 0, math.sin(a) * r);
  p = _rotX(p, tx);
  p = _rotZ(p, tz);
  p = _rotY(p, ty);
  return p;
}

void _buildTools(List<_Prim> out, double t) {
  // ── РУЛЕТКА — жёлтый корпус, чёрная резина, серебристая лента ──────
  // Орбита: наклон X 0.55 · Z 0.25
  {
    final a = t * 0.40;
    final pos = _orbit(1.16, 0.55, 0.00, 0.25, a);
    final pl = _Place(pos, rx: 0.42, ry: a * 1.7, rz: 0.30);

    const bodyY = Color(0xFFF0BE2E); // жёлтый пластик корпуса
    const rubber = Color(0xFF23262B); // чёрная резина
    const tape = Color(0xFFE4E9EF); // серебристая лента
    const mark = Color(0xFF2B3038); // деления

    // корпус
    _box(out, const _V3(0, 0, 0), const _V3(0.150, 0.160, 0.086), bodyY, pl: pl);
    // нижняя резиновая накладка
    _box(out, const _V3(0, -0.090, 0), const _V3(0.152, 0.028, 0.088), rubber,
        pl: pl);
    // верхняя чёрная кромка
    _box(out, const _V3(0, 0.088, 0), const _V3(0.152, 0.020, 0.088), rubber,
        pl: pl);
    // барабан катушки (виден сбоку)
    _prism(out, const _V3(0, 0, -0.047), 0.060, 0.018, 10, bodyY,
        pl: pl, alpha: 1, stroke: 0.8, glow: false, fill: true);
    // ось катушки
    _prism(out, const _V3(0, 0, -0.058), 0.018, 0.014, 8, rubber,
        pl: pl, alpha: 1, stroke: 0.8, glow: false, fill: true);
    // клипса на пояс
    _box(out, const _V3(-0.086, -0.018, 0), const _V3(0.018, 0.066, 0.024),
        rubber, pl: pl);
    // выдвинутая лента
    _box(out, const _V3(0.140, -0.028, 0), const _V3(0.130, 0.024, 0.056),
        tape, pl: pl);
    // деления на ленте
    for (var i = 0; i < 5; i++) {
      _box(out, _V3(0.092 + i * 0.025, -0.028, -0.030),
          const _V3(0.004, 0.022, 0.004), mark, pl: pl);
    }
    // крючок на конце ленты
    _box(out, const _V3(0.210, -0.028, 0), const _V3(0.014, 0.048, 0.050),
        tape, pl: pl);
    _box(out, const _V3(0.210, -0.052, 0), const _V3(0.014, 0.012, 0.050),
        tape, pl: pl);
  }

  // ── УРОВЕНЬ — алюминиевый брус, жёлтые заглушки, зелёные ампулы ────
  // Орбита: наклон X −0.45 · Y 0.90 · Z 0.75
  {
    final a = -t * 0.29 + 2.1;
    final pos = _orbit(1.34, -0.45, 0.90, 0.75, a);
    final pl = _Place(pos, rx: 0.15, ry: a * 1.2, rz: 0.55);

    const alum = Color(0xFFC4CAD2); // алюминий
    const alumDark = Color(0xFF868E98); // тёмная грань
    const capY = Color(0xFFE0AE28); // жёлтые заглушки
    const vialGlass = Color(0xFFD8E4EE); // стекло ампулы
    const vialLiq = Color(0xFF3FD46A); // зелёная жидкость

    // корпус
    _box(out, const _V3(0, 0, 0), const _V3(0.620, 0.060, 0.050), alum, pl: pl);
    // нижняя тёмная грань
    _box(out, const _V3(0, -0.033, 0), const _V3(0.620, 0.010, 0.052),
        alumDark, pl: pl);
    // торцевые заглушки
    for (final x in const [-0.318, 0.318]) {
      _box(out, _V3(x, 0, 0), const _V3(0.020, 0.064, 0.054), capY, pl: pl);
    }
    // центральная горизонтальная ампула
    _box(out, const _V3(0, 0.019, -0.027), const _V3(0.150, 0.026, 0.008),
        vialGlass, pl: pl);
    _box(out, const _V3(0, 0.019, -0.031), const _V3(0.068, 0.015, 0.004),
        vialLiq, pl: pl);
    // две вертикальные ампулы по краям
    for (final x in const [-0.215, 0.215]) {
      _box(out, _V3(x, 0.019, -0.027), const _V3(0.026, 0.058, 0.008),
          vialGlass, pl: pl);
      _box(out, _V3(x, 0.019, -0.031), const _V3(0.015, 0.026, 0.004),
          vialLiq, pl: pl);
    }
  }

  // ── КАРАНДАШ — жёлтый шестигранник, дерево, графит, ластик ─────────
  // Орбита: наклон X 0.85 · Y −0.70 · Z −0.35
  {
    final a = t * 0.24 + 4.0;
    final pos = _orbit(1.46, 0.85, -0.70, -0.35, a);
    final pl = _Place(pos, rx: 0.30, ry: a * 1.4, rz: -0.35);

    const wood = Color(0xFFF0C43A); // жёлтый корпус
    const cedar = Color(0xFFE3C08D); // дерево на срезе
    const graphite = Color(0xFF2A2E34); // графит
    const ferrule = Color(0xFFBCC3CC); // металлическое кольцо
    const eraser = Color(0xFFE4889A); // ластик

    // корпус — шестигранник
    _prism(out, const _V3(-0.030, 0, 0), 0.032, 0.300, 6, wood,
        pl: pl, alpha: 1, stroke: 0.9, glow: false, fill: true);
    // деревянный срез
    _cone(out, const _V3(0.170, 0, 0), 0.032, 0.090, 6, cedar,
        pl: pl, alpha: 1, stroke: 0.9, glow: false, fill: true);
    // графитовый наконечник
    _cone(out, const _V3(0.228, 0, 0), 0.013, 0.036, 6, graphite,
        pl: pl, alpha: 1, stroke: 0.9, glow: false, fill: true);
    // обжимное кольцо
    _prism(out, const _V3(-0.190, 0, 0), 0.034, 0.026, 6, ferrule,
        pl: pl, alpha: 1, stroke: 0.9, glow: false, fill: true);
    // ластик
    _prism(out, const _V3(-0.222, 0, 0), 0.030, 0.040, 6, eraser,
        pl: pl, alpha: 1, stroke: 0.9, glow: false, fill: true);
  }
}

// ═══════════════════════════ ОТРИСОВКА ═══════════════════════════

Color _shade(Color c, double k) => Color.fromARGB(
      c.alpha,
      (c.red * k).clamp(0, 255).round(),
      (c.green * k).clamp(0, 255).round(),
      (c.blue * k).clamp(0, 255).round(),
    );

class _Draw {
  final List<Offset> pts;
  final _Prim pr;
  final double depth;
  final double k;
  final double fog;
  _Draw(this.pts, this.pr, this.depth, this.k, this.fog);
}

class _ScenePainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final List<_Prim> prims;
  _ScenePainter(this.yaw, this.pitch, this.prims);

  // Кэш фонового шейдера: пересоздаётся только при смене размера,
  // а не каждый кадр (экономит аллокации и работу GPU).
  static Size? _bgSize;
  static Paint? _bgPaint;

  @override
  void paint(Canvas canvas, Size size) {
    // мягкое свечение позади сцены — «премиальная» подсветка
    if (_bgSize != size || _bgPaint == null) {
      _bgSize = size;
      _bgPaint = Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x2A3E7BB8), Color(0x00000000)],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.shortestSide * 0.78,
        ));
    }
    canvas.drawRect(Offset.zero & size, _bgPaint!);

    const camZ = -4.2;
    final f = size.shortestSide * 1.15;
    final cx = size.width / 2, cy = size.height / 2;
    final light = const _V3(-0.35, 0.62, 0.70).unit;

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
      final s = f / (d <= 0.25 ? 0.25 : d);
      return Offset(cx + p.x * s, cy - p.y * s);
    }

    final items = <_Draw>[];
    for (final pr in prims) {
      final rp = pr.pts.map(rot).toList();
      var zs = 0.0;
      for (final p in rp) {
        zs += p.z;
      }
      final depth = zs / rp.length - camZ;
      if (depth <= 0.35) continue;

      var k = 1.0;
      if (pr.fill && rp.length >= 3) {
        final n = _V3.cross(rp[1] - rp[0], rp[2] - rp[0]).unit;
        k = 0.46 + 0.54 * _V3.dot(n, light).abs();
      }
      // воздушная перспектива: дальние объекты приглушаются
      final fog = (1.0 - (depth - 3.6) * 0.085).clamp(0.42, 1.0);
      items.add(_Draw(rp.map(proj).toList(), pr, depth, k, fog));
    }

    // дальние — первыми: инструмент за окном уходит за раму
    items.sort((a, b) => b.depth.compareTo(a.depth));

    for (final it in items) {
      final pr = it.pr;

      if (!pr.fill) {
        final a = it.pts;
        if (a.length < 2) continue;
        // Ореол рисуем только у светящихся линий — вдвое меньше draw-вызовов
        // на контурах окна (фаска, штапик, канавки профиля).
        if (pr.glow) {
          canvas.drawLine(
            a[0],
            a[1],
            Paint()
              ..color = pr.color.withOpacity(pr.alpha * 0.20 * it.fog)
              ..strokeWidth = pr.stroke * 3.4
              ..strokeCap = StrokeCap.round
              ..blendMode = BlendMode.plus,
          );
        }
        canvas.drawLine(
          a[0],
          a[1],
          Paint()
            ..color = pr.color.withOpacity(pr.alpha * it.fog)
            ..strokeWidth = pr.stroke
            ..strokeCap = StrokeCap.round
            ..blendMode = pr.glow ? BlendMode.plus : BlendMode.srcOver,
        );
        continue;
      }

      final path = Path()..moveTo(it.pts[0].dx, it.pts[0].dy);
      for (var i = 1; i < it.pts.length; i++) {
        path.lineTo(it.pts[i].dx, it.pts[i].dy);
      }
      path.close();

      if (pr.glass) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _shade(pr.color, it.k).withOpacity(pr.alpha * it.fog)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFCFEBFA).withOpacity(0.55 * it.fog)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      } else if (pr.alpha < 1) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _shade(pr.color, it.k).withOpacity(pr.alpha * it.fog)
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = _shade(pr.color, it.k)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0x26000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.yaw != yaw || old.pitch != pitch;
}

// ═══════════════════════════ ВИДЖЕТ ═══════════════════════════

/// 3D-заставка: окно плавно вращается, инструменты летают по орбитам.
/// Управление не требуется — чистая анимация.
class Viewer3D extends StatefulWidget {
  const Viewer3D({super.key});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  /// Геометрия окна статична — собираем её ОДИН раз при старте.
  /// Раньше ~290 примитивов пересобирались каждый кадр: это давало
  /// постоянные аллокации и просадку FPS на слабых телефонах.
  late final List<_Prim> _windowPrims;

  @override
  void initState() {
    super.initState();
    final win = <_Prim>[];
    _buildWindow(win);
    _scalePrims(win, _winScale);
    _windowPrims = win;
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 24))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value * math.pi * 2;
        // Копируем ссылки на готовые примитивы окна (дёшево) и достраиваем
        // только движущиеся инструменты.
        final prims = List<_Prim>.of(_windowPrims);
        _buildTools(prims, t);
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ScenePainter(
              t * 0.55 + math.sin(t * 1.7) * 0.18,
              0.17 + math.sin(t * 0.9) * 0.05,
              prims,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}
