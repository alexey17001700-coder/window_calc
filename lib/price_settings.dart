import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'price_estimate.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПРАЙС ПО АДРЕСАТУ  ·  v3.4.108
///  У каждого адресата СВОЙ ценник, который замерщик задаёт в настройках:
///   · ДЛЯ СЕБЯ       — всё изделие, цены ПРИБЛИЗИТЕЛЬНЫЕ (монтаж точный);
///   · ДЛЯ КЛИЕНТА    — общая цена изделия;
///   · ДЛЯ МОНТАЖНИКА — цены монтажника за работу.
///  ЗАВОД цен не видит вообще — он сам присылает цены на комплектующие.
///  Прайс не задан → берётся стандартный (PriceBook).
/// ═══════════════════════════════════════════════════════════════════

/// Кому принадлежит прайс.
enum PriceOwner { measurer, client, installer }

extension PriceOwnerInfo on PriceOwner {
  /// Название прайса для настроек.
  String get label => switch (this) {
        PriceOwner.measurer => 'ДЛЯ СЕБЯ',
        PriceOwner.client => 'ДЛЯ КЛИЕНТА',
        PriceOwner.installer => 'ДЛЯ МОНТАЖНИКА',
      };

  /// Подсказка — что это за прайс.
  String get hint => switch (this) {
        PriceOwner.measurer => 'ВСЁ ИЗДЕЛИЕ · ЦЕНЫ ПРИБЛИЗИТЕЛЬНЫЕ',
        PriceOwner.client => 'ОБЩАЯ ЦЕНА ИЗДЕЛИЯ',
        PriceOwner.installer => 'ЦЕНЫ ЗА РАБОТУ МОНТАЖНИКА',
      };

  /// Ключ хранения в shared_preferences.
  String get storeKey => 'window_calc_price_$name';
}

/// Хранилище прайсов по адресатам.
class PriceSettings {
  /// Прайс адресата. Нет записи — стандартный.
  static Future<PriceBookData> load(PriceOwner o) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(o.storeKey);
      if (raw == null || raw.isEmpty) return PriceBookData.standard;
      final j = jsonDecode(raw);
      if (j is! Map) return PriceBookData.standard;
      return PriceBookData.fromJson(Map<String, dynamic>.from(j));
    } catch (_) {
      return PriceBookData.standard;
    }
  }

  /// Сохранить прайс адресата.
  static Future<void> save(PriceOwner o, PriceBookData b) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(o.storeKey, jsonEncode(b.toJson()));
  }

  /// Сбросить прайс адресата к стандартному.
  static Future<void> reset(PriceOwner o) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(o.storeKey);
  }
}
