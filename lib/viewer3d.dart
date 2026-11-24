import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'measure_item.dart';

/// Простой 3D-просмотр балконного блока (собственный рендерер, без WebView).
class Viewer3D extends StatefulWidget {
  /// Замер, из которого берётся пропорция балконного блока.
  /// Может быть null — тогда рисуется окно 1:1 (заставка).
  final MeasureItem? item;

  /// true — только чертёж, без заголовка и карточки (для заставки).
  final bool bare;

  const Viewer3D({super.key, this.item, this.bare = false});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D> {
  double _angle = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, '3D-просмотр'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppUi.card(),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() {
                    _angle += d.delta.dx * 0.01;
                  }),
                  child: CustomPaint(
                    painter: _Box3DPainter(
                      angle: _angle,
                      ratio: widget.item.balcony == null
                          ? 1.0
                          : widget.item.balcony!.totalWidth /
                              widget.item.balcony!.totalHeight,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Проведи пальцем — поворот',
                style: TextStyle(color: AppColors.dim, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Box3DPainter extends CustomPainter {
  final double angle;
  final double ratio;
  _Box3DPainter({required this.angle, required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height * 0.6;
    final w = h * ratio;

    // 8 вершин параллелепипеда
    final depth = w * 0.28;
    final cosA = cos(angle);
    final sinA = sin(angle);

    Offset proj(double x, double y, double z) {
      final rx = x * cosA - z * sinA;
      final rz = x * sinA + z * cosA;
      return Offset(cx + rx, cy + y - rz * 0.35);
    }

    final hw = w / 2;
    final hh = h / 2;
    final hd = depth / 2;

    final v = <Offset>[
      proj(-hw, -hh, -hd),
      proj(hw, -hh, -hd),
      proj(hw, hh, -hd),
      proj(-hw, hh, -hd),
      proj(-hw, -hh, hd),
      proj(hw, -hh, hd),
      proj(hw, hh, hd),
      proj(-hw, hh, hd),
    ];

    final face = Paint()
      ..color = AppColors.blue.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    final edge = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    void quad(int a, int b, int c, int d) {
      final path = Path()
        ..moveTo(v[a].dx, v[a].dy)
        ..lineTo(v[b].dx, v[b].dy)
        ..lineTo(v[c].dx, v[c].dy)
        ..lineTo(v[d].dx, v[d].dy)
        ..close();
      canvas.drawPath(path, face);
      canvas.drawPath(path, edge);
    }

    quad(0, 1, 2, 3); // задняя
    quad(4, 5, 6, 7); // передняя
    quad(0, 1, 5, 4); // верх
    quad(3, 2, 6, 7); // низ

    // вертикальная стойка двери
    final mid = proj(0, -hh, -hd);
    final mid2 = proj(0, hh, -hd);
    canvas.drawLine(mid, mid2, edge);
  }

  @override
  bool shouldRepaint(covariant _Box3DPainter old) => old.angle != angle;
}
