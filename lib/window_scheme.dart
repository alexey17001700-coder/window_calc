import 'package:flutter/material.dart';
import 'templates.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ЗАМЕРНЫЙ ЛИСТ — схема изделия «в лоб»
///  ВИЗУАЛ ПЕРЕПИСАН С НУЛЯ (v1.7.0) в стиле заводского чертежа.
///
///  СТИЛЬ (ГОСТ 2.303 — линии, ГОСТ 2.306 — штриховка):
///   • белый лист, тонкие тёмные линии, никаких «глянцевых» градиентов;
///   • профиль — двойной контур (наружный + внутренний);
///   • стеклопакет — светлая голубая заливка + тонкий контур;
///   • сэндвич-панель — диагональная штриховка 45°;
///   • простенок (стена) — штриховка 45° в другую сторону;
///   • размеры — размерные линии с засечками, числа в мм.
///
///  ГЕОМЕТРИЯ:
///   1. Пропорции изделия — строго по widthMm / heightMm.
///   2. Ширины колонок — по widthMm (недостающие = среднее известных).
///   3. Высоты колонок — по heightRatio, нормированные.
///   4. Сэндвич-панель — всегда внизу створки, ≈700 мм.
///   5. Простенок — под короткой колонкой балконного блока.
///
///  ИНТЕРАКТИВ: тап по створке меняет тип открывания по кругу
///  Поворотная → Откидная → Поворотно-откидная → Глухая → Поворотная
///  и меняет РЕАЛЬНУЮ модель (Section.type), затем [onChanged].
/// ═══════════════════════════════════════════════════════════════════

class WindowScheme extends StatefulWidget {
  final List<SchemeColumn> columns;
  final double width;
  final double height;
  final bool showDimensions;
  final bool showHandles;
  final double? widthMm;
  final double? heightMm;

  /// Тап по створке изменил модель — просим родителя обновиться.
  final VoidCallback? onChanged;

  /// Показывать подсказку под чертежом.
  final bool showHint;

  const WindowScheme({
    super.key,
    required this.columns,
    this.width = 200,
    this.height = 240,
    this.showDimensions = true,
    this.showHandles = true,
    this.widthMm,
    this.heightMm,
    this.onChanged,
    this.showHint = true,
  });

  @override
  State<WindowScheme> createState() => _WindowSchemeState();
}

/// Порядок переключения типов открывания по тапу.
const List<String> kOpenCycle = [
  'Поворотная',
  'Откидная',
  'Поворотно-откидная',
  'Глухая',
];

String nextOpenType(String current) {
  final i = kOpenCycle.indexOf(current);
  if (i < 0) return kOpenCycle.first; // Сэндвич/неизвестное → Поворотная
  return kOpenCycle[(i + 1) % kOpenCycle.length];
}

class _WindowSchemeState extends State<WindowScheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash;
  Rect? _flashRect;
  String? _flashLabel;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails d) {
    final layout = schemeLayout(
      Size(widget.width, widget.height),
      widget.columns,
      widget.showDimensions,
      widthMm: widget.widthMm,
      heightMm: widget.heightMm,
    );
    final p = d.localPosition;

    _SashBox? hit;
    for (final s in layout.sashes) {
      if (s.rect.contains(p)) hit = s;
    }
    if (hit == null) return;

    final col = widget.columns[hit.col];
    if (hit.sec >= col.sections.length) return;
    final sec = col.sections[hit.sec];

    if (sec.type == 'Сэндвич') return;

    final before = sec.type;
    final after = nextOpenType(before);
    if (after == before) return;

    sec.type = after;

    _flashRect = hit.rect;
    _flashLabel = after;
    _flash.forward(from: 0);

    widget.onChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _handleTap,
      child: AnimatedBuilder(
        animation: _flash,
        builder: (context, _) {
          final t = _flash.isAnimating ? _flash.value : 1.0;
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _WindowSchemePainter(
              columns: widget.columns,
              showDimensions: widget.showDimensions,
              showHandles: widget.showHandles,
              widthMm: widget.widthMm,
              heightMm: widget.heightMm,
              flashRect: _flashRect,
              flashLabel: _flashLabel,
              flashT: t,
            ),
          );
        },
      ),
    );

    if (!widget.showHint) return scheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        scheme,
        const SizedBox(height: 4),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 13, color: Color(0xFF6B7A8C)),
            SizedBox(width: 4),
            Text(
              'Тапни створку — сменить открывание',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7A8C)),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ГЕОМЕТРИЯ — общая для отрисовки и hit-test
// ═══════════════════════════════════════════════════════════════════

class _SashBox {
  final int col;
  final int sec;
  final Rect rect;
  const _SashBox(this.col, this.sec, this.rect);
}

class _ColBox {
  final int index;

  /// Полный прямоугольник колонки (выровнена по верху изделия).
  final Rect rect;

  /// Проём колонки внутри рамы (стекло + сэндвич).
  final Rect glass;

  /// Прямоугольники секций, индекс = индекс в col.sections.
  final List<Rect> secRects;

  /// Петли слева? (иначе справа).
  final bool hingeLeft;

  const _ColBox(
    this.index,
    this.rect,
    this.glass,
    this.secRects,
    this.hingeLeft,
  );
}

class _SchemeLayout {
  /// Силуэт изделия (объединение колонок разной высоты).
  final Rect product;
  final List<_ColBox> cols;
  final List<_SashBox> sashes;
  final double frameW;

  const _SchemeLayout(this.product, this.cols, this.sashes, this.frameW);

  static const empty = _SchemeLayout(Rect.zero, [], [], 0);
}

/// Единая раскладка: используется и художником, и обработчиком тапа.
_SchemeLayout schemeLayout(
  Size size,
  List<SchemeColumn> columns,
  bool showDimensions, {
  double? widthMm,
  double? heightMm,
}) {
  if (size.width <= 8 || size.height <= 8) return _SchemeLayout.empty;

  final multiCol = columns.length > 1;
  final multiSec = columns.any((c) => c.sections.length > 1);

  // ── Поля под размерные цепочки
  final mTop = showDimensions && multiCol ? 30.0 : 12.0;
  final mBottom = showDimensions ? 30.0 : 12.0;
  final mLeft = showDimensions && multiSec ? 30.0 : 12.0;
  final mRight = showDimensions ? 30.0 : 12.0;

  final availW = size.width - mLeft - mRight;
  final availH = size.height - mTop - mBottom;
  if (availW <= 8 || availH <= 8) return _SchemeLayout.empty;

  // ── Пропорции изделия строго по мм
  var aspect = availW / availH;
  if (widthMm != null && heightMm != null && widthMm > 0 && heightMm > 0) {
    aspect = widthMm / heightMm;
  }
  var pw = availW;
  var ph = pw / aspect;
  if (ph > availH) {
    ph = availH;
    pw = ph * aspect;
  }
  final product = Rect.fromLTWH(
    mLeft + (availW - pw) / 2,
    mTop + (availH - ph) / 2,
    pw,
    ph,
  );

  final frameW = ((pw < ph ? pw : ph) * 0.045).clamp(3.0, 14.0);
  if (columns.isEmpty) {
    return _SchemeLayout(product, const [], const [], frameW);
  }

  // ── Ширины колонок (строго по мм)
  final n = columns.length;
  final known = columns.where((c) => c.widthMm > 0).toList();
  final widths = <double>[];
  if (known.length == n) {
    final total = known.fold<double>(0, (s, c) => s + c.widthMm);
    for (final c in columns) {
      widths.add(product.width * (c.widthMm / total));
    }
  } else if (known.isNotEmpty) {
    final avg = known.fold<double>(0, (s, c) => s + c.widthMm) / known.length;
    final total = columns.fold<double>(
      0,
      (s, c) => s + (c.widthMm > 0 ? c.widthMm : avg),
    );
    for (final c in columns) {
      final v = c.widthMm > 0 ? c.widthMm : avg;
      widths.add(product.width * (v / total));
    }
  } else {
    for (var i = 0; i < n; i++) {
      widths.add(product.width / n);
    }
  }

  // ── Высоты колонок (по heightRatio, самая высокая = высота изделия)
  var maxRatio = 0.0;
  for (final c in columns) {
    final r = c.heightRatio > 0 ? c.heightRatio : 1.0;
    if (r > maxRatio) maxRatio = r;
  }
  if (maxRatio <= 0) maxRatio = 1.0;

  final cols = <_ColBox>[];
  final sashes = <_SashBox>[];
  var x = product.left;
  for (var i = 0; i < n; i++) {
    final col = columns[i];
    final cw = widths[i];
    final ratio = (col.heightRatio > 0 ? col.heightRatio : 1.0) / maxRatio;
    final ch = product.height * ratio;
    final colRect = Rect.fromLTWH(x, product.top, cw, ch);
    final glass = colRect.deflate(frameW);
    final secs = col.sections.isEmpty ? <Section>[Section()] : col.sections;
    final secRects = _sectionRects(glass, secs, ratio, heightMm);
    final hingeLeft = i <= (n - 1) / 2;
    cols.add(_ColBox(i, colRect, glass, secRects, hingeLeft));
    for (var s = 0; s < secRects.length; s++) {
      sashes.add(_SashBox(i, s, secRects[s]));
    }
    x += cw;
  }

  return _SchemeLayout(product, cols, sashes, frameW);
}

/// Раскладка секций внутри колонки.
/// Сэндвич-панель всегда уходит вниз и получает реалистичную высоту.
List<Rect> _sectionRects(
  Rect glass,
  List<Section> secs,
  double ratio,
  double? heightMm,
) {
  final n = secs.length;
  final rects = List<Rect>.filled(n, Rect.zero);
  if (n == 0 || glass.height <= 1) return rects;

  final order = <int>[];
  for (var i = 0; i < n; i++) {
    if (secs[i].type != 'Сэндвич') order.add(i);
  }
  for (var i = 0; i < n; i++) {
    if (secs[i].type == 'Сэндвич') order.add(i);
  }

  var swCount = 0;
  for (final s in secs) {
    if (s.type == 'Сэндвич') swCount++;
  }
  final glassCount = n - swCount;

  var swFrac = 0.0;
  if (swCount > 0) {
    swFrac = 0.30;
    if (heightMm != null && heightMm > 0 && ratio > 0) {
      final colMm = heightMm * ratio;
      if (colMm > 0) swFrac = (700.0 / colMm).clamp(0.15, 0.45);
    }
  }
  final swH = glass.height * swFrac;
  final eachH = glassCount > 0 ? (glass.height - swH) / glassCount : 0.0;

  var y = glass.top;
  for (final i in order) {
    final h = secs[i].type == 'Сэндвич' ? swH : eachH;
    rects[i] = Rect.fromLTWH(glass.left, y, glass.width, h);
    y += h;
  }
  return rects;
}

// ═══════════════════════════════════════════════════════════════════
//  ХУДОЖНИК — заводской чертёж
// ═══════════════════════════════════════════════════════════════════

class _WindowSchemePainter extends CustomPainter {
  final List<SchemeColumn> columns;
  final bool showDimensions;
  final bool showHandles;
  final double? widthMm;
  final double? heightMm;
  final Rect? flashRect;
  final String? flashLabel;
  final double flashT;

  _WindowSchemePainter({
    required this.columns,
    required this.showDimensions,
    required this.showHandles,
    this.widthMm,
    this.heightMm,
    this.flashRect,
    this.flashLabel,
    this.flashT = 1.0,
  });

  // ── Палитра чертежа
  static const _ink = Color(0xFF1B2733); // основные линии
  static const _inkSoft = Color(0xFF6B7A8C); // размеры
  static const _profile = Color(0xFFF5F8FB); // тело профиля
  static const _profileLine = Color(0xFF8C9BAA); // внутренний контур
  static const _glassA = Color(0xFFEAF6FF);
  static const _glassB = Color(0xFFD2E8FA);
  static const _glassLine = Color(0xFF9CC2DE);
  static const _wall = Color(0xFFF8FAFC);
  static const _wallHatch = Color(0xFFC2CDD9);
  static const _panel = Color(0xFFEFF3F7);
  static const _panelHatch = Color(0xFFA9B6C4);
  static const _net = Color(0xFF2E7D32);
  static const _accent = Color(0xFF1E88E5);
  static const _hinge = Color(0xFF37474F);
  static const _handle = Color(0xFF263238);

  @override
  void paint(Canvas canvas, Size size) {
    final L = schemeLayout(
      size,
      columns,
      showDimensions,
      widthMm: widthMm,
      heightMm: heightMm,
    );
    final product = L.product;
    if (product.width <= 4 || product.height <= 4) return;

    final frameW = L.frameW;
    final sashW = frameW * 0.5;
    final mullW = frameW * 0.85;

    // 1. Простенок (стена) под короткими колонками
    _paintWallBelow(canvas, L);

    // 2. Корпус: профиль + стекло
    _paintBody(canvas, L, frameW);

    // 3. Импосты
    _paintImposts(canvas, L, mullW);

    // 4. Секции
    _paintSections(canvas, L, sashW);

    // 4б. Символы открывания, петли, ручки
    _paintOpenSymbols(canvas, L);

    // 4в. Подписи секций (П / О / ПО / Гл / СП)
    _paintSectionLabels(canvas, L);

    // 5. Вспышка отклика на тап
    _paintFlash(canvas);

    // 6. Размерные цепочки
    _paintDimensions(canvas, L);
  }

  // ─────────────────────────────────────────────────────────────────
  // 1. Простенок — стена под короткой колонкой
  // ─────────────────────────────────────────────────────────────────
  void _paintWallBelow(Canvas canvas, _SchemeLayout L) {
    for (final c in L.cols) {
      final below = Rect.fromLTWH(
        c.rect.left,
        c.rect.bottom,
        c.rect.width,
        L.product.bottom - c.rect.bottom,
      );
      if (below.height <= 0.5) continue;
      canvas.drawRect(below, Paint()..color = _wall);
      _hatch(canvas, below, _wallHatch, 8, false);
      canvas.drawRect(
        below,
        Paint()
          ..color = _profileLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }
  }

  /// Штриховка 45°. [down] — направление наклона.
  void _hatch(
    Canvas canvas,
    Rect rect,
    Color color,
    double step,
    bool down,
  ) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.save();
    canvas.clipRect(rect);
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.9;
    final span = rect.width + rect.height;
    for (var i = -rect.height; i < span; i += step) {
      if (down) {
        canvas.drawLine(
          Offset(rect.left + i, rect.top),
          Offset(rect.left + i + rect.height, rect.bottom),
          p,
        );
      } else {
        canvas.drawLine(
          Offset(rect.left + i, rect.bottom),
          Offset(rect.left + i + rect.height, rect.top),
          p,
        );
      }
    }
    canvas.restore();
  }

  // ─────────────────────────────────────────────────────────────────
  // 2. Корпус: силуэт профиля + стекло по колонкам
  // ─────────────────────────────────────────────────────────────────
  void _paintBody(Canvas canvas, _SchemeLayout L, double frameW) {
    final product = L.product;

    if (L.cols.isEmpty) {
      canvas.drawRect(product, Paint()..color = _profile);
      canvas.drawRect(
        product,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      _paintGlass(canvas, product.deflate(frameW));
      return;
    }

    // Тело профиля — объединение колонок
    final silhouette = _silhouettePath(L);
    canvas.drawPath(silhouette, Paint()..color = _profile);
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Проёмы (стекло) + внутренний контур профиля
    for (final c in L.cols) {
      if (c.glass.width <= 1 || c.glass.height <= 1) continue;
      _paintGlass(canvas, c.glass);
      canvas.drawRect(
        c.glass,
        Paint()
          ..color = _profileLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }
  }

  /// Силуэт изделия — объединение колонок разной высоты.
  Path _silhouettePath(_SchemeLayout L) {
    final path = Path();
    final cols = L.cols;
    if (cols.isEmpty) return path;
    final top = L.product.top;
    path.moveTo(cols.first.rect.left, top);
    path.lineTo(cols.last.rect.right, top);
    for (var i = cols.length - 1; i >= 0; i--) {
      path.lineTo(cols[i].rect.right, cols[i].rect.bottom);
      path.lineTo(cols[i].rect.left, cols[i].rect.bottom);
    }
    path.close();
    return path;
  }

  // ─────────────────────────────────────────────────────────────────
  // 3. Импосты — сплошной профиль (двойная линия)
  // ─────────────────────────────────────────────────────────────────
  void _paintImposts(Canvas canvas, _SchemeLayout L, double mullW) {
    final product = L.product;

    for (var i = 0; i < L.cols.length - 1; i++) {
      final a = L.cols[i];
      final b = L.cols[i + 1];
      final bot = product.top +
          (a.rect.height < b.rect.height ? a.rect.height : b.rect.height);
      _mullionV(canvas, a.rect.right, product.top, bot, mullW);
    }

    for (final c in L.cols) {
      for (var s = 0; s < c.secRects.length - 1; s++) {
        _mullionH(
          canvas,
          c.glass.left,
          c.glass.right,
          c.secRects[s].bottom,
          mullW * 0.9,
        );
      }
    }
  }

  void _mullionV(
    Canvas canvas,
    double x,
    double top,
    double bottom,
    double w,
  ) {
    if (bottom - top <= 2 || w <= 0.5) return;
    final r = Rect.fromLTRB(x - w / 2, top, x + w / 2, bottom);
    canvas.drawRect(r, Paint()..color = _profile);
    final p = Paint()
      ..color = _profileLine
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(r.left, top), Offset(r.left, bottom), p);
    canvas.drawLine(Offset(r.right, top), Offset(r.right, bottom), p);
  }

  void _mullionH(
    Canvas canvas,
    double left,
    double right,
    double y,
    double w,
  ) {
    if (right - left <= 2 || w <= 0.5) return;
    final r = Rect.fromLTRB(left, y - w / 2, right, y + w / 2);
    canvas.drawRect(r, Paint()..color = _profile);
    final p = Paint()
      ..color = _profileLine
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(left, r.top), Offset(right, r.top), p);
    canvas.drawLine(Offset(left, r.bottom), Offset(right, r.bottom), p);
  }

  // ─────────────────────────────────────────────────────────────────
  // 4. Секции (ШАГ 1: рама створки, стекло, сэндвич)
  //    Символы открывания, петли и ручки — ШАГ 2.
  // ─────────────────────────────────────────────────────────────────
  void _paintSections(Canvas canvas, _SchemeLayout L, double sashW) {
    for (final c in L.cols) {
      final col = columns[c.index];
      final secs = col.sections.isEmpty ? <Section>[Section()] : col.sections;
      final isLeaf = secs.any((s) => s.type == 'Сэндвич');

      if (isLeaf) {
        _paintLeaf(canvas, c, secs, sashW);
        continue;
      }

      for (var s = 0; s < c.secRects.length; s++) {
        final sec = s < secs.length ? secs[s] : null;
        _paintSection(canvas, c.secRects[s], sec, sashW);
      }
    }
  }

  void _paintSection(Canvas canvas, Rect rect, Section? sec, double sashW) {
    final type = sec?.type ?? 'Глухая';
    final r = rect.deflate(0.6);
    if (r.width <= 3 || r.height <= 3) return;

    if (type == 'Сэндвич') {
      _paintPanel(canvas, r);
      if (sec?.hasMosquito == true) _paintNet(canvas, r);
      return;
    }

    final openable = type == 'Поворотная' ||
        type == 'Откидная' ||
        type == 'Поворотно-откидная';

    if (openable) {
      // Рамка створки — двойной контур
      canvas.drawRect(r, Paint()..color = _profile);
      canvas.drawRect(
        r,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      final inner = r.deflate(sashW);
      _paintGlass(canvas, inner);
      canvas.drawRect(
        inner,
        Paint()
          ..color = _profileLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      if (sec?.hasMosquito == true) _paintNet(canvas, inner);
    } else {
      // Глухая — стекло + штапик
      final inner = r.deflate(sashW * 0.5);
      _paintGlass(canvas, inner);
      canvas.drawRect(
        inner,
        Paint()
          ..color = _profileLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
      if (sec?.hasMosquito == true) _paintNet(canvas, inner);
    }
  }

  /// Створка-полотно балконной двери: рамка на всю высоту,
  /// внутри — стеклопакет сверху и сэндвич-панель снизу.
  void _paintLeaf(
    Canvas canvas,
    _ColBox c,
    List<Section> secs,
    double sashW,
  ) {
    final leafRect = c.glass.deflate(0.6);
    if (leafRect.width <= 6 || leafRect.height <= 6) return;

    canvas.drawRect(leafRect, Paint()..color = _profile);
    canvas.drawRect(
      leafRect,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    for (var s = 0; s < c.secRects.length; s++) {
      final sec = s < secs.length ? secs[s] : null;
      final inner = c.secRects[s].deflate(sashW);
      if (inner.width <= 2 || inner.height <= 2) continue;
      if (sec?.type == 'Сэндвич') {
        _paintPanel(canvas, inner);
      } else {
        _paintGlass(canvas, inner);
        canvas.drawRect(
          inner,
          Paint()
            ..color = _profileLine
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
      if (sec?.hasMosquito == true) _paintNet(canvas, inner);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 4б. СИМВОЛЫ ОТКРЫВАНИЯ, ПЕТЛИ И РУЧКИ
  //     • вершина (острие) треугольника смотрит НА РУЧКУ;
  //     • основание (два угла) — В СТОРОНУ ПЕТЕЛЬ;
  //     • у створки-полотна (дверь балконного блока) символ идёт
  //       на ВСЮ ВЫСОТУ: от верха стеклопакета до низа сэндвича;
  //     • петли показаны явно (3 метки по высоте).
  // ─────────────────────────────────────────────────────────────────
  void _paintOpenSymbols(Canvas canvas, _SchemeLayout L) {
    for (final c in L.cols) {
      final col = columns[c.index];
      final secs = col.sections.isEmpty ? <Section>[Section()] : col.sections;
      final isLeaf = secs.any((s) => s.type == 'Сэндвич');

      if (isLeaf) {
        final type = _leafOpenType(secs);
        if (type == null) continue;
        _paintTurnSymbol(canvas, c.glass, type, c.hingeLeft);
        _paintFittings(canvas, c.glass, type, c.hingeLeft);
        continue;
      }

      for (var s = 0; s < c.secRects.length; s++) {
        final sec = s < secs.length ? secs[s] : null;
        final type = sec?.type ?? 'Глухая';
        if (type == 'Сэндвич' || type == 'Глухая') continue;
        _paintTurnSymbol(canvas, c.secRects[s], type, c.hingeLeft);
        _paintFittings(canvas, c.secRects[s], type, c.hingeLeft);
      }
    }
  }

  /// Тип открывания створки-полотна (двери): первая не-сэндвич секция.
  String? _leafOpenType(List<Section> secs) {
    for (final s in secs) {
      if (s.type != 'Сэндвич') return s.type;
    }
    return null;
  }

  /// Треугольник(и) открывания внутри [rect].
  void _paintTurnSymbol(
    Canvas canvas,
    Rect rect,
    String type,
    bool hingeLeft,
  ) {
    final r = rect.deflate(2.0);
    if (r.width < 14 || r.height < 14) return;

    final hingeX = hingeLeft ? r.left : r.right;
    final handleX = hingeLeft ? r.right : r.left;

    if (type == 'Поворотная') {
      _triangle(
        canvas,
        Offset(handleX, r.center.dy),
        Offset(hingeX, r.top + 2),
        Offset(hingeX, r.bottom - 2),
      );
    } else if (type == 'Откидная') {
      _triangle(
        canvas,
        Offset(r.center.dx, r.top + 2),
        Offset(r.left + 2, r.bottom - 2),
        Offset(r.right - 2, r.bottom - 2),
      );
    } else if (type == 'Поворотно-откидная') {
      _triangle(
        canvas,
        Offset(handleX, r.center.dy),
        Offset(hingeX, r.top + 2),
        Offset(hingeX, r.bottom - 2),
      );
      final top = Rect.fromLTRB(r.left, r.top, r.right, r.center.dy - 2);
      _triangle(
        canvas,
        Offset(top.center.dx, top.top + 2),
        Offset(top.left + 2, top.bottom - 2),
        Offset(top.right - 2, top.bottom - 2),
      );
    }
  }

  /// Треугольник открывания: тонкий контур + лёгкая заливка.
  void _triangle(Canvas canvas, Offset a, Offset b, Offset c) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = _accent.withOpacity(0.07));
    canvas.drawPath(
      path,
      Paint()
        ..color = _accent.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  /// Петли (на стороне петель) и ручка (на противоположной стороне).
  void _paintFittings(
    Canvas canvas,
    Rect rect,
    String type,
    bool hingeLeft,
  ) {
    final r = rect.deflate(1.5);
    if (r.width < 10 || r.height < 20) return;

    // ── Петли: 3 метки по высоте
    final hx = hingeLeft ? r.left + 1.6 : r.right - 1.6;
    for (final f in const [0.13, 0.50, 0.87]) {
      final y = r.top + r.height * f;
      final hr = Rect.fromCenter(center: Offset(hx, y), width: 3.2, height: 7.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(hr, const Radius.circular(1.2)),
        Paint()..color = _hinge,
      );
    }

    // ── Ручка: с противоположной стороны от петель
    if (!showHandles) return;
    final wx = hingeLeft ? r.right - 2.6 : r.left + 2.6;
    final wy = type == 'Откидная' ? r.bottom - 7.0 : r.center.dy;
    final wr = Rect.fromCenter(center: Offset(wx, wy), width: 3.4, height: 11.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wr, const Radius.circular(1.6)),
      Paint()..color = _handle,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 4в. ПОДПИСИ СЕКЦИЙ — П / О / ПО / Гл / СП
  //     Короткие ГОСТ-обозначения типа открывания в углу секции.
  // ─────────────────────────────────────────────────────────────────
  void _paintSectionLabels(Canvas canvas, _SchemeLayout L) {
    for (final c in L.cols) {
      final col = columns[c.index];
      final secs = col.sections.isEmpty ? <Section>[Section()] : col.sections;
      final isLeaf = secs.any((s) => s.type == 'Сэндвич');

      if (isLeaf) {
        final type = _leafOpenType(secs);
        if (type == null) continue;
        _secLabel(canvas, _shortType(type), c.glass);
        continue;
      }

      for (var s = 0; s < c.secRects.length; s++) {
        final sec = s < secs.length ? secs[s] : null;
        final type = sec?.type ?? 'Глухая';
        _secLabel(canvas, _shortType(type), c.secRects[s]);
      }
    }
  }

  String _shortType(String type) {
    switch (type) {
      case 'Поворотная':
        return 'П';
      case 'Откидная':
        return 'О';
      case 'Поворотно-откидная':
        return 'ПО';
      case 'Глухая':
        return 'Гл';
      case 'Сэндвич':
        return 'СП';
      default:
        return '';
    }
  }

  /// Подпись типа открывания в левом нижнем углу секции.
  void _secLabel(Canvas canvas, String text, Rect rect) {
    if (text.isEmpty) return;
    if (rect.width < 22 || rect.height < 16) return;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _accent,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = rect.left + 2.5;
    final y = rect.bottom - tp.height - 2.0;
    canvas.drawRect(
      Rect.fromLTWH(x - 1.5, y - 1.0, tp.width + 3, tp.height + 2),
      Paint()..color = Colors.white.withOpacity(0.72),
    );
    tp.paint(canvas, Offset(x, y));
  }

  // ─────────────────────────────────────────────────────────────────
  // Стеклопакет
  // ─────────────────────────────────────────────────────────────────
  void _paintGlass(Canvas canvas, Rect rect) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_glassA, _glassB],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = _glassLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Сэндвич-панель — штриховка 45°
  // ─────────────────────────────────────────────────────────────────
  void _paintPanel(Canvas canvas, Rect rect) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.drawRect(rect, Paint()..color = _panel);
    _hatch(canvas, rect, _panelHatch, 7, true);
    canvas.drawRect(
      rect,
      Paint()
        ..color = _profileLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Москитная сетка
  // ─────────────────────────────────────────────────────────────────
  void _paintNet(Canvas canvas, Rect rect) {
    if (rect.width <= 2 || rect.height <= 2) return;
    canvas.save();
    canvas.clipRect(rect);
    final p = Paint()
      ..color = _net.withOpacity(0.4)
      ..strokeWidth = 0.8;
    for (var x = rect.left - rect.height; x < rect.right; x += 6) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x + rect.height, rect.top),
        p,
      );
    }
    canvas.restore();
    canvas.drawRect(
      rect,
      Paint()
        ..color = _net
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Вспышка (отклик на тап)
  // ─────────────────────────────────────────────────────────────────
  void _paintFlash(Canvas canvas) {
    final r = flashRect;
    if (r == null) return;
    final t = flashT.clamp(0.0, 1.0);
    if (t >= 1.0) return;
    final k = 1.0 - t;

    canvas.drawRect(r.deflate(1.5), Paint()..color = _accent.withOpacity(0.20 * k));
    canvas.drawRect(
      r.deflate(1.5),
      Paint()
        ..color = _accent.withOpacity(0.95 * k)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    final label = flashLabel;
    if (label != null && r.width > 40 && r.height > 24) {
      _label(canvas, label, r.center, 10.5, _accent.withOpacity(0.95 * k));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Размерные цепочки (засечки + числа в мм)
  // ─────────────────────────────────────────────────────────────────
  void _paintDimensions(Canvas canvas, _SchemeLayout L) {
    if (!showDimensions) return;
    final product = L.product;

    final sumMm = columns.fold<double>(0, (s, c) => s + c.widthMm);
    final wVal = widthMm ?? (sumMm > 0 ? sumMm : null);

    // ── Общая ширина (снизу)
    final yb = product.bottom + 12;
    _dimLine(canvas, Offset(product.left, yb), Offset(product.right, yb));
    if (wVal != null && wVal > 0) {
      _label(canvas, '${wVal.toInt()}', Offset(product.center.dx, yb + 9), 10);
    }

    // ── Общая высота (справа)
    if (heightMm != null && heightMm! > 0) {
      final xr = product.right + 12;
      _dimLine(canvas, Offset(xr, product.top), Offset(xr, product.bottom));
      canvas.save();
      canvas.translate(xr + 9, product.center.dy);
      canvas.rotate(-1.5707963);
      _label(canvas, '${heightMm!.toInt()}', Offset.zero, 10);
      canvas.restore();
    }

    // ── Цепочка ширин колонок (сверху)
    if (L.cols.length > 1) {
      final yt = product.top - 12;
      _dimLine(canvas, Offset(product.left, yt), Offset(product.right, yt));
      for (final c in L.cols) {
        _tick(canvas, Offset(c.rect.left, yt));
        final mm = _colMm(c.index, wVal);
        if (mm != null && mm > 0 && c.rect.width > 26) {
          _label(canvas, '${mm.toInt()}', Offset(c.rect.center.dx, yt - 9), 9);
        }
      }
      _tick(canvas, Offset(product.right, yt));
    }

    // ── Цепочка высот секций (слева, по самой высокой колонке)
    if (heightMm != null && heightMm! > 0 && L.cols.isNotEmpty) {
      _ColBox? tall;
      for (final c in L.cols) {
        if (tall == null || c.rect.height > tall.rect.height) tall = c;
      }
      if (tall != null && tall.secRects.length > 1) {
        final xl = product.left - 12;
        _dimLine(canvas, Offset(xl, product.top), Offset(xl, product.bottom));
        for (final s in tall.secRects) {
          _tick(canvas, Offset(xl, s.top));
          if (s.height > 22) {
            final mm = heightMm! * (s.height / product.height);
            canvas.save();
            canvas.translate(xl - 9, s.center.dy);
            canvas.rotate(-1.5707963);
            _label(canvas, '${mm.toInt()}', Offset.zero, 9);
            canvas.restore();
          }
        }
        _tick(canvas, Offset(xl, product.bottom));
      }
    }
  }

  /// Размерная линия с засечками на концах.
  void _dimLine(Canvas canvas, Offset a, Offset b) {
    final p = Paint()
      ..color = _inkSoft
      ..strokeWidth = 0.9;
    canvas.drawLine(a, b, p);
    _tick(canvas, a);
    _tick(canvas, b);
  }

  /// Засечка (ГОСТ 2.307) — короткий штрих под 45°.
  void _tick(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = _inkSoft
      ..strokeWidth = 1.1;
    canvas.drawLine(
      Offset(c.dx - 3.5, c.dy + 3.5),
      Offset(c.dx + 3.5, c.dy - 3.5),
      p,
    );
  }

  /// Ширина колонки в мм (с учётом колонок без мм).
  double? _colMm(int i, double? total) {
    if (total == null || total <= 0) return null;
    final known = columns.where((c) => c.widthMm > 0).toList();
    if (known.length == columns.length) return columns[i].widthMm;
    if (known.isNotEmpty) {
      final avg = known.fold<double>(0, (s, c) => s + c.widthMm) / known.length;
      final t = columns.fold<double>(
        0,
        (s, c) => s + (c.widthMm > 0 ? c.widthMm : avg),
      );
      final v = columns[i].widthMm > 0 ? columns[i].widthMm : avg;
      return total * (v / t);
    }
    return total / columns.length;
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize, [
    Color color = _inkSoft,
  ]) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _WindowSchemePainter old) =>
      old.columns != columns ||
      old.showDimensions != showDimensions ||
      old.showHandles != showHandles ||
      old.widthMm != widthMm ||
      old.heightMm != heightMm ||
      old.flashRect != flashRect ||
      old.flashLabel != flashLabel ||
      old.flashT != flashT;
}
