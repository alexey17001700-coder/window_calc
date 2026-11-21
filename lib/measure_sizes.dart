import 'package:flutter/material.dart';

import 'theme.dart';

part 'measure_sizes_specs.dart';
part 'measure_sizes_fields.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ШАГ «РАЗМЕРЫ»  ·  v3.4.26
///  По одному экрану на КАЖДЫЙ отмеченный пункт комплектации.
///  Единицу (ММ или СМ) замерщик выбирает ЯВНО — тапом по бейджу.
///  Программа больше НЕ угадывает единицу по величине числа.
///  Плюс проверка разумности: размер вне допуска не пропускается.
/// ═══════════════════════════════════════════════════════════════════

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
                if (_needGabarit && _i == 0) ...[
                  _gabaritCard(),
                  const SizedBox(height: 12),
                ],
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
                          auto: _auto.contains('$item|${specs[k].label}'),
                          autoHint: autoLengthHint(item, widget.balcony),
                          onToggleUnit: () =>
                              _toggleUnit(item, specs[k].label),
                          onChanged: () {
                            // Замерщик правит вручную — АВТО больше не трогаем.
                            _auto.remove('$item|${specs[k].label}');
                            setState(() {});
                          },
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

  /// Блок «ГАБАРИТ ИЗДЕЛИЯ» — база для АВТО-длин подоконника,
  /// отлива и козырька. Показывается, если ни один отмеченный пункт
  /// не даёт ШИРИНУ (например, отмечен только подоконник).
  Widget _gabaritCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.crop_free_rounded,
                  size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ГАБАРИТ ИЗДЕЛИЯ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'ОТ НЕГО СЧИТАЮТСЯ ДЛИНЫ ПОДОКОННИКА, ОТЛИВА И КОЗЫРЬКА',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 14),
          for (var k = 0; k < _gabaritSpecs.length; k++) ...[
            if (k > 0) const SizedBox(height: 12),
            _SizeField(
              spec: _gabaritSpecs[k],
              controller: _ctrl(_gabaritKey, _gabaritSpecs[k].label),
              unit: _unitOf(_gabaritKey, _gabaritSpecs[k].label),
              onToggleUnit: () =>
                  _toggleUnit(_gabaritKey, _gabaritSpecs[k].label),
              onChanged: () => setState(() {}),
            ),
          ],
        ],
      ),
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
