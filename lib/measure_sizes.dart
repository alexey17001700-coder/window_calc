import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'measure_item.dart';
import 'theme.dart';

/// Описание одного размерного поля: имя, допуск, подсказка.
class SizeSpec {
  final String field;
  final int minMm;
  final int maxMm;
  final String hint;
  const SizeSpec(this.field, this.minMm, this.maxMm, this.hint);
}

const SizeSpec kWidth = SizeSpec('ШИРИНА', 300, 4000, 'ШИРИНА ПРОЁМА');
const SizeSpec kHeight = SizeSpec('ВЫСОТА', 300, 4000, 'ВЫСОТА ПРОЁМА');
const SizeSpec kSillDepth =
    SizeSpec('ГЛУБИНА ПОДОКОННИКА', 100, 800, 'ГЛУБИНА ПОДОКОННИКА');
const SizeSpec kSillLen =
    SizeSpec('ДЛИНА ПОДОКОННИКА', 300, 4000, 'ДЛИНА ПОДОКОННИКА');
const SizeSpec kEbbDepth = SizeSpec('ГЛУБИНА ОТЛИВА', 50, 600, 'ГЛУБИНА ОТЛИВА');
const SizeSpec kEbbLen = SizeSpec('ДЛИНА ОТЛИВА', 300, 4000, 'ДЛИНА ОТЛИВА');
const SizeSpec kSlopeDepth =
    SizeSpec('ГЛУБИНА ОТКОСА', 40, 600, 'ГЛУБИНА ОТКОСА');
const SizeSpec kSlopeLen = SizeSpec('ДЛИНА ОТКОСА', 300, 4000, 'ДЛИНА ОТКОСА');
const SizeSpec kPsu = SizeSpec('ДЛИНА ПСУЛ', 300, 6000, 'ДЛИНА ПСУЛ');
const SizeSpec kRadius = SizeSpec('РАДИУС', 100, 3000, 'РАДИУС АРКИ');

/// Наборы полей по пунктам комплектации.
const Map<String, List<SizeSpec>> sizeSpecs = {
  'ПРОСТО ОКНО': [kWidth, kHeight],
  'С ПОДОКОННИКОМ': [kSillDepth, kSillLen],
  'С ОТЛИВОМ': [kEbbDepth, kEbbLen],
  'С ОТКОСАМИ': [kSlopeDepth, kSlopeLen],
  'ОТКОСЫ С ДВУХ СТОРОН': [kSlopeDepth, kSlopeLen],
  'АБРИС': [kWidth, kHeight, kRadius],
  'ПСУЛ': [kPsu],
  'ОТМАЗКА': [kWidth, kHeight],
  'ОТМАЗКА С ДВУХ СТОРОН': [kWidth, kHeight],
  'БЕЗ УБОРКИ': [kWidth, kHeight],
  'С УБОРКОЙ': [kWidth, kHeight],
  'С ВЫВОЗОМ МУСОРА': [kWidth, kHeight],
};

/// Надбавки АВТО-длин (мм).
const int kAutoSillWindow = 200;
const int kAutoEbbWindow = 100;
const int kAutoSillBalcony = 100;
const int kAutoEbbBalcony = 100;

/// Пересчёт введённого числа в ММ по ЯВНО выбранной единице.
int mmFrom(String raw, String unit) {
  final n = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
  if (n == null || n <= 0) return 0;
  return unit == 'СМ' ? n * 10 : n;
}

/// Текст ошибки допуска или null.
String? sizeError(int mm, SizeSpec spec) {
  if (mm <= 0) return null;
  if (mm < spec.minMm) return 'МАЛО · МИН ${spec.minMm} ММ';
  if (mm > spec.maxMm) return 'МНОГО · МАКС ${spec.maxMm} ММ';
  return null;
}

/// АВТО-длина от ширины изделия (0 — не считается).
int autoLengthMm(String field, int widthMm, bool balcony) {
  if (widthMm <= 0) return 0;
  if (field == 'ДЛИНА ПОДОКОННИКА') {
    return widthMm + (balcony ? kAutoSillBalcony : kAutoSillWindow);
  }
  if (field == 'ДЛИНА ОТЛИВА') {
    return widthMm + (balcony ? kAutoEbbBalcony : kAutoEbbWindow);
  }
  if (field == 'ДЛИНА ОТКОСА') return widthMm + kAutoEbbWindow;
  return 0;
}

/// Подпись формулы АВТО.
String autoLengthHint(String field, bool balcony) {
  if (field == 'ДЛИНА ПОДОКОННИКА') {
    return balcony ? 'АВТО: ШИРИНА + 100 ММ' : 'АВТО: ШИРИНА + 200 ММ';
  }
  if (field == 'ДЛИНА ОТЛИВА') return 'АВТО: ШИРИНА + 100 ММ';
  if (field == 'ДЛИНА ОТКОСА') return 'АВТО: ШИРИНА + 100 ММ';
  return '';
}

/// Шаг «РАЗМЕРЫ»: по экрану на каждый отмеченный пункт комплектации.
class MeasureSizesView extends StatefulWidget {
  const MeasureSizesView({
    super.key,
    required this.points,
    this.balcony = false,
    this.block,
    this.onDone,
    this.onBack,
  });

  final List<String> points;
  final bool balcony;
  final BalconyBlock? block;
  final void Function(Map<String, Map<String, int>> sizes)? onDone;
  final VoidCallback? onBack;

  @override
  State<MeasureSizesView> createState() => _MeasureSizesViewState();
}

class _MeasureSizesViewState extends State<MeasureSizesView> {
  int _index = 0;
  final Map<String, Map<String, int>> _values = {};
  final Map<String, String> _units = {};
  final Map<String, TextEditingController> _ctrl = {};
  final Set<String> _touched = {};
  late BalconyBlock _block;

  @override
  void initState() {
    super.initState();
    _block = widget.block?.copy() ?? BalconyBlock();
    for (final p in widget.points) {
      _values[p] = {};
      for (final s in _specsFor(p)) {
        _ctrl[_key(p, s.field)] = TextEditingController();
        _units[_key(p, s.field)] = 'ММ';
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _key(String point, String field) => '$point|$field';

  bool _isBlock(String p) => p.contains('БАЛКОННЫЙ БЛОК');

  List<SizeSpec> _specsFor(String p) {
    if (_isBlock(p)) return const [];
    return sizeSpecs[p] ?? const [kWidth, kHeight];
  }

  String get _point => widget.points[_index];

  /// Ширина изделия из любых введённых размеров.
  int get _widthMm {
    for (final p in widget.points) {
      final v = _values[p]?['ШИРИНА'];
      if (v != null && v > 0) return v;
    }
    return 0;
  }

  void _setValue(String point, String field, int mm) {
    setState(() => _values[point]![field] = mm);
  }

  void _onField(String point, SizeSpec spec, String raw) {
    final unit = _units[_key(point, spec.field)] ?? 'ММ';
    final mm = mmFrom(raw, unit);
    _touched.add(_key(point, spec.field));
    _setValue(point, spec.field, mm);
  }

  void _toggleUnit(String point, SizeSpec spec) {
    final k = _key(point, spec.field);
    final next = (_units[k] ?? 'ММ') == 'ММ' ? 'СМ' : 'ММ';
    setState(() => _units[k] = next);
    final raw = _ctrl[k]?.text ?? '';
    if (raw.isNotEmpty) _onField(point, spec, raw);
  }

  /// Подставить АВТО-длины, которые замерщик не трогал руками.
  void _applyAuto() {
    final w = _widthMm;
    if (w <= 0) return;
    for (final p in widget.points) {
      for (final s in _specsFor(p)) {
        final k = _key(p, s.field);
        if (_touched.contains(k)) continue;
        final auto = autoLengthMm(s.field, w, widget.balcony);
        if (auto <= 0) continue;
        _values[p]![s.field] = auto;
        _ctrl[k]?.text = '$auto';
      }
    }
  }

  String? _firstError() {
    for (final p in widget.points) {
      for (final s in _specsFor(p)) {
        final mm = _values[p]?[s.field] ?? 0;
        final err = sizeError(mm, s);
        if (err != null) return 'ПРОВЕРЬ «${s.field}»: $err';
      }
    }
    return null;
  }

  void _next() {
    _applyAuto();
    final err = _firstError();
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (_index < widget.points.length - 1) {
      setState(() => _index++);
      return;
    }
    _finish();
  }

  void _finish() {
    if (_isBlock(_point)) {
      _values[_point] = {
        'ШИРИНА': _block.width,
        'ВЫСОТА': _block.height,
      };
    }
    widget.onDone?.call(_values);
  }

  void _back() {
    if (_index > 0) {
      setState(() => _index--);
    } else {
      widget.onBack?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.points.length;
    final isLast = _index == total - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _progress(total),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: AppUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppUi.sectionTitle(_point),
                  if (_isBlock(_point))
                    _blockSummary()
                  else
                    ..._specsFor(_point).map(_field),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GhostButton(
                label: 'НАЗАД',
                onTap: _back,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GoldButton(
                label: isLast ? 'ГОТОВО' : 'ДАЛЕЕ',
                onTap: _next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _progress(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppUi.label('РАЗМЕРЫ · ТАП ПО ЕДИНИЦЕ'),
            const Spacer(),
            AppUi.label('${_index + 1} / $total', color: AppColors.gold),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(total, (i) {
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
                decoration: BoxDecoration(
                  color: i <= _index ? AppColors.gold : AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _field(SizeSpec spec) {
    final k = _key(_point, spec.field);
    final unit = _units[k] ?? 'ММ';
    final mm = _values[_point]?[spec.field] ?? 0;
    final err = sizeError(mm, spec);
    final auto = autoLengthMm(spec.field, _widthMm, widget.balcony);
    final showAuto = auto > 0 && !_touched.contains(k);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppUi.label(spec.hint),
              const Spacer(),
              if (showAuto) _badge('АВТО'),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleUnit(_point, spec),
                child: _badge(unit, gold: true),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              border: Border.all(
                color: err != null ? AppColors.red : AppColors.line,
                width: err != null ? 1.4 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _ctrl[k],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
              cursorColor: AppColors.gold,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: mm > 0 ? '$mm мм' : null,
                suffixStyle: const TextStyle(
                  color: AppColors.dim,
                  fontSize: 12,
                ),
              ),
              onChanged: (v) => _onField(_point, spec, v),
            ),
          ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                err,
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            )
          else if (showAuto)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                autoLengthHint(spec.field, widget.balcony),
                style: const TextStyle(
                  color: AppColors.dim,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String s, {bool gold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: gold ? const Color(0x22C9A227) : const Color(0x223E7BB8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: gold ? AppColors.gold : AppColors.blue,
          width: 0.8,
        ),
      ),
      child: Text(
        s,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: gold ? AppColors.gold : AppColors.blue,
        ),
      ),
    );
  }

  Widget _blockSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockRow('ДВЕРЬ · ШИРИНА', _block.doorW, (v) => _block.doorW = v),
        _blockRow('ДВЕРЬ · ВЫСОТА', _block.doorH, (v) => _block.doorH = v),
        _blockRow('ГЛУХНЯК · ШИРИНА', _block.fixedW, (v) => _block.fixedW = v),
        _blockRow('ГЛУХНЯК · ВЫСОТА', _block.fixedH, (v) => _block.fixedH = v),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _GhostButton(
                label: '⚡ СТАНДАРТ',
                onTap: () => setState(_block.reset),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GhostButton(
                label: _block.sideText,
                onTap: () => setState(() => _block.doorLeft = !_block.doorLeft),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(AppUi.radiusSm),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sumRow('ГАБАРИТ', _block.sizeText),
              _sumRow('ПЛОЩАДЬ',
                  '${_block.area.toStringAsFixed(2)} м²'),
              _sumRow('ПАНЕЛЬ', '${_block.panelMm} мм'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _blockRow(String label, int value, void Function(int) set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: AppUi.label(label)),
          _stepBtn(Icons.remove_rounded,
              () => setState(() => set((value - 50).clamp(100, 4000).toInt()))),
          SizedBox(
            width: 74,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _stepBtn(Icons.add_rounded, () => setState(() => set((value + 50).clamp(100, 4000)))),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 16, color: AppColors.gold),
      ),
    );
  }

  Widget _sumRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: AppUi.label(label)),
          Text(
            value,
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
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppUi.buttonH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppUi.goldGradient,
          borderRadius: BorderRadius.circular(AppUi.radius),
          boxShadow: const [
            BoxShadow(color: Color(0x55C9A227), blurRadius: 22),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.bg,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppUi.buttonH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x140A1424),
          borderRadius: BorderRadius.circular(AppUi.radius),
          border: Border.all(color: const Color(0x66C9A227)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.goldLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}
