import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'measure_history.dart';
import 'measure_item.dart';
import 'measure_sheet.dart';
import 'measure_sizes.dart';
import 'price_estimate.dart';
import 'theme.dart';
import 'window_visual.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  МАСТЕР ЗАМЕРА  ·  v3.4.63
///  Цепочка шагов:
///    КЛИЕНТ → ЧТО ДЕЛАЕМ → РАЗМЕРЫ → ВИЗУАЛЬНЫЙ ЗАМЕР →
///    СМЕТА → ИЗДЕЛИЯ → ЗАМЕРНЫЙ ЛИСТ.
///  На шаге «ВИЗУАЛЬНЫЙ ЗАМЕР» для изделия «БАЛКОННЫЙ БЛОК» вместо
///  панели створок показывается панель БАЛКОННОГО БЛОКА: дверь +
///  глухняк сверху боковой колонны (сэндвич-панель снизу).
/// ═══════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onBack, this.onFinish});

  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ── данные клиента ──
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _addr = TextEditingController();
  final _flat = TextEditingController();
  final _floor = TextEditingController();

  /// Номер текущего шага.
  int _step = 0;

  // ── дерево ──
  List<String> _path = [];
  List<String> _multi = [];

  // ── размеры (пункт → поле → ММ) ──
  Map<String, Map<String, int>> _sizes = {};

  // ── визуальный замер ──
  int _sashManual = 0;
  List<double> _secW = [];
  List<int> _sashModes = [];
  int _glass = -1;
  int _widthMm = 0;
  int _heightMm = 0;

  // ── балконный блок (ММ) ──
  int _bbDoorW = 600;
  int _bbDoorH = 2100;
  int _bbFixedW = 600;
  int _bbFixedH = 500;
  int _doorMode = 1;
  int _fixedMode = 0;
  bool _fixedRight = true;

  // ── изделия замера ──
  List<MeasureItem> _items = [];
  int _editing = -1;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _addr.dispose();
    _flat.dispose();
    _floor.dispose();
    super.dispose();
  }

  // ─────────────────────────── ГЕТТЕРЫ ───────────────────────────

  String get _kind => _path.length > 1 ? _path[1] : '';
  String get _type => _path.length > 2 ? _path[2] : '';

  /// Изделие — БАЛКОННЫЙ БЛОК?
  bool get _balconyBlock => _kind.toUpperCase().contains('БАЛКОННЫЙ');

  /// Изделие на балконе / лоджии (другие надбавки к длинам).
  bool get _balcony {
    final all = [..._path, ..._multi].join(' ').toUpperCase();
    return all.contains('БАЛКОН') ||
        all.contains('ЛОДЖИ') ||
        all.contains('КОЗЫР');
  }

  bool get _arched => _type.toUpperCase().contains('ФИГУРН');

  /// Число створок: ручной выбор, иначе по типу изделия.
  int get _sashCount {
    if (_sashManual > 0) return _sashManual;
    final t = _type.toUpperCase();
    if (t.contains('ТРЁХСТВ') || t.contains('ТРЕХСТВ')) return 3;
    if (t.contains('ДВУХСТВ') || t.contains('ДВУСТВ')) return 2;
    return 1;
  }

  /// Обозначения створок, приведённые к числу створок.
  List<int> get _modes {
    final n = _sashCount;
    final out = List<int>.filled(n, 1);
    for (var i = 0; i < n && i < _sashModes.length; i++) {
      out[i] = _sashModes[i].clamp(0, kSashModeNames.length - 1);
    }
    return out;
  }

  /// Доли ширины секций (сумма ≈ 1.0).
  List<double> get _secWidths {
    final n = _sashCount;
    if (_secW.length == n) {
      final sum = _secW.fold<double>(0, (a, b) => a + b);
      if (sum > 0) return [for (final w in _secW) w / sum];
    }
    return List<double>.filled(n, 1.0 / n);
  }

  String get _glassTitle =>
      (_glass >= 0 && _glass < glassTypes.length) ? glassTypes[_glass].title : '';

  /// Габарит в ММ по названию поля (ищем по всем отмеченным пунктам).
  int _mmOf(String field) {
    if (field == 'ШИРИНА' && _widthMm > 0) return _widthMm;
    if (field == 'ВЫСОТА' && _heightMm > 0) return _heightMm;
    for (final e in _sizes.values) {
      final v = e[field];
      if (v != null && v > 0) return v;
    }
    return 0;
  }

  Estimate get _estimate => buildEstimate(
        widthMm: _widthMm,
        heightMm: _heightMm,
        windowType: _type,
        parts: _multi,
        glass: _glassTitle,
        sizes: _sizes,
      );

  // ─────────────────────────── ИЗДЕЛИЯ ───────────────────────────

  MeasureItem _snapshot() => MeasureItem(
        path: _path,
        multi: _multi,
        sizes: _sizes,
        glass: _glass,
        widthMm: _widthMm,
        heightMm: _heightMm,
        sashModes: _sashModes,
        sashManual: _sashManual,
        secW: _secW,
        doorW: _bbDoorW,
        doorH: _bbDoorH,
        fixedW: _bbFixedW,
        fixedH: _bbFixedH,
        doorMode: _doorMode,
        fixedMode: _fixedMode,
      );

  void _restore(MeasureItem it) {
    _path = List.of(it.path);
    _multi = List.of(it.multi);
    _sizes = it.sizes;
    _glass = it.glass;
    _widthMm = it.widthMm;
    _heightMm = it.heightMm;
    _sashModes = List.of(it.sashModes);
    _sashManual = it.sashManual;
    _secW = List.of(it.secW);
    _bbDoorW = it.doorW;
    _bbDoorH = it.doorH;
    _bbFixedW = it.fixedW;
    _bbFixedH = it.fixedH;
    _doorMode = it.doorMode;
    _fixedMode = it.fixedMode;
  }

  void _clearCurrent() {
    _path = [];
    _multi = [];
    _sizes = {};
    _glass = -1;
    _widthMm = 0;
    _heightMm = 0;
    _sashModes = [];
    _sashManual = 0;
    _secW = [];
    _bbDoorW = 600;
    _bbDoorH = 2100;
    _bbFixedW = 600;
    _bbFixedH = 500;
    _doorMode = 1;
    _fixedMode = 0;
    _fixedRight = true;
  }

  void _commitCurrent() {
    final it = _snapshot();
    if (_editing >= 0 && _editing < _items.length) {
      _items[_editing] = it;
    } else {
      _items.add(it);
      _editing = _items.length - 1;
    }
  }

  void _addItem() {
    _clearCurrent();
    _editing = -1;
    setState(() => _step = 1);
  }

  void _editItem(int i) {
    _restore(_items[i]);
    _editing = i;
    setState(() => _step = 3);
  }

  void _removeItem(int i) {
    setState(() {
      _items.removeAt(i);
      if (_editing == i) {
        _editing = -1;
      } else if (_editing > i) {
        _editing -= 1;
      }
    });
  }

  Future<void> _saveRecord() async {
    final est = _estimate;
    await MeasureHistory.add(MeasureRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      name: _name.text,
      phone: _phone.text,
      addr: _addr.text,
      flat: _flat.text,
      floor: _floor.text,
      path: _path,
      multi: _multi,
      sizes: _sizes,
      glass: _glassTitle,
      widthMm: _widthMm,
      heightMm: _heightMm,
      sashModes: [for (final m in _modes) kSashModeNames[m]],
      total: est.total.round(),
    ));
  }

  // ─────────────────────────── НАВИГАЦИЯ ───────────────────────────

  void _confirmTree() {
    _sashModes = [];
    _sashManual = 0;
    _secW = [];
    _glass = -1;
    _widthMm = 0;
    _heightMm = 0;
    _bbDoorW = 600;
    _bbDoorH = 2100;
    _bbFixedW = 600;
    _bbFixedH = 500;
    _doorMode = 1;
    _fixedMode = 0;
    _fixedRight = true;
    setState(() => _step = 2);
  }

  void _back() {
    if (_step == 0) {
      widget.onBack?.call();
    } else {
      setState(() => _step -= 1);
    }
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HistoryView()),
    );
  }

  static const List<String> _titles = [
    'ДАННЫЕ КЛИЕНТА',
    'ЧТО ДЕЛАЕМ',
    'РАЗМЕРЫ',
    'ВИЗУАЛЬНЫЙ ЗАМЕР',
    'СМЕТА',
    'ИЗДЕЛИЯ',
    'ЗАМЕРНЫЙ ЛИСТ',
  ];

  static const List<IconData> _icons = [
    Icons.person_rounded,
    Icons.account_tree_rounded,
    Icons.straighten_rounded,
    Icons.window_rounded,
    Icons.calculate_rounded,
    Icons.list_alt_rounded,
    Icons.receipt_long_rounded,
  ];

  // ─────────────────────────── КАРКАС ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBg()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(child: _body()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          _RoundButton(icon: Icons.arrow_back_rounded, onTap: _back),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'НОВЫЙ ЗАМЕР',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(_icons[_step], size: 11, color: AppColors.gold),
                    const SizedBox(width: 5),
                    Text(
                      _titles[_step],
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _RoundButton(icon: Icons.history_rounded, onTap: _openHistory),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _clientStep();
      case 1:
        return _treeStep();
      case 2:
        return _sizesStep();
      case 3:
        return _visualStep();
      case 4:
        return _estimateStep();
      case 5:
        return _itemsStep();
      default:
        return _sheetStep();
    }
  }

  // ─────────────────────────── ШАГ 0: КЛИЕНТ ───────────────────────────

  Widget _clientStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      child: _clientCard(),
    );
  }

  Widget _clientCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppUi.cardGrad,
        borderRadius: BorderRadius.circular(AppUi.radius),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
        boxShadow: AppUi.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppUi.radius),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.gold, Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PremiumField(
                    label: 'ИМЯ КЛИЕНТА',
                    hint: 'Иван Петров',
                    icon: Icons.person_rounded,
                    controller: _name,
                  ),
                  const SizedBox(height: 14),
                  _PremiumField(
                    label: 'НОМЕР ТЕЛЕФОНА',
                    hint: '+7 900 000-00-00',
                    icon: Icons.phone_rounded,
                    controller: _phone,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _PremiumField(
                    label: 'АДРЕС ОБЪЕКТА',
                    hint: 'ул. Ленина, 15',
                    icon: Icons.location_on_rounded,
                    controller: _addr,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PremiumField(
                          label: 'КВАРТИРА',
                          hint: '24',
                          icon: Icons.meeting_room_rounded,
                          controller: _flat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PremiumField(
                          label: 'ЭТАЖ',
                          hint: '5',
                          icon: Icons.stairs_rounded,
                          controller: _floor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _GoldButton(
                    label: 'ДАЛЕЕ',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => setState(() => _step = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── ШАГ 1: ЧТО ДЕЛАЕМ ───────────────────────

  Widget _treeStep() {
    return Column(
      children: [
        Expanded(
          child: WorkTreeView(
            onPathChanged: (p) => setState(() => _path = p),
            onMultiChanged: (m) => setState(() => _multi = m),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              _GhostButton(
                'НАЗАД',
                Icons.arrow_back_rounded,
                () => setState(() => _step = 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _multi.isEmpty
                    ? _GoldButton(
                        label: 'В МЕНЮ',
                        icon: Icons.home_rounded,
                        onTap: () => widget.onFinish?.call(),
                      )
                    : _GoldButton(
                        label: 'ПОДТВЕРДИТЬ (${_multi.length})',
                        icon: Icons.check_rounded,
                        onTap: _confirmTree,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────── ШАГ 2: РАЗМЕРЫ ───────────────────────

  Widget _sizesStep() {
    return MeasureSizesView(
      items: _multi,
      balcony: _balcony,
      onDone: (s) {
        setState(() {
          _sizes = s;
          _step = 3;
        });
      },
      onBack: () => setState(() => _step = 1),
    );
  }

  // ─────────────────── ШАГ 3: ВИЗУАЛЬНЫЙ ЗАМЕР ───────────────────

  Widget _visualStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Column(
              children: [
                WindowVisual(
                  sashCount: _sashCount,
                  modes: _modes,
                  sectionWidths: _secWidths,
                  widthMm: _widthMm,
                  heightMm: _heightMm,
                  arched: _arched,
                  parts: _multi,
                  balconyBlock: _balconyBlock,
                  doorMode: _doorMode,
                  fixedMode: _fixedMode,
                  doorWidthMm: _bbDoorW,
                  doorHeightMm: _bbDoorH,
                  fixedWidthMm: _bbFixedW,
                  fixedHeightMm: _bbFixedH,
                  fixedRight: _fixedRight,
                  onSashTap: _cycleSash,
                  onBalconyTap: _cycleBalcony,
                  onBalconyEdit: _editBalconyDim,
                ),
                const SizedBox(height: 14),
                _glassPanel(),
                const SizedBox(height: 14),
                if (_balconyBlock) _balconyPanel() else _sashPanel(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              _GhostButton(
                'НАЗАД',
                Icons.arrow_back_rounded,
                () => setState(() => _step = 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoldButton(
                  label: 'СМЕТА',
                  icon: Icons.calculate_rounded,
                  onTap: () => setState(() => _step = 4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _cycleSash(int i) {
    setState(() {
      final m = _modes;
      m[i] = (m[i] + 1) % kSashModeNames.length;
      _sashModes = m;
    });
  }

  void _cycleBalcony(int i) {
    setState(() {
      if (i == 0) {
        _doorMode = (_doorMode + 1) % kSashModeNames.length;
      } else {
        _fixedMode = (_fixedMode + 1) % kSashModeNames.length;
      }
    });
  }

  Future<void> _editBalconyDim(String field) async {
    final cur = field == 'doorW'
        ? _bbDoorW
        : field == 'doorH'
            ? _bbDoorH
            : field == 'fixedW'
                ? _bbFixedW
                : _bbFixedH;
    final ctrl = TextEditingController(text: '$cur');
    final v = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withOpacity(0.35)),
        ),
        title: const Text(
          'РАЗМЕР, ММ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.gold,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.gold,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(hintText: '600'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ОТМЕНА',
                style: TextStyle(color: Color(0xFF7E93AC))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text.trim())),
            child: const Text('ОК', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
    if (v == null || v <= 0) return;
    setState(() {
      if (field == 'doorW') {
        _bbDoorW = v;
      } else if (field == 'doorH') {
        _bbDoorH = v;
      } else if (field == 'fixedW') {
        _bbFixedW = v;
      } else {
        _bbFixedH = v;
      }
    });
  }

  // ── стеклопакет ──
  Widget _glassPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СТЕКЛОПАКЕТ',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < glassTypes.length; i++)
                _chip(
                  glassTypes[i].title,
                  selected: _glass == i,
                  onTap: () => setState(() => _glass = _glass == i ? -1 : i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── створки обычного изделия ──
  Widget _sashPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СТВОРКИ',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var n = 1; n <= 4; n++) ...[
                if (n > 1) const SizedBox(width: 8),
                _chip(
                  '$n',
                  selected: _sashCount == n,
                  onTap: () => _setSashCount(n),
                ),
              ],
            ],
          ),
          if (_sashCount > 1) ...[
            const SizedBox(height: 14),
            const Text(
              'ШИРИНА СЕКЦИЙ',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _sashCount; i++) _secRow(i),
          ],
        ],
      ),
    );
  }

  void _setSashCount(int n) {
    setState(() {
      _sashManual = n;
      _sashModes = List<int>.filled(n, 1);
      _secW = List<double>.filled(n, 1.0 / n);
    });
  }

  Widget _secRow(int i) {
    final mm = _widthMm > 0 ? (_widthMm * _secWidths[i]).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              mm > 0 ? '$mm мм' : '—',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),
          _stepBtn(Icons.remove_rounded, () => _bumpSection(i, -1)),
          const SizedBox(width: 6),
          _stepBtn(Icons.add_rounded, () => _bumpSection(i, 1)),
        ],
      ),
    );
  }

  void _bumpSection(int i, int dir) {
    final n = _sashCount;
    if (n < 2) return;
    final w = List<double>.from(_secWidths);
    final j = i == 0 ? 1 : i - 1;
    const step = 0.05;
    if (dir > 0) {
      if (w[j] - step < 0.10) return;
      w[i] += step;
      w[j] -= step;
    } else {
      if (w[i] - step < 0.10) return;
      w[i] -= step;
      w[j] += step;
    }
    setState(() => _secW = w);
  }

  // ── панель БАЛКОННОГО БЛОКА ──
  Widget _balconyPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'БАЛКОННЫЙ БЛОК',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.gold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _applyStandardBlock,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.gold.withOpacity(0.40)),
                  ),
                  child: const Text(
                    '⚡ СТАНДАРТ',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bbRow('ДВЕРЬ · ШИРИНА', _bbDoorW, 'doorW'),
          _bbRow('ГЛУХНЯК · ШИРИНА', _bbFixedW, 'fixedW'),
          _bbRow('ГЛУХНЯК · ВЫСОТА', _bbFixedH, 'fixedH'),
          _bbRow('ДВЕРЬ · ВЫСОТА', _bbDoorH, 'doorH'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _chip(
                  'ГЛУХОЕ СПРАВА',
                  selected: _fixedRight,
                  onTap: () => setState(() => _fixedRight = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _chip(
                  'ГЛУХОЕ СЛЕВА',
                  selected: !_fixedRight,
                  onTap: () => setState(() => _fixedRight = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bbRow(String label, int value, String field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textDim,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _editBalconyDim(field),
            child: Text(
              '$value мм',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _stepBtn(Icons.remove_rounded, () => _bumpBlock(field, -50)),
          const SizedBox(width: 6),
          _stepBtn(Icons.add_rounded, () => _bumpBlock(field, 50)),
        ],
      ),
    );
  }

  void _bumpBlock(String field, int delta) {
    setState(() {
      if (field == 'doorW') {
        _bbDoorW = (_bbDoorW + delta).clamp(300, 2000);
      } else if (field == 'doorH') {
        _bbDoorH = (_bbDoorH + delta).clamp(1000, 3000);
      } else if (field == 'fixedW') {
        _bbFixedW = (_bbFixedW + delta).clamp(300, 2000);
      } else {
        _bbFixedH = (_bbFixedH + delta).clamp(200, 2000);
      }
    });
  }

  void _applyStandardBlock() {
    setState(() {
      _bbDoorW = 600;
      _bbDoorH = 2100;
      _bbFixedW = 600;
      _bbFixedH = 500;
    });
  }

  // ─────────────────────── ШАГ 4: СМЕТА ───────────────────────

  Widget _estimateStep() {
    return EstimateView(
      estimate: _estimate,
      onBack: () => setState(() => _step = 3),
      onNext: () {
        _commitCurrent();
        setState(() => _step = 5);
      },
    );
  }

  // ─────────────────────── ШАГ 5: ИЗДЕЛИЯ ───────────────────────

  Widget _itemsStep() {
    return Column(
      children: [
        Expanded(
          child: _items.isEmpty
              ? const Center(
                  child: Text(
                    'ИЗДЕЛИЙ ПОКА НЕТ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _itemCard(i),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              _GhostButton('+ ИЗДЕЛИЕ', Icons.add_rounded, _addItem),
              const SizedBox(width: 12),
              Expanded(
                child: _GoldButton(
                  label: 'ЗАМЕРНЫЙ ЛИСТ',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => setState(() => _step = 6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemCard(int i) {
    final it = _items[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: AppUi.cardGrad,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.navy900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _editItem(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    it.balconyBlock
                        ? 'БЛОК ${it.blockWidth} × ${it.doorH} ММ'
                        : (it.widthMm > 0 && it.heightMm > 0
                            ? '${it.widthMm} × ${it.heightMm} ММ'
                            : 'РАЗМЕР НЕ ЗАДАН'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeItem(i),
            child: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFFE07A7A)),
          ),
        ],
      ),
    );
  }

  // ─────────────────── ШАГ 6: ЗАМЕРНЫЙ ЛИСТ ───────────────────

  Widget _sheetStep() {
    return MeasureSheetView(
      name: _name.text,
      phone: _phone.text,
      addr: _addr.text,
      flat: _flat.text,
      floor: _floor.text,
      path: _path,
      multi: _multi,
      sizes: _sizes,
      glass: _glassTitle,
      items: _items,
      sashModes: [for (final m in _modes) kSashModeNames[m]],
      widthMm: _widthMm,
      sectionWidths: _secWidths,
      onBack: () => setState(() => _step = 5),
      onFinish: () {
        _saveRecord();
        widget.onFinish?.call();
      },
    );
  }

  // ─────────────────────────── МЕЛОЧИ ───────────────────────────

  Widget _chip(String text, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldGradient : null,
          color: selected ? null : const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.line,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: selected ? AppColors.navy900 : AppColors.text,
          ),
        ),
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
          color: const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.gold.withOpacity(0.42)),
        ),
        child: Icon(icon, size: 16, color: AppColors.gold),
      ),
    );
  }
}

// ── Премиальный фон ──────────────────────────────────────────────────────────

class _PremiumBg extends StatefulWidget {
  const _PremiumBg();

  @override
  State<_PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<_PremiumBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _BgPainter(_c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;

  const _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = AppUi.bgGrad.createShader(rect),
    );

    // три медленно плывущих орба
    final orbs = <List<dynamic>>[
      [AppColors.gold, 0.30, 0.22, 0.34, 0.16],
      [const Color(0xFF3E7BB8), 0.72, 0.30, 0.40, 0.13],
      [const Color(0xFF8A6A2A), 0.45, 0.78, 0.36, 0.11],
    ];
    for (var i = 0; i < orbs.length; i++) {
      final o = orbs[i];
      final col = o[0] as Color;
      final bx = o[1] as double;
      final by = o[2] as double;
      final br = o[3] as double;
      final ba = o[4] as double;
      final a = t * math.pi * 2 + i * 2.1;
      final cx = size.width * (bx + 0.05 * math.cos(a));
      final cy = size.height * (by + 0.04 * math.sin(a));
      final r = size.shortestSide * br;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(ba), col.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // парящие частицы
    final rnd = math.Random(7);
    for (var i = 0; i < 46; i++) {
      final px = rnd.nextDouble() * size.width;
      final base = rnd.nextDouble() * size.height;
      final spd = 0.4 + rnd.nextDouble() * 1.2;
      final py = (base - t * size.height * spd) % size.height;
      final rr = 0.6 + rnd.nextDouble() * 1.5;
      canvas.drawCircle(
        Offset(px, py),
        rr,
        Paint()
          ..color = AppColors.goldLight.withOpacity(0.10 + rnd.nextDouble() * 0.14),
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ── Поля и кнопки ────────────────────────────────────────────────────────────

class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboard,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focus = FocusNode();
  bool _on = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _on = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navy900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppUi.radiusSm),
        border: Border.all(
          color: _on ? AppColors.gold.withOpacity(0.75) : AppColors.line,
        ),
        boxShadow: _on
            ? [BoxShadow(color: AppColors.gold.withOpacity(0.20), blurRadius: 18)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon,
                  size: 13, color: _on ? AppColors.gold : AppColors.textDim),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _on ? AppColors.gold : AppColors.textDim,
                  fontSize: 9,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboard,
            cursorColor: AppColors.gold,
            cursorWidth: 1.6,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 2),
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF7E93AC), fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatefulWidget {
  const _GoldButton({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapCancel: on ? () => setState(() => _down = false) : null,
      onTapUp: on
          ? (_) {
              setState(() => _down = false);
              widget.onTap!.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: on ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: AppUi.buttonH,
            decoration: BoxDecoration(
              gradient: AppUi.goldGrad,
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              boxShadow: _down
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF1A1206),
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(widget.icon, size: 18, color: const Color(0xFF1A1206)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  const _GhostButton(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
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
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: AppUi.buttonH,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(AppUi.radiusSm),
            border: Border.all(color: AppColors.gold.withOpacity(0.42)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                widget.label,
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

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy800.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold.withOpacity(0.45)),
        ),
        child: Icon(icon, size: 19, color: AppColors.gold),
      ),
    );
  }
}
