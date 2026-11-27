import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════
///  НОМЕР ЗАКАЗА  ·  v3.4.104
///  Свой номер у каждого замера, чтобы заказы не путались между собой.
///  Счётчик растёт от 1 вверх и хранится локально (shared_preferences),
///  ключ window_calc_order_seq. Формат номера — «ЗК-0001».
/// ═══════════════════════════════════════════════════════════════════
class OrderNumber {
  static const _key = 'window_calc_order_seq';

  /// Префикс номера заказа. Меняется одной строкой.
  static const prefix = 'ЗК';

  /// Следующий номер: увеличивает счётчик и возвращает «ЗК-0001».
  static Future<String> next() async {
    final sp = await SharedPreferences.getInstance();
    final cur = sp.getInt(_key) ?? 0;
    final n = cur + 1;
    await sp.setInt(_key, n);
    return format(n);
  }

  /// Текущий номер БЕЗ увеличения (0 — заказов ещё не было).
  static Future<int> current() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_key) ?? 0;
  }

  /// «ЗК-0001» — номер с ведущими нулями до 4 знаков.
  static String format(int n) => '$prefix-${n.toString().padLeft(4, '0')}';
}
