import 'package:flutter/material.dart';
import 'theme.dart';

/// Дерево работ: вид работ → изделие.
class WorkTreeView extends StatelessWidget {
  final String workType;
  final String product;
  final void Function(String work, String product) onSelect;

  const WorkTreeView({
    super.key,
    required this.workType,
    required this.product,
    required this.onSelect,
  });

  static const Map<String, List<String>> tree = {
    'НОВОЕ ОКНО': ['ОКНО ПВХ', 'БАЛКОННЫЙ БЛОК', 'ДВЕРЬ ПВХ', 'ВИТРАЖ'],
    'ЗАМЕНА РЕЗИНОК': ['ОКНО ПВХ', 'БАЛКОННЫЙ БЛОК'],
    'РЕМОНТ': ['ОКНО ПВХ', 'БАЛКОННЫЙ БЛОК', 'ДВЕРЬ ПВХ'],
    'ОТДЕЛКА': ['ОТКОСЫ', 'ПОДОКОННИК', 'ОТЛИВ'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Что делаем'),
        ...tree.keys.map((w) {
          final active = w == workType;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              onTap: () => onSelect(w, tree[w]!.first),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: AppUi.card(
                  border: active ? AppColors.gold : AppColors.line,
                ),
                child: Row(
                  children: [
                    Icon(
                      active ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: active ? AppColors.gold : AppColors.dim,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        w,
                        style: TextStyle(
                          color: active ? AppColors.text : AppColors.dim,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        AppUi.sectionTitle(context, 'Изделие'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (tree[workType] ?? const []).map((p) {
            final active = p == product;
            return GestureDetector(
              onTap: () => onSelect(workType, p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: active ? AppColors.goldGradient : null,
                  color: active ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: active ? AppColors.gold : AppColors.line,
                  ),
                ),
                child: Text(
                  p,
                  style: TextStyle(
                    color: active ? const Color(0xFF1A1206) : AppColors.dim,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.8,
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
