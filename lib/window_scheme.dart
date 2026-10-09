import 'package:flutter/material.dart';
import 'templates.dart';

class WindowScheme extends StatelessWidget {
  final List<SchemeColumn> columns;
  final double width;
  final double height;

  const WindowScheme({
    super.key,
    required this.columns,
    this.width = 200,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WindowSchemePainter(columns: columns),
    );
  }
}

class _WindowSchemePainter extends CustomPainter {
  final List<SchemeColumn> columns;

  _WindowSchemePainter({required this.columns});

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 4.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;
    final left = padding;
    final top = padding;

    final framePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final sashLinePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final glassPaint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.fill;

    final symbolPaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final fullRect = Rect.fromLTWH(left, top, w, h);
    canvas.drawRect(fullRect, glassPaint);
    canvas.drawRect(fullRect, framePaint);

    if (columns.isEmpty) return;

    final totalWidthMm = columns.fold<double>(0, (s, c) => s + c.widthMm);
    final List<double> colWidths = [];
    for (var i = 0; i < columns.length; i++) {
      if (totalWidthMm > 0 && columns[i].widthMm > 0) {
        colWidths.add(w * (columns[i].widthMm / totalWidthMm));
      } else {
        colWidths.add(w / columns.length);
      }
    }

    var xAcc = left;
    for (var i = 0; i < colWidths.length - 1; i++) {
      xAcc += colWidths[i];
      canvas.drawLine(Offset(xAcc, top), Offset(xAcc, top + h), sashLinePaint);
    }

    var xCol = left;
    for (var c = 0; c < columns.length; c++) {
      final col = columns[c];
      final colW = colWidths[c];
      if (col.sections.length > 1) {
        final sectionH = h / col.sections.length;
        for (var s = 1; s < col.sections.length; s++) {
          final y = top + sectionH * s;
          canvas.drawLine(Offset(xCol, y), Offset(xCol + colW, y), sashLinePaint);
        }
      }
      if (col.sections.isNotEmpty) {
        final sectionH = h / col.sections.length;
        for (var s = 0; s < col.sections.length; s++) {
          final sec = col.sections[s];
          final secRect = Rect.fromLTWH(xCol, top + sectionH * s, colW, sectionH);
          _drawSashSymbol(canvas, secRect, sec.type, symbolPaint, sec.hasMosquito);
        }
      }
      xCol += colW;
    }
  }

  void _drawSashSymbol(Canvas canvas, Rect rect, String type, Paint paint, bool hasMosquito) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final w = rect.width;
    final h = rect.height;
    final pad = 6.0;
    final l = rect.left + pad;
    final t = rect.top + pad;
    final r = rect.right - pad;
    final b = rect.bottom - pad;

    switch (type) {
      case 'Глухая':
        final armX = w * 0.18;
        final armY = h * 0.18;
        canvas.drawLine(Offset(cx - armX, cy), Offset(cx + armX, cy), paint);
        canvas.drawLine(Offset(cx, cy - armY), Offset(cx, cy + armY), paint);
        break;

      case 'Поворотная':
        final path = Path();
        path.moveTo(l, cy);
        path.lineTo(r, t);
        path.lineTo(r, b);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'Откидная':
        final path = Path();
        path.moveTo(cx, t);
        path.lineTo(l, b);
        path.lineTo(r, b);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'Поворотно-откидная':
        canvas.drawLine(Offset(l, t), Offset(r, b), paint);
        canvas.drawLine(Offset(l, b), Offset(r, t), paint);
        final path = Path();
        path.moveTo(cx, t + h * 0.1);
        path.lineTo(cx - w * 0.18, b - h * 0.05);
        path.lineTo(cx + w * 0.18, b - h * 0.05);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'Сэндвич':
        final fill = Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, fill);
        final tp = TextPainter(
          text: const TextSpan(
            text: 'S',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
        break;
    }

    if (hasMosquito) {
      final sz = w * 0.12;
      final off = sz * 0.6;
      canvas.drawLine(Offset(cx - sz, cy - off), Offset(cx + sz, cy - off), paint);
      canvas.drawLine(Offset(cx - sz, cy + off), Offset(cx + sz, cy + off), paint);
      canvas.drawLine(Offset(cx - off, cy - sz), Offset(cx - off, cy + sz), paint);
      canvas.drawLine(Offset(cx + off, cy - sz), Offset(cx + off, cy + sz), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindowSchemePainter old) {
    return old.columns != columns;
  }
}
