import 'package:flutter/material.dart';
import 'theme.dart';
import 'measure_item.dart';

/// Шаг «РАЗМЕРЫ»: ширина, высота, число створок.
class MeasureSizesView extends StatelessWidget {
  final MeasureItem item;
  final VoidCallback onChanged;

  const MeasureSizesView({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isBalcony) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppUi.sectionTitle(context, 'Размеры'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppUi.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppUi.label('Балконный блок'),
                const SizedBox(height: 8),
                Text(
                  item.sizeText,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Размеры блока задаются на шаге «ВИЗУАЛЬНЫЙ ЗАМЕР».',
                  style: TextStyle(color: AppColors.dim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Размеры проёма'),
        Row(
          children: [
            Expanded(
              child: _numField(
                'ШИРИНА, ММ',
                item.width,
                (v) {
                  item.width = v;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numField(
                'ВЫСОТА, ММ',
                item.height,
                (v) {
                  item.height = v;
                  onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppUi.label('Створок'),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((n) {
            final active = item.sashes == n;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  item.sashes = n;
                  onChanged();
                },
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.goldGradient : null,
                    color: active ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? AppColors.gold : AppColors.line,
                    ),
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      color: active ? const Color(0xFF1A1206) : AppColors.dim,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _numField(String label, double value, ValueChanged<double> onSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(label),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value == 0 ? '' : value.round().toString(),
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.text, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.dim),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
          onChanged: (s) => onSet(double.tryParse(s.trim()) ?? 0),
        ),
      ],
    );
  }
}
