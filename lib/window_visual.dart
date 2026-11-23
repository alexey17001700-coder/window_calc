import 'package:flutter/material.dart';
import 'theme.dart';
import 'measure_item.dart';

/// Шаг «ВИЗУАЛЬНЫЙ ЗАМЕР».
/// Для БАЛКОННОГО БЛОКА — панель размеров двери и глухняка + живой чертёж.
/// Для остальных изделий — панель створок.
class WindowVisual extends StatefulWidget {
  final MeasureItem item;
  final VoidCallback onChanged;

  const WindowVisual({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  State<WindowVisual> createState() => _WindowVisualState();
}

class _WindowVisualState extends State<WindowVisual> {
  BalconyBlock get b => widget.item.balcony ??= BalconyBlock();

  void _bump(String field, double delta) {
    setState(() {
      switch (field) {
        case 'dw':
          b.doorWidth = (b.doorWidth + delta).clamp(300.0, 2000.0).toDouble();
          break;
        case 'dh':
          b.doorHeight = (b.doorHeight + delta).clamp(1000.0, 3000.0).toDouble();
          break;
        case 'bw':
          b.blindWidth = (b.blindWidth + delta).clamp(200.0, 2000.0).toDouble();
          break;
        case 'bh':
          b.blindHeight =
              (b.blindHeight + delta).clamp(200.0, 3000.0).toDouble();
          break;
      }
    });
    widget.onChanged();
  }

  void _cycleGlazing() {
    const order = ['Г', 'П', 'ПО', 'О'];
    final i = order.indexOf(widget.item.glazing);
    widget.item.glazing = order[(i + 1) % order.length];
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.item.isBalcony) return _sashPanel();
    return _balconyPanel();
  }

  // ---------- БАЛКОННЫЙ БЛОК ----------

  Widget _balconyPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Балконный блок'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppUi.card(),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.35,
                child: GestureDetector(
                  onTap: _cycleGlazing,
                  child: CustomPaint(
                    painter: BalconyPainter(b),
                    size: Size.infinite,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Тап по чертежу — обозначение: ${widget.item.glazing}',
                style: const TextStyle(color: AppColors.dim, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _row('ДВЕРЬ · ШИРИНА', b.doorWidth, 'dw'),
        _row('ДВЕРЬ · ВЫСОТА', b.doorHeight, 'dh'),
        _row('ГЛУХНЯК · ШИРИНА', b.blindWidth, 'bw'),
        _row('ГЛУХНЯК · ВЫСОТА', b.blindHeight, 'bh'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _btn(
                '⚡ СТАНДАРТ',
                () {
                  setState(() => b.reset());
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _btn(
                b.blindRight ? 'ГЛУХОЕ СПРАВА' : 'ГЛУХОЕ СЛЕВА',
                () {
                  setState(() => b.blindRight = !b.blindRight);
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: AppUi.card(border: AppColors.gold),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUi.label('Авторасчёт', color: AppColors.gold),
              const SizedBox(height: 8),
              _stat('Габарит блока',
                  '${b.totalWidth.round()} × ${b.totalHeight.round()} мм'),
              _stat('Площадь блока', '${b.area.toStringAsFixed(2)} м²'),
              _stat('Остекление', '${b.glazingArea.toStringAsFixed(2)} м²'),
              _stat('Уплотнитель', '${b.sealLength.toStringAsFixed(1)} м'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, double value, String field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppUi.card(),
      child: Row(
        children: [
          Expanded(child: AppUi.label(label)),
          _stepBtn('−', () => _bump(field, -50)),
          SizedBox(
            width: 78,
            child: Text(
              '${value.round()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _stepBtn('+', () => _bump(field, 50)),
        ],
      ),
    );
  }

  Widget _stepBtn(String t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          t,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _stat(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppColors.dim, fontSize: 12)),
          Text(
            v,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ОБЫЧНОЕ ИЗДЕЛИЕ ----------

  Widget _sashPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Визуальный замер'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppUi.card(),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: GestureDetector(
                  onTap: _cycleGlazing,
                  child: CustomPaint(
                    painter: SashPainter(
                      sashes: widget.item.sashes,
                      glazing: widget.item.glazing,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Створок: ${widget.item.sashes} · обозначение: ${widget.item.glazing}',
                style: const TextStyle(color: AppColors.dim, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppUi.label('Обозначение'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Г', 'П', 'ПО', 'О'].map((g) {
            final active = widget.item.glazing == g;
            return GestureDetector(
              onTap: () {
                widget.item.glazing = g;
                setState(() {});
                widget.onChanged();
              },
              child: Container(
                width: 52,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: active ? AppColors.goldGradient : null,
                  color: active ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.gold : AppColors.line,
                  ),
                ),
                child: Text(
                  g,
                  style: TextStyle(
                    color: active ? const Color(0xFF1A1206) : AppColors.dim,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Чертёж балконного блока: дверь + глухняк, выровненный по верху двери.
class BalconyPainter extends CustomPainter {
  final BalconyBlock b;
  BalconyPainter(this.b);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 34.0;
    final availW = size.width - pad * 2;
    final availH = size.height - pad * 2;
    final scale = [
      availW / b.totalWidth,
      availH / b.totalHeight,
    ].reduce((a, c) => a < c ? a : c);

    final w = b.totalWidth * scale;
    final h = b.totalHeight * scale;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;

    final doorW = b.doorWidth * scale;
    final blindW = b.blindWidth * scale;
    final blindH = b.blindHeight * scale;

    final doorRect = Rect.fromLTWH(
      b.blindRight ? left : left + blindW,
      top,
      doorW,
      h,
    );
    final blindRect = Rect.fromLTWH(
      b.blindRight ? left + doorW : left,
      top,
      blindW,
      blindH,
    );

    final frame = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final glass = Paint()..color = AppColors.blue.withOpacity(0.16);
    final glassLine = Paint()
      ..color = AppColors.blue.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // стекло
    canvas.drawRect(doorRect.deflate(6), glass);
    canvas.drawRect(doorRect.deflate(6), glassLine);
    canvas.drawRect(blindRect.deflate(6), glass);
    canvas.drawRect(blindRect.deflate(6), glassLine);

    // рамы
    canvas.drawRect(doorRect, frame);
    canvas.drawRect(blindRect, frame);

    // ручка двери
    final handle = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final hx = b.blindRight ? doorRect.right - 12 : doorRect.left + 12;
    canvas.drawLine(
      Offset(hx, doorRect.center.dy - 14),
      Offset(hx, doorRect.center.dy + 14),
      handle,
    );

    // размерные линии
    final dim = Paint()
      ..color = AppColors.dim
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void label(String t, Offset at) {
      textPainter.text = TextSpan(
        text: t,
        style: const TextStyle(color: AppColors.dim, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        at - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // габарит сверху
    final yTop = top - 16;
    canvas.drawLine(Offset(left, yTop), Offset(left + w, yTop), dim);
    canvas.drawLine(Offset(left, yTop - 5), Offset(left, yTop + 5), dim);
    canvas.drawLine(Offset(left + w, yTop - 5), Offset(left + w, yTop + 5), dim);
    label('${b.totalWidth.round()}', Offset(left + w / 2, yTop - 12));

    // ширина двери
    label('${b.doorWidth.round()}', Offset(doorRect.center.dx, top + h + 14));
    // ширина глухняка
    label('${b.blindWidth.round()}', Offset(blindRect.center.dx, top + h + 14));

    // высота двери
    final xR = left + w + 16;
    canvas.drawLine(Offset(xR, top), Offset(xR, top + h), dim);
    label('${b.doorHeight.round()}', Offset(xR + 18, top + h / 2));

    // высота глухняка
    final xL = left - 16;
    canvas.drawLine(Offset(xL, top), Offset(xL, top + blindH), dim);
    label('${b.blindHeight.round()}', Offset(xL - 18, top + blindH / 2));
  }

  @override
  bool shouldRepaint(covariant BalconyPainter old) => true;
}

/// Чертёж обычного окна со створками.
class SashPainter extends CustomPainter {
  final int sashes;
  final String glazing;
  SashPainter({required this.sashes, required this.glazing});

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 30.0;
    final rect = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );
    final frame = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final glass = Paint()..color = AppColors.blue.withOpacity(0.16);
    final glassLine = Paint()
      ..color = AppColors.blue.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRect(rect, glass);
    canvas.drawRect(rect, glassLine);
    canvas.drawRect(rect, frame);

    final n = sashes < 1 ? 1 : sashes;
    final sw = rect.width / n;
    for (var i = 1; i < n; i++) {
      canvas.drawLine(
        Offset(rect.left + sw * i, rect.top),
        Offset(rect.left + sw * i, rect.bottom),
        frame,
      );
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: glazing,
      style: const TextStyle(
        color: AppColors.gold,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SashPainter old) =>
      old.sashes != sashes || old.glazing != glazing;
}
