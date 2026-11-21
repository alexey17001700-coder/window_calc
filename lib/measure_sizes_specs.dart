part of 'measure_sizes.dart';

/// Описание одного поля размера.
class SizeSpec {
  const SizeSpec(
    this.label,
    this.hint, {
    this.minMm = 100,
    this.maxMm = 6000,
  });

  final String label;
  final String hint;

  /// Разумный минимум в ММ — ниже считаем ошибкой ввода.
  final int minMm;

  /// Разумный максимум в ММ — выше считаем ошибкой ввода.
  final int maxMm;
}

/// Наборы полей по пунктам комплектации.
const Map<String, List<SizeSpec>> sizeSpecs = {
  'ПРОСТО ОКНО': [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
  ],
  // Отлив: только ГЛУБИНА (вынос) и ДЛИНА — так и мерят на объекте.
  'С ОТЛИВОМ': [
    SizeSpec('ГЛУБИНА ОТЛИВА', '180', minMm: 50, maxMm: 600),
    SizeSpec('ДЛИНА ОТЛИВА', '1400', minMm: 300, maxMm: 4000),
  ],
  // Подоконник: только ГЛУБИНА и ДЛИНА.
  'С ПОДОКОННИКОМ': [
    SizeSpec('ГЛУБИНА ПОДОКОННИКА', '300', minMm: 100, maxMm: 800),
    SizeSpec('ДЛИНА ПОДОКОННИКА', '1400', minMm: 300, maxMm: 4000),
  ],
  // Откосы: только ГЛУБИНА и ДЛИНА (боковой и верхний считаются
  // по одной глубине — так и мерят на объекте).
  'С ОТКОСАМИ': [
    SizeSpec('ГЛУБИНА ОТКОСА', '150', minMm: 40, maxMm: 600),
    SizeSpec('ДЛИНА ОТКОСА', '1400', minMm: 300, maxMm: 4000),
  ],
  // Козырёк — только на балконе / лоджии. ДЛИНА ставится АВТОМАТИЧЕСКИ:
  // ширина изделия + 200 мм (балкон 3000 → козырёк 3200).
  'КОЗЫРЁК': [
    SizeSpec('ГЛУБИНА КОЗЫРЬКА', '900', minMm: 200, maxMm: 2000),
    SizeSpec('ДЛИНА КОЗЫРЬКА', '3200', minMm: 300, maxMm: 8000),
  ],
  // Козырёк из двух частей: каждая часть = половина + нахлёст 150 мм
  // (балкон 3000 → 3200 → по 1750 мм).
  'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ': [
    SizeSpec('ГЛУБИНА КОЗЫРЬКА', '900', minMm: 200, maxMm: 2000),
    SizeSpec('ДЛИНА ЧАСТИ', '1750', minMm: 300, maxMm: 4000),
  ],
  'АБРИС': [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
    SizeSpec('РАДИУС / УГОЛ', '600', minMm: 100, maxMm: 3000),
  ],
  'ПСУЛ': [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
    SizeSpec('ДЛИНА ПСУЛ', '1400', minMm: 300, maxMm: 4000),
  ],
  'ОТМАЗКА': [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
  ],
  'ОТМАЗКА С ДВУХ СТОРОН': [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
  ],
};

/// Поля по умолчанию, если пункт неизвестен.
const List<SizeSpec> _fallback = [
  SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 4000),
  SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
];

/// ═══════════════════════════════════════════════════════════════════
///  АВТО-ДЛИНА КОМПЛЕКТАЦИИ
///  Длина подоконника, отлива и козырька считается от ШИРИНЫ изделия:
///    • ОКНО:   подоконник = ширина + 200 мм, отлив = ширина + 100 мм;
///    • БАЛКОН: подоконник и отлив = ширина + 100 мм,
///              козырёк = ширина + 200 мм (балкон 3000 → козырёк 3200);
///    • козырёк из двух частей: каждая = половина + нахлёст 150 мм
///              (балкон 3000 → 3200 → по 1750 мм).
///  Значение подставляется в поле, но замерщик может его переписать —
///  тогда АВТО по этому полю больше не срабатывает.
/// ═══════════════════════════════════════════════════════════════════
const int kAutoSillWindow = 200;
const int kAutoEbbWindow = 100;
const int kAutoSillBalcony = 100;
const int kAutoEbbBalcony = 100;
const int kAutoCanopyBalcony = 200;
const int kAutoCanopyOverlap = 150;

/// Поле, которое заполняется автоматически, по пункту комплектации.
const Map<String, String> kAutoLengthField = {
  'С ПОДОКОННИКОМ': 'ДЛИНА ПОДОКОННИКА',
  'С ОТЛИВОМ': 'ДЛИНА ОТЛИВА',
  'КОЗЫРЁК': 'ДЛИНА КОЗЫРЬКА',
  'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ': 'ДЛИНА ЧАСТИ',
};

/// Авто-длина, мм. null — для пункта правила нет или ширина неизвестна.
int? autoLengthMm({
  required String item,
  required int widthMm,
  required bool balcony,
}) {
  if (widthMm <= 0) return null;
  switch (item) {
    case 'С ПОДОКОННИКОМ':
      return widthMm + (balcony ? kAutoSillBalcony : kAutoSillWindow);
    case 'С ОТЛИВОМ':
      return widthMm + (balcony ? kAutoEbbBalcony : kAutoEbbWindow);
    case 'КОЗЫРЁК':
      return balcony ? widthMm + kAutoCanopyBalcony : null;
    case 'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ':
      if (!balcony) return null;
      return ((widthMm + kAutoCanopyBalcony) / 2).round() +
          kAutoCanopyOverlap;
    default:
      return null;
  }
}

/// Подсказка-формула для поля авто-длины.
String autoLengthHint(String item, bool balcony) {
  switch (item) {
    case 'С ПОДОКОННИКОМ':
      return balcony ? 'АВТО: ШИРИНА + 100 ММ' : 'АВТО: ШИРИНА + 200 ММ';
    case 'С ОТЛИВОМ':
      return 'АВТО: ШИРИНА + 100 ММ';
    case 'КОЗЫРЁК':
      return 'АВТО: ШИРИНА + 200 ММ';
    case 'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ':
      return 'АВТО: ПОЛОВИНА + 150 ММ';
    default:
      return '';
  }
}

/// Единицы ввода: замерщик выбирает ЯВНО, программа не угадывает.
const String kUnitMm = 'ММ';
const String kUnitCm = 'СМ';

/// Разбор введённого числа → МИЛЛИМЕТРЫ с ЯВНОЙ единицей.
/// null — поле пустое или в нём мусор.
int? mmFrom(String raw, String unit) {
  final t = raw.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  if (v == null || v <= 0) return null;
  final mm = unit == kUnitCm ? v * 10 : v;
  return mm.round();
}

/// Совместимость: разбор без указания единицы считает ввод в ММ.
int? parseToMm(String raw) => mmFrom(raw, kUnitMm);

/// Совместимость: раньше программа угадывала единицу сама.
/// Теперь единицу выбирает замерщик — функция оставлена для совместимости.
String detectedUnit(String raw) => raw.trim().isEmpty ? '' : kUnitMm;

/// Проверка разумности размера. null — всё в порядке,
/// иначе текст ошибки для замерщика.
String? sizeError(int? mm, SizeSpec spec) {
  if (mm == null) return null;
  if (mm < spec.minMm) return 'МАЛО · МИН ${spec.minMm} ММ';
  if (mm > spec.maxMm) return 'МНОГО · МАКС ${spec.maxMm} ММ';
  return null;
}
