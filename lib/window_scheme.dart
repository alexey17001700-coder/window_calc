import 'package:flutter/material.dart';
import 'templates.dart';

/// Схема окна «в лоб» — замерный лист.
///
/// ПРАВИЛА ОТРИСОВКИ (v1.6.3):
///  • пропорции изделия строго по мм (widthMm × heightMm) с сохранением
///    соотношения сторон внутри отведённой области;
///  • ширины колонок — по widthMm; если часть колонок без мм, недостающие
///    получают среднее известных (раньше раскладка ломалась и вылезала);
///  • высоты колонок — по heightRatio, самая высокая заполняет изделие;
///  • сэндвич-панель ВСЕГДА внизу колонки, высота ≈ 700 мм (или 30%);
///  • ниже короткой колонки балконного блока рисуется ПРОСТЕНОК (стена);
///  • символ открывания: вершина (острие) треугольника смотрит на РУЧКУ,
///    широкое основание — на ПЕТЛИ; петли рисуются явно (3 метки по высоте);
///  • у створки-полотна балконной двери (стеклопакет + сэндвич) символ
///    открывания, ручка и петли рисуются ОДИН раз на ВСЮ высоту створки —
///    от верха стеклопакета до низа сэндвич-панели;
///  • размерные цепочки: сверху — ширины колонок, слева — высоты секций,
///    снизу — общая ширина, справа — общая высота.
///
/// ИНТЕРАКТИВ: тап по створке меняет тип открывания по кругу
/// Поворотная → Откидная → Поворотно-откидная → Глухая → Поворотная
/// и меняет реальную модель данных (Section.type), после чего
/// вызывается [onChanged] — родитель пересчитывает цену.
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

    // Ищем створку под пальцем (сверху вниз — последняя нарисованная важнее)
    _SashBox? hit;
    for (final s in layout.sashes) {
      if (s.rect.contains(p)) hit = s;
    }
    if (hit == null) return;

    final col = widget.columns[hit.col];
    if (hit.sec >= col.sections.length) return;
    final sec = col.sections[hit.sec];

    // Сэндвич-панель не створка — не трогаем
    if (sec.type == 'Сэндвич') return;

    final before = sec.type;
    final after = nextOpenType(before);
    if (after == before) return;

    // ── Меняем РЕАЛЬНУЮ модель данных
    sec.type = after;

    // ── Визуальный отклик
    _flashRect = hit.rect;
    _flashLabel = after;
    _flash.forward(from: 0);

    // ── Сообщаем родителю (пересчёт цены / перерисовка)
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
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

// ═══════════════════════════════════════════════════════════
// ГЕОМЕТРИЯ (общая для отрисовки и hit-test)
// ═══════════════════════════════════════════════════════════

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

  /// Стекло внутри рамы колонки.
  final Rect glass;

  /// Прямоугольники секций, индекс = индекс в col.sections.
  final List<Rect> secRects;

  /// Петли слева? (иначе справа) — от этого зависит символ и ручка.
  final bool hingeLeft;

  const _ColBox(this.index, this.rect, this.glass, this.secRects, this.hingeLeft);
}

class _SchemeLayout {
  /// Силуэт изделия (объединение колонок).
  final Rect product;
  final List<_ColBox> cols;
  final List<_SashBox> sashes;
  final double frameW;

  const _SchemeLayout(this.product, this.cols, this.sashes, this.frameW);

  static const empty = _SchemeLayout(Rect.zero, [], [], 0);
}

/// Единая раскладка: используется и художником, и обработчиком тапа —
/// попадание пальца всегда совпадает с картинкой.
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
  final mTop = showDimensions && multiCol ? 24.0 : 8.0;
  final mBottom = showDimensions ? 24.0 : 8.0;
  final mLeft = showDimensions && multiSec ? 24.0 : 8.0;
  final mRight = showDimensions ? 24.0 : 8.0;

  final availW = size.width - mLeft - mRight;
  final availH = size.height - mTop - mBottom;
  if (availW <= 8 || availH <= 8) return _SchemeLayout.empty;

  // ── Соотношение сторон изделия по мм
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

  final frameW = ((pw < ph ? pw : ph) * 0.05).clamp(2.5, 16.0);
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
    // Часть колонок без мм → берём среднее известных (раньше ломалось)
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

  // порядок: обычные секции сверху, сэндвич — внизу (индексы сохраняем)
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

// ═══════════════════════════════════════════════════════════
// ХУДОЖНИК
// ═══════════════════════════════════════════════════════════

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

  // ── Палитра
  static const _frameLight = Color(0xFFFBFDFF);
  static const _frameMid = Color(0xFFE2E9F0);
  static const _frameDark = Color(0xFFA7B4C2);
  static const _outline = Color(0xFF5A6B7C);
  static const _line = Color(0xFF2C3E50);
  static const _dimColor = Color(0xFF6B7A8C);
  static const _wall = Color(0xFFEDF1F5);
  static const _wallHatch = Color(0xFFC9D2DB);
  static const _panel = Color(0xFFD5DBE2);
  static const _panelHatch = Color(0xFFB4BDC7);
  static const _net = Color(0xFF2E7D32);
  static const _accent = Color(0xFF1E88E5);

  @override
  void paint(Canvas canvas, Size size) {
    final layout = schemeLayout(
      size,
      columns,
      showDimensions,
      widthMm: widthMm,
      heightMm: heightMm,
    );
    final product = layout.product;
    if (product.width <= 4 || product.height <= 4) return;

    final frameW = layout.frameW;
    final sashW = frameW * 0.55;
    final mullW = frameW * 0.85;

    final frameGrad = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_frameLight, _frameMid, _frameDark],
      stops: [0.0, 0.62, 1.0],
    ).createShader(product);

    // ── Простенок под короткими колонками (балконный блок)
    for (final c in layout.cols) {
      final below = Rect.fromLTWH(
        c.rect.left,
        c.rect.bottom,
        c.rect.width,
        product.bottom - c.rect.bottom,
      );
      if (below.height > 0.5) _paintWall(canvas, below);
    }

    // ── Силуэт изделия
    if (layout.cols.isEmpty) {
      final rr = RRect.fromRectAndRadius(product, Radius.circular(frameW * 0.6));
      canvas.drawRRect(rr, Paint()..shader = frameGrad);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      _paintGlass(canvas, product.deflate(frameW));
      _paintDimensions(canvas, layout);
      return;
    }

    final silhouette = _silhouettePath(layout);
    canvas.drawPath(silhouette, Paint()..shader = frameGrad);
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Стекло по колонкам (база, чтобы не было разрывов)
    for (final c in layout.cols) {
      if (c.glass.width > 1 && c.glass.height > 1) _paintGlass(canvas, c.glass);
    }

    // ── Импосты между колонками (только на общей высоте)
    for (var i = 0; i < layout.cols.length - 1; i++) {
      final a = layout.cols[i];
      final b = layout.cols[i + 1];
      final bot = product.top +
          (a.rect.height < b.rect.height ? a.rect.height : b.rect.height);
      _paintMullionV(canvas, a.rect.right, product.top, bot, mullW);
    }

    // ── Импосты между секциями внутри колонки
    for (final c in layout.cols) {
      for (var s = 0; s < c.secRects.length - 1; s++) {
        _paintMullionH(
          canvas,
          c.glass.left,
          c.glass.right,
          c.secRects[s].bottom,
          mullW * 0.9,
        );
      }
    }

    // ── Секции
    for (final c in layout.cols) {
      final col = columns[c.index];
      final secs = col.sections.isEmpty ? <Section>[Section()] : col.sections;
      // Створка-полотно балконной двери (стекло + сэндвич): символ
      // открывания рисуется один раз на ВСЮ высоту створки.
      final isLeaf = secs.any((s) => s.type == 'Сэндвич');
      for (var s = 0; s < c.secRects.length; s++) {
        final sec = s < secs.length ? secs[s] : null;
        _paintSection(
          canvas,
          c.secRects[s],
          sec,
          sashW,
          c.hingeLeft,
          drawSymbol: !isLeaf,
          drawHandle: !isLeaf,
        );
      }
      if (isLeaf) _paintLeaf(canvas, c, secs, sashW);
    }

    // ── Вспышка отклика на тап
    _paintFlash(canvas);

    _paintDimensions(canvas, layout);
  }

  // ─────────────────────────────────────────────────────────
  // Силуэт изделия (объединение колонок разной высоты)
  // ─────────────────────────────────────────────────────────
  Path _silhouettePath(_SchemeLayout layout) {
    final path = Path();
    final cols = layout.cols;
    if (cols.isEmpty) return path;
    final top = layout.product.top;
    path.moveTo(cols.first.rect.left, top);
    path.lineTo(cols.last.rect.right, top);
    for (var i = cols.length - 1; i >= 0; i--) {
      path.lineTo(cols[i].rect.right, cols[i].rect.bottom);
      path.lineTo(cols[i].rect.left, cols[i].rect.bottom);
    }
    path.close();
    return path;
  }

  // ─────────────────────────────────────────────────────────
  // Простенок (стена под короткой колонкой балконного блока)
  // ─────────────────────────────────────────────────────────
  void _paintWall(Canvas canvas, Rect rect) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.drawRect(rect, Paint()..color = _wall);
    canvas.save();
    canvas.clipRect(rect);
    final p = Paint()
      ..color = _wallHatch
      ..strokeWidth = 0.9;
    for (var x = rect.left - rect.height; x < rect.right; x += 8) {
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
        ..color = _frameDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Импосты
  // ─────────────────────────────────────────────────────────
  void _paintMullionV(
    Canvas canvas,
    double x,
    double top,
    double bottom,
    double w,
  ) {
    if (bottom - top <= 2 || w <= 0.5) return;
    final r = Rect.fromLTRB(x - w / 2, top, x + w / 2, bottom);
    canvas.drawRect(r, Paint()..color = _frameMid);
    final p = Paint()
      ..color = _outline
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(r.left, top), Offset(r.left, bottom), p);
    canvas.drawLine(Offset(r.right, top), Offset(r.right, bottom), p);
  }

  void _paintMullionH(
    Canvas canvas,
    double left,
    double right,
    double y,
    double w,
  ) {
    if (right - left <= 2 || w <= 0.5) return;
    final r = Rect.fromLTRB(left, y - w / 2, right, y + w / 2);
    canvas.drawRect(r, Paint()..color = _frameMid);
    final p = Paint()
      ..color = _outline
      ..strokeWidth = 0.7;
    canvas.drawLine(Offset(left, r.top), Offset(right, r.top), p);
    canvas.drawLine(Offset(left, r.bottom), Offset(right, r.bottom), p);
  }

  // ─────────────────────────────────────────────────────────
  // Вспышка (визуальный отклик на тап)
  // ─────────────────────────────────────────────────────────
  void _paintFlash(Canvas canvas) {
    final r = flashRect;
    if (r == null) return;
    final t = flashT.clamp(0.0, 1.0);
    if (t >= 1.0) return;
    final k = 1.0 - t; // 1 → 0

    final rr = RRect.fromRectAndRadius(r.deflate(1.5), const Radius.circular(4));

    canvas.drawRRect(rr, Paint()..color = _accent.withOpacity(0.22 * k));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = _accent.withOpacity(0.95 * k)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );

    final label = flashLabel;
    if (label != null && r.width > 40 && r.height > 24) {
      _paintLabel(
        canvas,
        label,
        r.center,
        10.5,
        _accent.withOpacity(0.95 * k),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Стекло
  // ─────────────────────────────────────────────────────────
  void _paintGlass(Canvas canvas, Rect rect) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB4DAF5), Color(0xFFEAF6FF), Color(0xFF9AC2E2)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // Диагональный блик
    final hl = Path()
      ..moveTo(rect.left + rect.width * 0.04, rect.bottom)
      ..lineTo(rect.left + rect.width * 0.44, rect.top)
      ..lineTo(rect.left + rect.width * 0.60, rect.top)
      ..lineTo(rect.left + rect.width * 0.20, rect.bottom)
      ..close();
    canvas.drawPath(hl, Paint()..color = Colors.white.withOpacity(0.38));

    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF7FA3C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Секция (створка / глухая / сэндвич)
  // ─────────────────────────────────────────────────────────
  void _paintSection(
    Canvas canvas,
    Rect rect,
    Section? sec,
    double sashW,
    bool hingeLeft, {
    bool drawSymbol = true,
    bool drawHandle = true,
  }) {
    final type = sec?.type ?? 'Глухая';
    final r = rect.deflate(0.6);
    if (r.width <= 3 || r.height <= 3) return;

    // ── Сэндвич-панель (нижняя глухая часть балконной двери)
    if (type == 'Сэндвич') {
      _paintPanel(canvas, r);
      if (r.width > 16 && r.height > 12) {
        _paintLabel(canvas, 'S', r.center, 12, _line);
      }
      if (sec?.hasMosquito == true) _paintNet(canvas, r);
      return;
    }

    final openable = type == 'Поворотная' ||
        type == 'Откидная' ||
        type == 'Поворотно-откидная';

    if (openable) {
      // Рамка створки
      final rr = RRect.fromRectAndRadius(r, Radius.circular(sashW * 0.8));
      canvas.drawRRect(rr, Paint()..color = _frameLight);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
      final inner = r.deflate(sashW);
      _paintGlass(canvas, inner);
      if (drawSymbol) {
        _paintSymbol(canvas, inner, type, hingeLeft);
        _paintHinges(canvas, inner, hingeLeft);
      }
      if (drawHandle) _paintHandle(canvas, inner, type, hingeLeft);
      if (sec?.hasMosquito == true) _paintNet(canvas, inner);
    } else {
      // Глухая — только штапик по краю стекла
      final inner = r.deflate(sashW * 0.5);
      _paintGlass(canvas, inner);
      canvas.drawRect(
        inner,
        Paint()
          ..color = _frameDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
      if (sec?.hasMosquito == true) _paintNet(canvas, inner);
    }
  }

  // ─────────────────────────────────────────────────────────
  // Символы открывания
  // Вершина (острие) треугольника смотрит на РУЧКУ,
  // широкое основание — на ПЕТЛИ (hingeLeft).
  // Петли рисуются явно: 3 метки по высоте створки.
  // ─────────────────────────────────────────────────────────
  void _paintSymbol(Canvas canvas, Rect rect, String type, bool hingeLeft) {
    if (rect.width <= 8 || rect.height <= 8) return;
    final t = rect.top + rect.height * 0.12;
    final b = rect.bottom - rect.height * 0.12;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final inset = rect.width * 0.16;
    final l = rect.left + inset;
    final r = rect.right - inset;

    switch (type) {
      case 'Глухая':
        // фиксированное остекление — символа нет
        break;
      case 'Поворотная':
        // Вершина → РУЧКА, основание → ПЕТЛИ
        if (hingeLeft) {
          // петли слева, ручка справа → острие вправо
          _triangle(canvas, Offset(r, cy), Offset(l, t), Offset(l, b));
        } else {
          // петли справа, ручка слева → острие влево
          _triangle(canvas, Offset(l, cy), Offset(r, t), Offset(r, b));
        }
        break;
      case 'Откидная':
        _triangle(canvas, Offset(cx, t), Offset(l, b), Offset(r, b));
        break;
      case 'Поворотно-откидная':
        // Поворотная часть — на всю высоту
        if (hingeLeft) {
          _triangle(canvas, Offset(r, cy), Offset(l, t), Offset(l, b));
        } else {
          _triangle(canvas, Offset(l, cy), Offset(r, t), Offset(r, b));
        }
        // Откидная часть — верхняя половина
        final tt = rect.top + rect.height * 0.06;
        final tb = rect.top + rect.height * 0.46;
        _triangle(canvas, Offset(cx, tt), Offset(l, tb), Offset(r, tb));
        break;
      default:
        break;
    }
  }

  void _triangle(Canvas canvas, Offset a, Offset b, Offset c) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = _line.withOpacity(0.10));
    canvas.drawPath(
      path,
      Paint()
        ..color = _line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Створка-полотно балконной двери: символ открывания, ручка и
  // петли — ОДИН раз на всю высоту (стеклопакет + сэндвич-панель).
  // ─────────────────────────────────────────────────────────
  void _paintLeaf(
    Canvas canvas,
    _ColBox c,
    List<Section> secs,
    double sashW,
  ) {
    String? type;
    for (final s in secs) {
      if (s.type != 'Сэндвич') {
        type = s.type;
        break;
      }
    }
    if (type == null || type == 'Глухая') return;

    final rect = c.glass.deflate(sashW);
    if (rect.width <= 10 || rect.height <= 24) return;

    _paintSymbol(canvas, rect, type, c.hingeLeft);
    _paintHandle(canvas, rect, type, c.hingeLeft);
    _paintHinges(canvas, rect, c.hingeLeft);
  }

  // ─────────────────────────────────────────────────────────
  // Петли — явные метки на стороне петель (3 шт. по высоте створки)
  // ─────────────────────────────────────────────────────────
  void _paintHinges(Canvas canvas, Rect inner, bool hingeLeft) {
    if (inner.width < 14 || inner.height < 34) return;
    final hw = (inner.width * 0.05).clamp(2.0, 4.5);
    final hh = (inner.height * 0.05).clamp(4.0, 11.0);
    final x = hingeLeft ? inner.left : inner.right;
    final ys = <double>[
      inner.top + inner.height * 0.13,
      inner.center.dy,
      inner.bottom - inner.height * 0.13,
    ];
    final fill = Paint()..color = const Color(0xFF546E7A);
    final stroke = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final y in ys) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: hw * 2, height: hh),
        Radius.circular(hw * 0.4),
      );
      canvas.drawRRect(rr, fill);
      canvas.drawRRect(rr, stroke);
    }
  }

  // ─────────────────────────────────────────────────────────
  // Ручка — с противоположной от петель стороны
  // ─────────────────────────────────────────────────────────
  void _paintHandle(
    Canvas canvas,
    Rect inner,
    String type,
    bool hingeLeft,
  ) {
    if (!showHandles) return;
    if (type == 'Глухая' || type == 'Сэндвич') return;
    if (inner.width <= 10 || inner.height <= 16) return;

    final hw = (inner.width * 0.075).clamp(3.0, 7.0);
    final hh = (inner.height * 0.12).clamp(10.0, 24.0);

    double cx;
    double cy;
    if (type == 'Откидная') {
      cx = inner.center.dx;
      cy = inner.bottom - hh * 0.6;
    } else {
      cx = hingeLeft ? inner.right - hw * 1.2 : inner.left + hw * 1.2;
      cy = inner.center.dy;
    }

    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: hw, height: hh),
      Radius.circular(hw * 0.45),
    );
    canvas.drawRRect(rr, Paint()..color = const Color(0xFF37474F));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Москитная сетка
  // ─────────────────────────────────────────────────────────
  void _paintNet(Canvas canvas, Rect rect) {
    if (rect.width <= 2 || rect.height <= 2) return;
    canvas.save();
    canvas.clipRect(rect);
    final p = Paint()
      ..color = _net.withOpacity(0.45)
      ..strokeWidth = 0.9;
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
        ..strokeWidth = 1.2,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Панель (сэндвич)
  // ─────────────────────────────────────────────────────────
  void _paintPanel(Canvas canvas, Rect rect) {
    if (rect.width <= 1 || rect.height <= 1) return;
    canvas.drawRect(rect, Paint()..color = _panel);
    canvas.save();
    canvas.clipRect(rect);
    final p = Paint()
      ..color = _panelHatch
      ..strokeWidth = 1.0;
    for (var x = rect.left - rect.height; x < rect.right; x += 7) {
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
        ..color = _frameDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Размеры: снизу — общая ширина, справа — общая высота,
  // сверху — ширины колонок, слева — высоты секций
  // ─────────────────────────────────────────────────────────
  void _paintDimensions(Canvas canvas, _SchemeLayout layout) {
    if (!showDimensions) return;
    final product = layout.product;
    final p = Paint()
      ..color = _dimColor
      ..strokeWidth = 1.0;

    final sumMm = columns.fold<double>(0, (s, c) => s + c.widthMm);
    final wVal = widthMm ?? (sumMm > 0 ? sumMm : null);

    // ── Общая ширина (снизу)
    final yb = product.bottom + 9;
    canvas.drawLine(Offset(product.left, yb), Offset(product.right, yb), p);
    canvas.drawLine(Offset(product.left, yb - 4), Offset(product.left, yb + 4), p);
    canvas.drawLine(
      Offset(product.right, yb - 4),
      Offset(product.right, yb + 4),
      p,
    );
    if (wVal != null && wVal > 0) {
      _paintLabel(
        canvas,
        '${wVal.toInt()}',
        Offset(product.center.dx, yb + 8),
        10,
      );
    }

    // ── Общая высота (справа)
    if (heightMm != null && heightMm! > 0) {
      final xr = product.right + 9;
      canvas.drawLine(Offset(xr, product.top), Offset(xr, product.bottom), p);
      canvas.drawLine(Offset(xr - 4, product.top), Offset(xr + 4, product.top), p);
      canvas.drawLine(
        Offset(xr - 4, product.bottom),
        Offset(xr + 4, product.bottom),
        p,
      );
      canvas.save();
      canvas.translate(xr + 8, product.center.dy);
      canvas.rotate(-1.5707963);
      _paintLabel(canvas, '${heightMm!.toInt()}', Offset.zero, 10);
      canvas.restore();
    }

    // ── Цепочка ширин колонок (сверху)
    if (layout.cols.length > 1) {
      final yt = product.top - 9;
      canvas.drawLine(Offset(product.left, yt), Offset(product.right, yt), p);
      for (final c in layout.cols) {
        canvas.drawLine(Offset(c.rect.left, yt - 4), Offset(c.rect.left, yt + 4), p);
        final mm = _colMm(c.index, wVal);
        if (mm != null && mm > 0 && c.rect.width > 26) {
          _paintLabel(canvas, '${mm.toInt()}', Offset(c.rect.center.dx, yt - 8), 9);
        }
      }
      canvas.drawLine(
        Offset(product.right, yt - 4),
        Offset(product.right, yt + 4),
        p,
      );
    }

    // ── Цепочка высот секций (слева, по самой высокой колонке)
    if (heightMm != null && heightMm! > 0 && layout.cols.isNotEmpty) {
      _ColBox? tall;
      for (final c in layout.cols) {
        if (tall == null || c.rect.height > tall.rect.height) tall = c;
      }
      if (tall != null && tall.secRects.length > 1) {
        final xl = product.left - 9;
        canvas.drawLine(Offset(xl, product.top), Offset(xl, product.bottom), p);
        for (final s in tall.secRects) {
          canvas.drawLine(Offset(xl - 4, s.top), Offset(xl + 4, s.top), p);
          if (s.height > 22) {
            final mm = heightMm! * (s.height / product.height);
            canvas.save();
            canvas.translate(xl - 8, s.center.dy);
            canvas.rotate(-1.5707963);
            _paintLabel(canvas, '${mm.toInt()}', Offset.zero, 9);
            canvas.restore();
          }
        }
        canvas.drawLine(
          Offset(xl - 4, product.bottom),
          Offset(xl + 4, product.bottom),
          p,
        );
      }
    }
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

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize, [
    Color color = _dimColor,
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
