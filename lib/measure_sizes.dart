import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ШАГ «РАЗМЕРЫ»  ·  v3.4.26
///  По одному экрану на КАЖДЫЙ отмеченный пункт комплектации.
///  Единицу (ММ или СМ) замерщик выбирает ЯВНО — тапом по бейджу.
///  Программа больше НЕ угадывает единицу по величине числа.
///  Плюс проверка разумности: размер вне допуска не пропускается.
/// ═══════════════════════════════════════════════════════════════════

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

/// ═══════════════════════════════════════════════════════════════════
///  ЭКРАН ВВОДА РАЗМЕРОВ: пункт за пунктом, каждый — отдельное окно
/// ═══════════════════════════════════════════════════════════════════
class MeasureSizesView extends StatefulWidget {
  const MeasureSizesView({
    super.key,
    required this.items,
    required this.onDone,
    required this.onBack,
    this.balcony = false,
  });

  /// Отмеченные пункты комплектации — по одному экрану на каждый.
  final List<String> items;

  /// Изделие на балконе / лоджии / балконный блок: у подоконника, отлива
  /// и козырька другие надбавки к длине.
  final bool balcony;

  /// Готово: размеры по пунктам, уже в МИЛЛИМЕТРАХ.
  final ValueChanged<Map<String, Map<String, int>>> onDone;

  /// Выход назад — к дереву.
  final VoidCallback onBack;

  @override
  State<MeasureSizesView> createState() => _MeasureSizesViewState();
}

class _MeasureSizesViewState extends State<MeasureSizesView> {
  /// Номер текущего пункта.
  int _i = 0;

  /// Контроллеры полей: ключ «пункт|поле».
  final Map<String, TextEditingController> _c = {};

  /// Выбранная единица по полю: ключ «пункт|поле» → ММ или СМ.
  final Map<String, String> _unit = {};

  /// Итог в миллиметрах: пункт → поле → мм.
  final Map<String, Map<String, int>> _mm = {};

  /// Ключи полей, заполненных АВТОМАТИЧЕСКИ (замерщик их не трогал).
  final Set<String> _auto = {};

  /// Пункт-«габарит изделия»: показывается, когда ни один отмеченный
  /// пункт не даёт ШИРИНУ (например, отмечен только подоконник).
  /// От него считаются АВТО-длины подоконника, отлива и козырька.
  static const String _gabaritKey = 'ГАБАРИТ ИЗДЕЛИЯ';

  static const List<SizeSpec> _gabaritSpecs = [
    SizeSpec('ШИРИНА', '1300', minMm: 300, maxMm: 8000),
    SizeSpec('ВЫСОТА', '1400', minMm: 300, maxMm: 4000),
  ];

  /// Нужен ли блок габарита: ни один пункт не даёт ШИРИНУ.
  bool get _needGabarit =>
      !widget.items.any((i) => _specs(i).any((s) => s.label == 'ШИРИНА'));

  List<SizeSpec> _specs(String item) => sizeSpecs[item] ?? _fallback;

  TextEditingController _ctrl(String item, String field) =>
      _c.putIfAbsent('$item|$field', TextEditingController.new);

  /// Текущая единица поля (по умолчанию — ММ).
  String _unitOf(String item, String field) =>
      _unit['$item|$field'] ?? kUnitMm;

  /// Переключить единицу поля: ММ ↔ СМ.
  void _toggleUnit(String item, String field) {
    setState(() {
      final k = '$item|$field';
      _unit[k] = (_unit[k] ?? kUnitMm) == kUnitMm ? kUnitCm : kUnitMm;
    });
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Ширина изделия в ММ: сначала блок габарита, потом любая ШИРИНА.
  int _widthMm() {
    if (_needGabarit) {
      final g = mmFrom(
        _ctrl(_gabaritKey, 'ШИРИНА').text,
        _unitOf(_gabaritKey, 'ШИРИНА'),
      );
      if (g != null && g > 0) return g;
    }
    for (final e in _mm.values) {
      final v = e['ШИРИНА'];
      if (v != null && v > 0) return v;
    }
    for (final item in widget.items) {
      for (final s in _specs(item)) {
        if (s.label != 'ШИРИНА') continue;
        final v = mmFrom(_ctrl(item, s.label).text, _unitOf(item, s.label));
        if (v != null && v > 0) return v;
      }
    }
    return 0;
  }

  /// Собрать блок «ГАБАРИТ ИЗДЕЛИЯ» (если он показан).
  void _collectGabarit() {
    if (!_needGabarit) return;
    final out = <String, int>{};
    for (final s in _gabaritSpecs) {
      final mm = mmFrom(
        _ctrl(_gabaritKey, s.label).text,
        _unitOf(_gabaritKey, s.label),
      );
      if (mm != null) out[s.label] = mm;
    }
    if (out.isEmpty) {
      _mm.remove(_gabaritKey);
    } else {
      _mm[_gabaritKey] = out;
    }
  }

  /// Подставить АВТО-длину в пункт. Ручной ввод замерщика не трогаем.
  void _applyAuto(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    final field = kAutoLengthField[item];
    if (field == null) return;
    final v = autoLengthMm(
      item: item,
      widthMm: _widthMm(),
      balcony: widget.balcony,
    );
    if (v == null) return;
    final k = '$item|$field';
    final c = _ctrl(item, field);
    if (c.text.trim().isNotEmpty && !_auto.contains(k)) return;
    final txt = '$v';
    if (c.text != txt) c.text = txt;
    _auto.add(k);
  }

  /// Собрать текущий пункт в миллиметрах (с учётом выбранной единицы).
  void _collect(int index) {
    final item = widget.items[index];
    final out = <String, int>{};
    for (final s in _specs(item)) {
      final mm = mmFrom(_ctrl(item, s.label).text, _unitOf(item, s.label));
      if (mm != null) out[s.label] = mm;
    }
    _mm[item] = out;
  }

  /// Проверить текущий пункт: нет ли размеров вне допуска.
  /// Возвращает название первого плохого поля или null.
  String? _badField(int index) {
    final item = widget.items[index];
    for (final s in _specs(item)) {
      final mm = mmFrom(_ctrl(item, s.label).text, _unitOf(item, s.label));
      if (sizeError(mm, s) != null) return s.label;
    }
    if (_needGabarit) {
      for (final s in _gabaritSpecs) {
        final mm = mmFrom(
          _ctrl(_gabaritKey, s.label).text,
          _unitOf(_gabaritKey, s.label),
        );
        if (sizeError(mm, s) != null) return s.label;
      }
    }
    return null;
  }

  void _next() {
    final bad = _badField(_i);
    if (bad != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF3A1620),
            content: Text(
              'ПРОВЕРЬ «$bad»: РАЗМЕР ВНЕ ДОПУСКА',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      return;
    }
    _collect(_i);
    _collectGabarit();
    // АВТО-длина текущего пункта — от ширины изделия.
    _applyAuto(_i);
    _collect(_i);
    if (_i < widget.items.length - 1) {
      // Заранее готовим АВТО-длину следующего пункта.
      _applyAuto(_i + 1);
      setState(() => _i += 1);
    } else {
      widget.onDone(_mm);
    }
  }

  void _back() {
    if (_i > 0) {
      setState(() => _i -= 1);
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          'НИЧЕГО НЕ ВЫБРАНО',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF7E93AC),
          ),
        ),
      );
    }

    final item = widget.items[_i];
    final specs = _specs(item);
    final last = _i == widget.items.length - 1;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _progress(),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF152740), Color(0xFF0B1524)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: AppColors.gold.withOpacity(0.30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.32),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.straighten_rounded,
                                size: 20, color: AppColors.navy900),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'РАЗМЕРЫ · ТАП ПО ЕДИНИЦЕ',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.3,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (var k = 0; k < specs.length; k++) ...[
                        if (k > 0) const SizedBox(height: 12),
                        _SizeField(
                          spec: specs[k],
                          controller: _ctrl(item, specs[k].label),
                          unit: _unitOf(item, specs[k].label),
                          onToggleUnit: () =>
                              _toggleUnit(item, specs[k].label),
                          onChanged: () => setState(() {}),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _SizeGhost(
                _i > 0 ? 'НАЗАД' : 'К ДЕРЕВУ',
                Icons.arrow_back_rounded,
                _back,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SizeGold(
                  last ? 'ГОТОВО' : 'ДАЛЕЕ',
                  last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  _next,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Полоса прогресса: пункт N из M.
  Widget _progress() {
    final n = widget.items.length;
    return Row(
      children: [
        for (var k = 0; k < n; k++)
          Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: k == n - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: k <= _i ? AppColors.gold : const Color(0xFF1B2C44),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          '${_i + 1} / $n',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПОЛЕ РАЗМЕРА: явный выбор ММ/СМ + живой пересчёт + проверка допуска
/// ═══════════════════════════════════════════════════════════════════
class _SizeField extends StatefulWidget {
  const _SizeField({
    required this.spec,
    required this.controller,
    required this.unit,
    required this.onToggleUnit,
    required this.onChanged,
  });

  final SizeSpec spec;
  final TextEditingController controller;

  /// Текущая единица поля: ММ или СМ.
  final String unit;

  /// Переключить единицу (ММ ↔ СМ).
  final VoidCallback onToggleUnit;

  final VoidCallback onChanged;

  @override
  State<_SizeField> createState() => _SizeFieldState();
}

class _SizeFieldState extends State<_SizeField> {
  final FocusNode _fn = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _fn.addListener(() {
      if (_focused != _fn.hasFocus) setState(() => _focused = _fn.hasFocus);
    });
  }

  @override
  void dispose() {
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.controller.text;
    final mm = mmFrom(raw, widget.unit);
    final err = sizeError(mm, widget.spec);
    final bad = err != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: bad
                      ? const Color(0xFFE06A6A)
                      : _focused
                          ? AppColors.gold
                          : const Color(0xFF7E93AC),
                ),
              ),
            ),
            // Переключатель единицы: тап меняет ММ ↔ СМ.
            GestureDetector(
              onTap: widget.onToggleUnit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.gold.withOpacity(0.40)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.swap_horiz_rounded,
                        size: 11, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: bad
                  ? const Color(0xFFE06A6A).withOpacity(0.85)
                  : _focused
                      ? AppColors.gold.withOpacity(0.75)
                      : const Color(0xFF1B2C44),
            ),
            boxShadow: bad
                ? [
                    BoxShadow(
                      color: const Color(0xFFE06A6A).withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : _focused
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _fn,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: AppColors.gold,
            cursorWidth: 1.6,
            onChanged: (_) {
              setState(() {});
              widget.onChanged();
            },
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              // Гасим глобальную заливку темы — фон даёт контейнер.
              filled: false,
              fillColor: Colors.transparent,
              hintText: widget.spec.hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E93AC),
              ),
              suffixText: mm == null ? null : '$mm мм',
              suffixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: bad ? const Color(0xFFE06A6A) : AppColors.gold,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
        if (bad) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 12, color: Color(0xFFE06A6A)),
              const SizedBox(width: 5),
              Text(
                err!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFFE06A6A),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЗОЛОТАЯ КНОПКА
/// ═══════════════════════════════════════════════════════════════════
class _SizeGold extends StatefulWidget {
  const _SizeGold(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SizeGold> createState() => _SizeGoldState();
}

class _SizeGoldState extends State<_SizeGold> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(_down ? 0.20 : 0.38),
                blurRadius: _down ? 12 : 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18, color: AppColors.navy900),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРОЗРАЧНАЯ КНОПКА «НАЗАД»
/// ═══════════════════════════════════════════════════════════════════
class _SizeGhost extends StatefulWidget {
  const _SizeGhost(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SizeGhost> createState() => _SizeGhostState();
}

class _SizeGhostState extends State<_SizeGhost> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.gold.withOpacity(0.42)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
