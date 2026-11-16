import 'package:flutter/material.dart';
import 'templates.dart';

/// Схема окна «в лоб»: рама с объёмом, стеклопакеты с бликом,
/// створки с символами открывания, москитные сетки, сэндвич-панели,
/// ручки и размеры в мм.
class WindowScheme extends StatelessWidget {
  final List<SchemeColumn> columns;
  final double width;
  final double height;
  final bool showDimensions;
  final bool showHandles;
  final double? widthMm;
  final double? heightMm;

  const WindowScheme({
    super.key,
    required this.columns,
    this.width = 200,
    this.height = 240,
    this.showDimensions = true,
    this.showHandles = true,
    this.widthMm,
    this.heightMm,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WindowSchemePainter(
        columns: columns,
        showDimensions: showDimensions,
        showHandles: showHandles,
        widthMm: widthMm,
        heightMm: heightMm,
      ),
    );
  }
}

class _WindowSchemePainter extends CustomPainter {
  final List<SchemeColumn> columns;
  final bool showDimensions;
  final bool showHandles;
  final double? widthMm;
  final double? heightMm;

  _WindowSchemePainter({
    required this.columns,
    required this.showDimensions,
    required this.showHandles,
    this.widthMm,
    this.heightMm,
  });

  // ── Палитра
  static const _frameLight = Color(0xFFFBFDFF);
  static const _frameMid = Color(0xFFE2E9F0);
  static const _frameDark = Color(0xFFA7B4C2);
  static const _outline = Color(0xFF5A6B7C);
  static const _line = Color(0xFF2C3E50);
  static const _dimColor = Color(0xFF6B7A8C);
  static const _wall = Color(0xFFE9EDF2);
  static const _panel = Color(0xFFD5DBE2);
  static const _panelHatch = Color(0xFFB4BDC7);
  static const _net = Color(0xFF2E7D32);

  @override
  void paint(Canvas canvas, Size size) {
    final dimSpace = showDimensions ? 20.0 : 6.0;
    final left = 6.0;
    final top = 6.0;
    final right = size.width - 6.0 - (showDimensions ? 20.0 : 0.0);
    final bottom = size.height - 6.0 - (showDimensions ? 20.0 : 0.0);
    final w = right - left;
    final h = bottom - top;
    if (w <= 6 || h <= 6) return;

    final frameW = (w < h ? w : h) * 0.055;
    final sashW = frameW * 0.8;

    // ── Проём в стене
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left - 3, top - 3, w + 6, h + 6),
        const Radius.circular(3),
      ),
      Paint()..color = _wall,
    );

    // ── Рама (объёмный градиент)
    final frameRect = Rect.fromLTWH(left, top, w, h);
    final frameRRect = RRect.fromRectAndRadius(
      frameRect,
      Radius.circular(frameW * 0.6),
    );
    canvas.drawRRect(
      frameRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_frameLight, _frameMid, _frameDark],
          stops: [0.0, 0.62, 1.0],
        ).createShader(frameRect),
    );
    canvas.drawRRect(
      frameRRect,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Стекло по всему проёму
    final glassRect = frameRect.deflate(frameW);
    _paintGlass(canvas, glassRect);

    if (columns.isEmpty) {
      _paintDimensions(canvas, left, top, w, h);
      return;
    }

    // ── Пропорции колонок
    final totalMm = columns.fold<double>(
      0,
      (s, c) => s + (c.widthMm > 0 ? c.widthMm : 0),
    );
    final useMm = totalMm > 0;
    final colWidths = <double>[];
    for (final c in columns) {
      if (useMm && c.widthMm > 0) {
        colWidths.add(glassRect.width * (c.widthMm / totalMm));
      } else {
        colWidths.add(glassRect.width / columns.length);
      }
    }

    // ── Колонки и секции
    var x = glassRect.left;
    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      final cw = colWidths[i];
      var ratio = col.heightRatio;
      if (ratio <= 0) ratio = 1.0;
      if (ratio > 1.0) ratio = 1.0;
      final colH = glassRect.height * ratio;

      // Пустота под короткой колонкой — панель
      if (colH < glassRect.height - 0.5) {
        _paintPanel(
          canvas,
          Rect.fromLTWH(x, glassRect.top + colH, cw, glassRect.height - colH),
        );
      }

      final n = col.sections.isEmpty ? 1 : col.sections.length;
      final secH = colH / n;
      for (var s = 0; s < n; s++) {
        final secRect = Rect.fromLTWH(x, glassRect.top + secH * s, cw, secH);
        final sec = col.sections.isEmpty ? null : col.sections[s];
        _paintSash(canvas, secRect, sec, sashW);
      }

      // Импост между колонками
      if (i < columns.length - 1) {
        final ix = x + cw;
        canvas.drawLine(
          Offset(ix, glassRect.top),
          Offset(ix, glassRect.bottom),
          Paint()
            ..color = _frameMid
            ..strokeWidth = frameW * 0.9,
        );
        canvas.drawLine(
          Offset(ix, glassRect.top),
          Offset(ix, glassRect.bottom),
          Paint()
            ..color = _outline
            ..strokeWidth = 0.7,
        );
      }

      x += cw;
    }

    _paintDimensions(canvas, left, top, w, h);
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
  // Створка / секция
  // ─────────────────────────────────────────────────────────
  void _paintSash(Canvas canvas, Rect rect, Section? sec, double sashW) {
    final type = sec?.type ?? 'Глухая';
    final r = rect.deflate(1.2);
    if (r.width <= 3 || r.height <= 3) return;

    // Сэндвич-панель (глухая часть балконного блока)
    if (type == 'Сэндвич') {
      _paintPanel(canvas, r);
      _paintLabel(canvas, 'S', r.center, 13, _line);
      if (sec?.hasMosquito == true) _paintNet(canvas, r);
      return;
    }

    // Рамка створки
    final sashRRect = RRect.fromRectAndRadius(
      r.deflate(sashW * 0.5),
      Radius.circular(sashW * 0.7),
    );
    canvas.drawRRect(sashRRect, Paint()..color = _frameLight);
    canvas.drawRRect(
      sashRRect,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Стеклопакет
    final inner = r.deflate(sashW);
    _paintGlass(canvas, inner);

    // Символ открывания
    _paintSymbol(canvas, inner, type);

    // Ручка
    _paintHandle(canvas, inner, type);

    // Москитная сетка
    if (sec?.hasMosquito == true) _paintNet(canvas, inner);
  }

  // ─────────────────────────────────────────────────────────
  // Символы открывания (по ГОСТ-логике: вершина — сторона петель)
  // ─────────────────────────────────────────────────────────
  void _paintSymbol(Canvas canvas, Rect rect, String type) {
    if (rect.width <= 6 || rect.height <= 6) return;
    final l = rect.left + rect.width * 0.14;
    final r = rect.right - rect.width * 0.14;
    final t = rect.top + rect.height * 0.10;
    final b = rect.bottom - rect.height * 0.10;
    final cx = rect.center.dx;
    final cy = rect.center.dy;

    switch (type) {
      case 'Глухая':
        // фиксированное остекление — символа нет
        break;
      case 'Поворотная':
        _triangle(canvas, Offset(l, cy), Offset(r, t), Offset(r, b));
        break;
      case 'Откидная':
        _triangle(canvas, Offset(cx, t), Offset(l, b), Offset(r, b));
        break;
      case 'Поворотно-откидная':
        _triangle(canvas, Offset(l, cy), Offset(r, t), Offset(r, b));
        _triangle(canvas, Offset(cx, t), Offset(l, b), Offset(r, b));
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
  // Ручка
  // ─────────────────────────────────────────────────────────
  void _paintHandle(Canvas canvas, Rect inner, String type) {
    if (!showHandles) return;
    if (type == 'Глухая' || type == 'Сэндвич') return;
    if (inner.width <= 8 || inner.height <= 12) return;

    final hw = (inner.width * 0.07).clamp(3.0, 7.0);
    final hh = (inner.height * 0.11).clamp(9.0, 22.0);

    double cx;
    double cy;
    if (type == 'Откидная') {
      cx = inner.center.dx;
      cy = inner.bottom - hh * 0.55;
    } else {
      cx = inner.right - hw * 1.1;
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
  // Панель (пустота / сэндвич)
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
  // Размеры
  // ─────────────────────────────────────────────────────────
  void _paintDimensions(Canvas canvas, double left, double top, double w, double h) {
    if (!showDimensions) return;
    final p = Paint()
      ..color = _dimColor
      ..strokeWidth = 1.0;

    // Ширина — снизу
    final y = top + h + 10;
    canvas.drawLine(Offset(left, y), Offset(left + w, y), p);
    canvas.drawLine(Offset(left, y - 4), Offset(left, y + 4), p);
    canvas.drawLine(Offset(left + w, y - 4), Offset(left + w, y + 4), p);

    final sumMm = columns.fold<double>(0, (s, c) => s + c.widthMm);
    final wValue = widthMm ?? (sumMm > 0 ? sumMm : null);
    if (wValue != null && wValue > 0) {
      _paintLabel(canvas, '${wValue.toInt()} мм', Offset(left + w / 2, y + 9), 10);
    }

    // Высота — справа (повёрнуто)
    if (heightMm != null && heightMm! > 0) {
      final x = left + w + 10;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), p);
      canvas.drawLine(Offset(x - 4, top), Offset(x + 4, top), p);
      canvas.drawLine(Offset(x - 4, top + h), Offset(x + 4, top + h), p);
      canvas.save();
      canvas.translate(x, top + h / 2);
      canvas.rotate(-1.5707963);
      _paintLabel(canvas, '${heightMm!.toInt()}', Offset.zero, 10);
      canvas.restore();
    }
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
      old.heightMm != heightMm;
}
