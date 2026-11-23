import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';
import 'measure_item.dart';
import 'price_estimate.dart';

/// Шаг «ЗАМЕРНЫЙ ЛИСТ»: сводка по замеру + отправка.
class MeasureSheetView extends StatelessWidget {
  final Measure measure;
  const MeasureSheetView({super.key, required this.measure});

  String asText() {
    final sb = StringBuffer();
    sb.writeln('ЗАМЕРНЫЙ ЛИСТ');
    sb.writeln('Клиент: ${measure.client}');
    if (measure.phone.isNotEmpty) sb.writeln('Телефон: ${measure.phone}');
    if (measure.address.isNotEmpty) sb.writeln('Адрес: ${measure.address}');
    sb.writeln('');
    for (var i = 0; i < measure.items.length; i++) {
      final it = measure.items[i];
      sb.writeln('${i + 1}. ${it.product} (${it.workType})');
      if (it.balcony != null) {
        final b = it.balcony!;
        sb.writeln('   Дверь: ${b.doorWidth.round()} × ${b.doorHeight.round()} мм');
        sb.writeln(
            '   Глухняк: ${b.blindWidth.round()} × ${b.blindHeight.round()} мм '
            '(${b.blindRight ? "справа" : "слева"})');
        sb.writeln(
            '   Габарит блока: ${b.totalWidth.round()} × ${b.totalHeight.round()} мм');
        sb.writeln('   Площадь: ${b.area.toStringAsFixed(2)} м²');
      } else {
        sb.writeln('   Размер: ${it.width.round()} × ${it.height.round()} мм');
        sb.writeln('   Створок: ${it.sashes}, обозначение: ${it.glazing}');
      }
      sb.writeln('   Цена: ${priceFor(it).round()} ₽');
    }
    sb.writeln('');
    sb.writeln('ИТОГО: ${buildEstimate(measure.items).round()} ₽');
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Замерный лист'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppUi.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line('Клиент', measure.client.isEmpty ? '—' : measure.client),
              _line('Телефон', measure.phone.isEmpty ? '—' : measure.phone),
              _line('Адрес', measure.address.isEmpty ? '—' : measure.address),
              _line('Изделий', '${measure.items.length}'),
              _line('Площадь', '${measure.totalArea.toStringAsFixed(2)} м²'),
              _line('Итого', '${buildEstimate(measure.items).round()} ₽'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...measure.items.asMap().entries.map((e) {
          final it = e.value;
          final b = it.balcony;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: AppUi.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.key + 1}. ${it.product}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (b != null) ...[
                  _line('Дверь', '${b.doorWidth.round()} × ${b.doorHeight.round()} мм'),
                  _line('Глухняк',
                      '${b.blindWidth.round()} × ${b.blindHeight.round()} мм'),
                  _line('Сторона', b.blindRight ? 'справа' : 'слева'),
                  _line('Габарит',
                      '${b.totalWidth.round()} × ${b.totalHeight.round()} мм'),
                ] else ...[
                  _line('Размер', '${it.width.round()} × ${it.height.round()} мм'),
                  _line('Створок', '${it.sashes}'),
                  _line('Обозначение', it.glazing),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Share.share(asText()),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
            ),
            child: const Text(
              '📤 ОТПРАВИТЬ',
              style: TextStyle(
                color: Color(0xFF1A1206),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(k, style: const TextStyle(color: AppColors.dim, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
