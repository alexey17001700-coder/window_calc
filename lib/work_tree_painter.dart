part of 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  КАРТОЧКА С НАЖАТИЕМ: при касании сжимается, при отпускании — назад
/// ═══════════════════════════════════════════════════════════════════
class _PressCard extends StatefulWidget {
  const _PressCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: Duration(milliseconds: _down ? 90 : 190),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЛИНИИ-ВЕТКИ: от правого торца карточки к левому торцу подпункта
/// ═══════════════════════════════════════════════════════════════════
class _EdgePainter extends CustomPainter {
  _EdgePainter(this.edges, this.t);

  final List<List<Rect>> edges;

  /// Фаза бегущего огонька: 0 → 1 (слева направо).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < edges.length; i++) {
      final e = edges[i];
      final p1 = Offset(e[0].right, e[0].center.dy);
      final p2 = Offset(e[1].left, e[1].center.dy);
      final dx = (p2.dx - p1.dx) * 0.5;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(p1.dx + dx, p1.dy, p2.dx - dx, p2.dy, p2.dx, p2.dy);

      // мягкое свечение
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..color = AppColors.gold.withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.6),
      );
      // сама линия
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.gold.withOpacity(0.55),
      );

      // ── БЕГУЩИЙ ОГОНЁК: свечение идёт слева направо ──
      // у каждой ветки своя фаза — линии «переливаются» по очереди
      final phase = (t + i * 0.13) % 1.0;
      for (final m in path.computeMetrics()) {
        final len = m.length;
        if (len <= 1) continue;

        final head = phase * len;
        const tail = 52.0;
        final start = (head - tail).clamp(0.0, len);

        if (head - start > 1.5) {
          final from = m.getTangentForOffset(start)?.position;
          final to = m.getTangentForOffset(head)?.position;
          if (from != null && to != null) {
            canvas.drawPath(
              m.extractPath(start, head),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.4
                ..strokeCap = StrokeCap.round
                ..shader = LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.gold.withOpacity(0.0),
                    AppColors.goldLight.withOpacity(0.85),
                    Colors.white.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ).createShader(Rect.fromPoints(from, to)),
            );
          }
        }

        // головка-искра
        final tip = m.getTangentForOffset(head)?.position;
        if (tip != null) {
          canvas.drawCircle(
            tip,
            4.2,
            Paint()
              ..color = AppColors.goldLight.withOpacity(0.45)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2),
          );
          canvas.drawCircle(
              tip, 1.7, Paint()..color = Colors.white.withOpacity(0.95));
        }
      }

      // узелки на концах
      canvas.drawCircle(
          p1, 2.4, Paint()..color = AppColors.gold.withOpacity(0.75));
      canvas.drawCircle(
          p2, 2.0, Paint()..color = AppColors.gold.withOpacity(0.55));
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.t != t || old.edges != edges;
}