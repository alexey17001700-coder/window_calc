import 'package:flutter/material.dart';

class WindowScheme extends StatelessWidget {
  final int sashes;
  final List<String> sashTypes;
  final bool hasMosquito;
  final double width;
  final double height;

  const WindowScheme({
    super.key,
    required this.sashes,
    required this.sashTypes,
    this.hasMosquito = false,
    this.width = 200,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WindowSchemePainter(
        sashes: sashes,
        sashTypes: sashTypes,
        hasMosquito: hasMosquito,
      ),
    );
  }
}

class _WindowSchemePainter extends CustomPainter {
  final int sashes;
  final List<String> sashTypes;
  final bool hasMosquito;

  _WindowSchemePainter({
    required this.sashes,
    required this.sashTypes,
    required this.hasMosquito,
  });

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

    final sashWidth = w / sashes;
    for (var i = 1; i < sashes; i++) {
      final x = left + sashWidth * i;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), sashLinePaint);
    }

    for (var i = 0; i < sashes; i++) {
      final sashLeft = left + sashWidth * i;
      final sashRect = Rect.fromLTWH(sashLeft, top, sashWidth, h);
      final type = i < sashTypes.length ? sashTypes[i] : 'Глухая';
      _drawSashSymbol(canvas, sashRect, type, symbolPaint);
    }
  }
    void _drawSashSymbol(Canvas canvas, Rect rect, String type, Paint paint) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final w = rect.width;
    final h = rect.height;
    final pad = 8.0;
    final l = rect.left + pad;
    final t = rect.top + pad;
    final r = rect.right - pad;
    final b = rect.bottom - pad;

    switch (type) {
      case 'Глухая':
        // Крест в центре
        final armX = w * 0.18;
        final armY = h * 0.18;
        canvas.drawLine(Offset(cx - armX, cy), Offset(cx + armX, cy), paint);
        canvas.drawLine(Offset(cx, cy - armY), Offset(cx, cy + armY), paint);
        break;

      case 'Поворотная':
        // Треугольник вершиной влево (от петли справа)
        final path = Path();
        path.moveTo(l, cy);
        path.lineTo(r, t);
        path.lineTo(r, b);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'Откидная':
        // Треугольник вершиной вверх
        final path = Path();
        path.moveTo(cx, t);
        path.lineTo(l, b);
        path.lineTo(r, b);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'Поворотно-откидная':
        // Двойная диагональ + треугольник
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
      // Решётка в центре — знак #
      final sz = w * 0.12;
      final off = sz * 0.6;
      canvas.drawLine(
        Offset(cx - sz, cy - off),
        Offset(cx + sz, cy - off),
        paint,
      );
      canvas.drawLine(
        Offset(cx - sz, cy + off),
        Offset(cx + sz, cy + off),
        paint,
      );
      canvas.drawLine(
        Offset(cx - off, cy - sz),
        Offset(cx - off, cy + sz),
        paint,
      );
      canvas.drawLine(
        Offset(cx + off, cy - sz),
        Offset(cx + off, cy + sz),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WindowSchemePainter old) {
    return old.sashes != sashes ||
        old.sashTypes != sashTypes ||
        old.hasMosquito != hasMosquito;
  }
}
