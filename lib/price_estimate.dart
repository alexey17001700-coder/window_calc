import 'package:flutter/material.dart';
import 'theme.dart';
import 'measure_item.dart';

/// Цена изделия, ₽.
double priceFor(MeasureItem it) {
  if (it.isBalcony) {
    final b = it.balcony!;
    // дверь дороже глухняка
    return (b.doorWidth / 1000) * (b.doorHeight / 1000) * 14500 +
        (b.blindWidth / 1000) * (b.blindHeight / 1000) * 9800;
  }
  return it.area * 9800;
}

/// Итог по списку изделий, ₽.
double buildEstimate(List<MeasureItem> items) =>
    items.fold(0.0, (s, i) => s + priceFor(i));

/// Шаг «СМЕТА».
class EstimateView extends StatelessWidget {
  final List<MeasureItem> items;
  const EstimateView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final total = buildEstimate(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Смета'),
        ...items.asMap().entries.map((e) {
          final i = e.key + 1;
          final it = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: AppUi.card(),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      color: Color(0xFF1A1206),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.product,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        it.sizeText,
                        style: const TextStyle(
                          color: AppColors.dim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${priceFor(it).round()} ₽',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppUi.card(border: AppColors.gold),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppUi.label('Итого', color: AppColors.gold, size: 13),
              Text(
                '${total.round()} ₽',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
