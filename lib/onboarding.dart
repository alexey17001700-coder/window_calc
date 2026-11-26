import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'screen_flash.dart';
import 'measure_history.dart';
import 'measure_sizes.dart';
import 'measure_sheet.dart';
import 'price_estimate.dart';
import 'window_visual.dart';
import 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ ЭКРАН  ·  v3.4.17
///  Пять шагов мастера:
///    1) «ДАННЫЕ КЛИЕНТА» — карточка с полями;
///    2) «ЧТО ДЕЛАЕМ» — дерево НА ЭКРАНЕ + мультивыбор комплектации;
///    3) «РАЗМЕРЫ» — по одному экрану на каждый отмеченный пункт,
///       ввод в ММ или СМ (программа определяет сама и переводит в ММ);
///    4) «ВИЗУАЛЬНЫЙ ЗАМЕР» — нарисованное окно + выбор стеклопакета;
///    5) «ЗАМЕРНЫЙ ЛИСТ» — итог в ММ, копирование и отправка листа.
/// ═══════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish, this.onBack});
  final VoidCallback onFinish;

  /// Возврат на главный экран (заставка с проверкой обновлений).
  final VoidCallback? onBack;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _flat = TextEditingController();
  final TextEditingController _floor = TextEditingController();

  /// Пробегающий блик по карточке.
  late final AnimationController _shine;

  /// Шаг мастера: 0 — клиент, 1 — дерево, 2 — размеры, 3 — визуальный замер,
  /// 4 — замерный лист (отправка).
  int _step = 0;

  /// Выбранная цепочка дерева: ЗАМЕР → ОКНО → вид → тип дома.
  List<String> _picked = const [];

  /// Отмеченная комплектация (финальный уровень дерева, мультивыбор).
  List<String> _multi = const [];

  /// Размеры по пунктам комплектации — уже в МИЛЛИМЕТРАХ.
  Map<String, Map<String, int>> _sizes = const {};

  /// Размеры, введённые ТАПОМ ПО ЦИФРЕ прямо на чертеже (ММ).
  /// Ключ — имя поля: ШИРИНА, ВЫСОТА, ШИРИНА ОКНА, ВЫСОТА ОКНА,
  /// ШИРИНА ДВЕРИ.
  Map<String, int> _visSizes = const {};

  /// Выбранный стеклопакет (-1 — не выбран).
  int _glass = -1;

  /// Обозначение каждой створки на чертеже (индекс в kSashModeNames).
  List<int> _sashModes = const [];

  /// Ручное число створок (0 — по типу изделия из дерева).
  int _sashManual = 0;

  /// Доли ширины секций (пусто — секции равные).
  List<double> _secW = const [];

  /// Число петель на каждой створке (пусто — по 2: верхняя и нижняя).
  /// Дополнительные петли замерщик добавляет ВРУЧНУЮ (например, на дверь).
  List<int> _hinges = const [];

  // ─── БАЛКОННЫЙ БЛОК ───
  /// Зеркало: дверь СЛЕВА (иначе окно слева).
  bool _doorOnLeft = false;

  /// Вид балконной двери: 0 — стекло в пол, 1 — стекло + сэндвич,
  /// 2 — стекло + стекло.
  int _doorKind = 1;

  /// Частей в оконной части: 1 — цельный глухарь, 2 — две части.
  int _winParts = 1;

  /// Обозначение частей окна: 0 — глухарь, 1 — створка.
  List<int> _winCellModes = const [0];

  /// Доли ширины частей окна (пусто — поровну).
  List<double> _winSecW = const [];

  static const _doorKindNames = [
    'СТЕКЛО В ПОЛ',
    'СТЕКЛО + СЭНДВИЧ',
    'СТЕКЛО + СТЕКЛО',
  ];

  static const _titles = [
    'ДАННЫЕ КЛИЕНТА',
    'ЧТО ДЕЛАЕМ',
    'РАЗМЕРЫ',
    'ВИЗУАЛЬНЫЙ ЗАМЕР',
    'СМЕТА',
    'ЗАМЕРНЫЙ ЛИСТ',
  ];
  static const _icons = [
    Icons.person_rounded,
    Icons.account_tree_rounded,
    Icons.straighten_rounded,
    Icons.window_rounded,
    Icons.calculate_rounded,
    Icons.receipt_long_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4200))
      ..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    _name.dispose();
    _phone.dispose();
    _addr.dispose();
    _flat.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBg()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: _step == 0
                      ? _cardWrap(h, _cardClient())
                      : _step == 1
                          ? _treeStep()
                          : _step == 2
                              ? _sizesStep()
                              : _step == 3
                                  ? _visualStep()
                                  : _step == 4
                                      ? _estimateStep()
                                      : _sheetStep(),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── ШАПКА ───────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.arrow_back_rounded,
            onTap: _goBack,
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.38),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(_icons[_step], color: AppColors.navy900, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'НОВЫЙ ЗАМЕР',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _titles[_step],
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoundButton(
            icon: Icons.history_rounded,
            onTap: _openHistory,
          ),
        ],
      ),
    );
  }

  // ───────────────────── ОБЁРТКА КАРТОЧКИ (≤50%) ─────────────────────
  Widget _cardWrap(double screenH, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenH * 0.50),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF152740), Color(0xFF0B1524)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.gold.withOpacity(0.30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.50),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.08),
                  blurRadius: 44,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Золотая линия сверху
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.gold,
                          AppColors.bronze,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Пробегающий блик
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (_, __) => CustomPaint(
                        painter: _ShinePainter(_shine.value),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── КАРТОЧКА: КЛИЕНТ ───────────────────────
  Widget _cardClient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle('ДАННЫЕ КЛИЕНТА', 'Кому считаем окна'),
        const SizedBox(height: 18),
        _PremiumField(
          label: 'ИМЯ КЛИЕНТА',
          hint: 'Например: Иванов Иван',
          icon: Icons.person_rounded,
          controller: _name,
        ),
        const SizedBox(height: 13),
        _PremiumField(
          label: 'НОМЕР ТЕЛЕФОНА',
          hint: '+7 900 000-00-00',
          icon: Icons.phone_rounded,
          controller: _phone,
          kb: TextInputType.phone,
        ),
        const SizedBox(height: 13),
        _PremiumField(
          label: 'АДРЕС ОБЪЕКТА',
          hint: 'Улица, дом',
          icon: Icons.location_on_rounded,
          controller: _addr,
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _PremiumField(
                label: 'КВАРТИРА',
                hint: '№',
                icon: Icons.door_front_door_rounded,
                controller: _flat,
                kb: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PremiumField(
                label: 'ЭТАЖ',
                hint: '№',
                icon: Icons.stairs_rounded,
                controller: _floor,
                kb: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _GoldButton('ДАЛЕЕ', Icons.arrow_forward_rounded,
            () => setState(() => _step = 1)),
      ],
    );
  }

  // ─────────────── ШАГ 2: ДЕРЕВО «ЧТО ДЕЛАЕМ» ───────────────
  /// Дерево живёт НА ЭКРАНЕ — без карточки-обёртки, без рамки, от края до края.
  /// Финальный уровень — комплектация: можно отметить один пункт,
  /// несколько или все. Есть отметка → внизу появляется «ПОДТВЕРДИТЬ».
  Widget _treeStep() {
    final hasPick = _multi.isNotEmpty;
    return Column(
      children: [
        Expanded(
          child: WorkTreeView(
            onPathChanged: (titles) => setState(() => _picked = titles),
            onMultiChanged: (items) => setState(() => _multi = items),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _GhostButton('НАЗАД', Icons.arrow_back_rounded,
                  () => setState(() => _step = 0)),
              const SizedBox(width: 12),
              Expanded(
                child: hasPick
                    ? _GoldButton(
                        'ПОДТВЕРДИТЬ (${_multi.length})',
                        Icons.check_rounded,
                        _confirmTree,
                      )
                    : _GoldButton(
                        'ДАЛЕЕ', Icons.arrow_forward_rounded, widget.onFinish),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// «ПОДТВЕРДИТЬ»: выбор по дереву и по клиенту запоминается,
  /// открывается ввод размеров — по одному экрану на каждый пункт.
  void _confirmTree() {
    setState(() {
      _sizes = const {};
      _sashManual = 0;
      _secW = const [];
      _sashModes = const [];
      _hinges = const [];
      _doorOnLeft = false;
      _doorKind = 1;
      _winParts = 1;
      _winCellModes = const [0];
      _winSecW = const [];
      // У изделий с визуалкой шаг «РАЗМЕРЫ» пропускаем — сразу чертёж.
      _step = _hasVisual ? 3 : 2;
    });
  }

  /// Есть ли у выбранного изделия визуальный чертёж.
  /// Изделия с визуалкой (окно, балконный блок, балкон, лоджия, дверь,
  /// фасад) идут СРАЗУ на чертёж — размеры вводятся на нём.
  /// Комплектующие (откосы, отлив, подоконники) и работы (монтаж, ремонт,
  /// рекламации) визуалки не имеют — у них шаг «РАЗМЕРЫ» остаётся.
  bool get _hasVisual {
    if (_picked.length < 2) return false;
    if (_picked[0].toUpperCase() != 'ЗАМЕР') return false;
    const visual = {
      'ОКНО',
      'БАЛКОННЫЙ БЛОК',
      'БАЛКОН',
      'ЛОДЖИЯ',
      'ДВЕРЬ',
      'ФАСАДНОЕ ОСТЕКЛЕНИЕ',
    };
    return visual.contains(_picked[1].toUpperCase());
  }

  /// Балконный блок — окно + балконная дверь в ОДНОЙ раме.
  /// Рисуется отдельным чертежом: окно сверху, дверь во всю высоту,
  /// под окном простенок.
  bool get _isBalcony =>
      _picked.length > 1 && _picked[1].toUpperCase() == 'БАЛКОННЫЙ БЛОК';

  /// Шаг назад: у изделий с визуалкой шаг «РАЗМЕРЫ» пропущен,
  /// поэтому с чертежа возвращаемся сразу к дереву.
  void _goBack() {
    if (_step == 0) {
      widget.onBack?.call();
      return;
    }
    setState(() {
      if (_step == 3 && _hasVisual) {
        _step = 1;
      } else {
        _step -= 1;
      }
    });
  }

  // ─────────────── ШАГ 3: РАЗМЕРЫ ПО ПУНКТАМ ───────────────
  Widget _sizesStep() {
    return MeasureSizesView(
      items: _multi,
      onBack: () => setState(() => _step = 1),
      onDone: (mm) => setState(() {
        _sizes = mm;
        _step = 3;
      }),
    );
  }

  // ──────── ШАГ 4: ВИЗУАЛЬНОЕ ОКНО + ВЫБОР СТЕКЛОПАКЕТА ────────
  Widget _visualStep() => _visualStepOld();

  Widget _visualStepOld() {
    final windowType = _picked.length > 2 ? _picked[2] : '';
    final house = _picked.length > 3 ? _picked[3] : '';
    final sashes = _sashCount;
    final arched = windowType.toUpperCase().contains('ФИГУРН');
    // Обозначения створок: если ещё не заданы — все «поворотные».
    final modes = _sashModes.length == sashes
        ? _sashModes
        : List<int>.filled(sashes, 1);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pickedBar(windowType, house),
                const SizedBox(height: 12),
                // У балконного блока — свой чертёж и свои кнопки (этап 3),
                // панель створок обычного окна ему не нужна.
                if (_isBalcony) ...[
                  _balconyControls(),
                ] else ...[
                  _sashControls(sashes),
                ],
                const SizedBox(height: 12),
                WindowVisual(
                  sashes: _isBalcony ? 1 : sashes,
                  arched: arched,
                  parts: _multi,
                  selectedGlass: _glass,
                  onGlass: (i) => setState(() => _glass = i),
                  sashModes: _isBalcony ? const <int>[1] : modes,
                  widthMm: _mmOf('ШИРИНА'),
                  heightMm: _mmOf('ВЫСОТА'),
                  sectionWidths: _secWidths,
                  hingeCounts: _hingeCounts,
                  balcony: _isBalcony,
                  doorOnLeft: _doorOnLeft,
                  doorKind: _doorKind,
                  winParts: _winParts,
                  winCellModes: _winCellModes,
                  winSectionWidths: _winSecWidths,
                  onWinTap: () => setState(() {
                    _glass = (_glass + 1 >= glassTypes.length
                        ? 0
                        : _glass + 1);
                  }),
                  onDoorTap: () => setState(
                      () => _doorKind = (_doorKind + 1) % _doorKindNames.length),
                  onSashTap: (i) => setState(() {
                    final m = List<int>.from(modes);
                    m[i] = (m[i] + 1) % kSashModeNames.length;
                    _sashModes = m;
                  }),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _GhostButton('НАЗАД', Icons.arrow_back_rounded,
                  () => setState(() => _step = _hasVisual ? 1 : 2)),
              const SizedBox(width: 12),
              Expanded(
                child: _GoldButton('СМЕТА', Icons.calculate_rounded,
                    () => setState(() => _step = 4)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────── ШАГ 5: СМЕТА (ПРАЙС И ИТОГ) ────────────
  /// Считаем стоимость по площади изделия и комплектации.
  /// Прайс — в lib/price_estimate.dart (класс PriceBook).
  Widget _estimateStep() {
    final glass = (_glass >= 0 && _glass < glassTypes.length)
        ? glassTypes[_glass].title
        : '';
    final windowType = _picked.length > 2 ? _picked[2] : '';
    final estimate = buildEstimate(
      widthMm: _mmOf('ШИРИНА'),
      heightMm: _mmOf('ВЫСОТА'),
      windowType: windowType,
      parts: _multi,
      glass: glass,
    );
    return EstimateView(
      estimate: estimate,
      onBack: () => setState(() => _step = 3),
      onNext: () => setState(() => _step = 5),
    );
  }

  // ──────────── ШАГ 6: ЗАМЕРНЫЙ ЛИСТ (ОТПРАВКА) ────────────
  /// Итог: клиент + цепочка дерева + комплектация + стеклопакет +
  /// размеры (уже в МИЛЛИМЕТРАХ). Лист копируется или отправляется.
  Widget _sheetStep() {
    final glass = (_glass >= 0 && _glass < glassTypes.length)
        ? glassTypes[_glass].title
        : '';
    return MeasureSheetView(
      name: _name.text,
      phone: _phone.text,
      addr: _addr.text,
      flat: _flat.text,
      floor: _floor.text,
      path: _picked,
      multi: _multi,
      sizes: _sizes,
      glass: glass,
      widthMm: _mmOf('ШИРИНА'),
      sectionWidths: _secWidths,
      sashModes: [
        for (final m in (_sashModes.length == _sashCount
            ? _sashModes
            : List<int>.filled(_sashCount, 1)))
          kSashModeNames[m.clamp(0, kSashModeNames.length - 1)],
      ],
      onBack: () => setState(() => _step = 4),
      onFinish: () {
        _saveRecord();
        widget.onFinish();
      },
    );
  }

  /// Готовый замер уходит в историю (lib/measure_history.dart).
  Future<void> _saveRecord() async {
    final glass = (_glass >= 0 && _glass < glassTypes.length)
        ? glassTypes[_glass].title
        : '';
    final windowType = _picked.length > 2 ? _picked[2] : '';
    final w = _mmOf('ШИРИНА');
    final h = _mmOf('ВЫСОТА');
    final est = buildEstimate(
      widthMm: w,
      heightMm: h,
      windowType: windowType,
      parts: _multi,
      glass: glass,
    );
    final modes = _sashModes.length == _sashCount
        ? _sashModes
        : List<int>.filled(_sashCount, 1);
    await MeasureHistory.add(MeasureRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      name: _name.text,
      phone: _phone.text,
      addr: _addr.text,
      flat: _flat.text,
      floor: _floor.text,
      path: List<String>.from(_picked),
      multi: List<String>.from(_multi),
      sizes: _sizes,
      glass: glass,
      widthMm: w,
      heightMm: h,
      sashModes: [
        for (final m in modes)
          kSashModeNames[m.clamp(0, kSashModeNames.length - 1)],
      ],
      total: est.total.round(),
    ));
  }

  /// Открыть историю замеров и базу клиентов.
  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryView()),
    );
  }

  /// Сколько створок: ручной выбор замерщика, иначе — по типу изделия.
  int get _sashCount {
    if (_sashManual > 0) return _sashManual;
    final t = (_picked.length > 2 ? _picked[2] : '').toUpperCase();
    if (t.contains('ТРЁХСТВ') || t.contains('ТРЕХСТВ')) return 3;
    if (t.contains('ДВУХСТВ') || t.contains('ДВУСТВ')) return 2;
    return 1;
  }

  /// Доли ширины секций: пусто или не то число — делим поровну.
  List<double> get _secWidths {
    final n = _sashCount;
    if (_secW.length == n) {
      final sum = _secW.fold<double>(0, (a, b) => a + b);
      if (sum > 0) return [for (final w in _secW) w / sum];
    }
    return List<double>.filled(n, 1.0 / n);
  }

  /// Число петель на каждой створке: пусто или не то число — по 2
  /// (верхняя и нижняя). Дополнительные петли замерщик добавляет вручную.
  List<int> get _hingeCounts {
    final n = _sashCount;
    if (_hinges.length == n) return _hinges;
    return List<int>.filled(n, 2);
  }

  /// Изменить ширину секции i: отдаём/забираем долю у соседа.
  void _bumpSection(int i, int dir) {
    final n = _sashCount;
    if (n < 2) return;
    final ws = List<double>.from(_secWidths);
    if (i < 0 || i >= ws.length) return;
    final j = i == 0 ? 1 : i - 1;
    const d = 0.05;
    if (dir > 0) {
      if (ws[j] - d < 0.10) return;
      ws[i] += d;
      ws[j] -= d;
    } else {
      if (ws[i] - d < 0.10) return;
      ws[i] -= d;
      ws[j] += d;
    }
    setState(() => _secW = ws);
  }

  /// Панель створок: число створок (для ЛЮБОГО изделия) + ширина секций.
  Widget _sashControls(int sashes) {
    final total = _mmOf('ШИРИНА');
    final ws = _secWidths;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_column_rounded,
                  size: 15, color: AppColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'СТВОРКИ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: Colors.white,
                  ),
                ),
              ),
              for (var n = 1; n <= 4; n++) ...[
                if (n > 1) const SizedBox(width: 6),
                _SashCountChip(
                  n: n,
                  selected: sashes == n,
                  onTap: () => setState(() {
                    _sashManual = n;
                    _sashModes = List<int>.filled(n, 1);
                    _secW = List<double>.filled(n, 1.0 / n);
                  }),
                ),
              ],
            ],
          ),
          if (sashes > 1) ...[
            const SizedBox(height: 11),
            Row(
              children: [
                const Text(
                  'ШИРИНА СЕКЦИЙ',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF7E93AC),
                  ),
                ),
                const Spacer(),
                Text(
                  total > 0 ? 'ВСЕГО $total ММ' : 'ВВЕДИ ШИРИНУ',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            for (var i = 0; i < sashes; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _SectionWidthRow(
                index: i,
                mm: total > 0 ? (total * ws[i]).round() : 0,
                onMinus: () => _bumpSection(i, -1),
                onPlus: () => _bumpSection(i, 1),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ─────────── ПАНЕЛЬ БАЛКОННОГО БЛОКА (ЭТАП 3) ───────────
  /// Зеркало · вид двери · состав оконной части · ширина частей окна.
  /// Все настройки — кнопками, плюс тап прямо по чертежу.
  Widget _balconyControls() {
    final doorIdx = _doorKind.clamp(0, _doorKindNames.length - 1);
    final preset = _winPreset;
    final ws = _winSecWidthsNorm;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── заголовок + ЗЕРКАЛО ──
          Row(
            children: [
              const Icon(Icons.window_rounded, size: 15, color: AppColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'БАЛКОННЫЙ БЛОК',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: Colors.white,
                  ),
                ),
              ),
              _MirrorBtn(
                doorOnLeft: _doorOnLeft,
                onTap: () => setState(() => _doorOnLeft = !_doorOnLeft),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _doorOnLeft ? 'ДВЕРЬ СЛЕВА · ОКНО СПРАВА' : 'ОКНО СЛЕВА · ДВЕРЬ СПРАВА',
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          _ctrlLabel('ДВЕРЬ'),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _doorKindNames.length; i++)
                _OptChip(
                  label: _doorKindNames[i],
                  selected: doorIdx == i,
                  onTap: () => setState(() => _doorKind = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ctrlLabel('ОКОННАЯ ЧАСТЬ'),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < 3; i++)
                _OptChip(
                  label: const [
                    'ГЛУХАРЬ',
                    'ГЛУХАРЬ + СТВОРКА',
                    'СТВОРКА + СТВОРКА',
                  ][i],
                  selected: preset == i,
                  onTap: () => _setWinPreset(i),
                ),
            ],
          ),
          if (_winParts > 1) ...[
            const SizedBox(height: 11),
            Row(
              children: [
                const Text(
                  'ШИРИНА ЧАСТЕЙ ОКНА',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF7E93AC),
                  ),
                ),
                const Spacer(),
                Text(
                  _balconyWinMm > 0 ? 'ВСЕГО $_balconyWinMm ММ' : 'ВВЕДИ ШИРИНУ',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            for (var i = 0; i < _winParts; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _SectionWidthRow(
                index: i,
                mm: _balconyWinMm > 0
                    ? (_balconyWinMm * ws[i]).round()
                    : 0,
                onMinus: () => _bumpWinSection(i, -1),
                onPlus: () => _bumpWinSection(i, 1),
              ),
            ],
          ],
          const SizedBox(height: 10),
          const Text(
            'ТАП ПО ЧЕРТЕЖУ: ОКНО — СТЕКЛОПАКЕТ, ДВЕРЬ — ВИД НИЗА',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF7E93AC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctrlLabel(String s) => Text(
        s,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Color(0xFF7E93AC),
        ),
      );

  /// Ширина окна балконного блока в ММ (0 — ещё не задана).
  int get _balconyWinMm => _mmOf('ШИРИНА ОКНА');

  /// Доли ширины частей окна: пусто или не то число — поровну.
  List<double> get _winSecWidthsNorm {
    final n = _winParts.clamp(1, 2);
    if (_winSecW.length == n) {
      final sum = _winSecW.fold<double>(0, (a, b) => a + b);
      if (sum > 0) return [for (final w in _winSecW) w / sum];
    }
    return List<double>.filled(n, 1.0 / n);
  }

  /// Изменить ширину части окна i: отдаём/забираем долю у соседа.
  void _bumpWinSection(int i, int dir) {
    final n = _winParts.clamp(1, 2);
    if (n < 2) return;
    final ws = List<double>.from(_winSecWidthsNorm);
    if (i < 0 || i >= ws.length) return;
    final j = i == 0 ? 1 : i - 1;
    const d = 0.05;
    if (dir > 0) {
      if (ws[j] - d < 0.15) return;
      ws[i] += d;
      ws[j] -= d;
    } else {
      if (ws[i] - d < 0.15) return;
      ws[i] -= d;
      ws[j] += d;
    }
    setState(() => _winSecW = ws);
  }

  /// Выбранный состав окна: 0 — цельный глухарь, 1 — глухарь + створка,
  /// 2 — створка + створка.
  int get _winPreset {
    if (_winParts < 2) return 0;
    return _winCellModes.length > 1 && _winCellModes[1] != 0 ? 2 : 1;
  }

  void _setWinPreset(int i) {
    setState(() {
      if (i == 0) {
        _winParts = 1;
        _winCellModes = const [0];
        _winSecW = const [];
      } else if (i == 1) {
        _winParts = 2;
        _winCellModes = const [0, 1];
        _winSecW = const [0.5, 0.5];
      } else {
        _winParts = 2;
        _winCellModes = const [1, 1];
        _winSecW = const [0.5, 0.5];
      }
    });
  }

  /// Габарит в ММ по названию поля (ищем по всем отмеченным пунктам).
  int _mmOf(String field) {
    for (final e in _sizes.values) {
      final v = e[field];
      if (v != null && v > 0) return v;
    }
    return 0;
  }

  /// Плашка выбранного: ОКНО · ДВУХСТВОРЧАТОЕ · КИРПИЧКА
  Widget _pickedBar(String windowType, String house) {
    final parts = <String>[
      if (windowType.isNotEmpty) windowType,
      if (house.isNotEmpty) house,
      ..._multi,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.window_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.isEmpty ? 'ОКНО' : parts.join('  ·  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── ЭЛЕМЕНТЫ ───────────────────────────
  Widget _cardTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7E93AC),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПОЛЕ ВВОДА С ЗОЛОТЫМ СВЕЧЕНИЕМ ПРИ ФОКУСЕ
/// ═══════════════════════════════════════════════════════════════════
class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.kb,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? kb;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(widget.label,
            color: _focused ? AppColors.gold : const Color(0xFF7E93AC),
            size: 9),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused
                  ? AppColors.gold.withOpacity(0.75)
                  : const Color(0xFF1B2C44),
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _fn,
            keyboardType: widget.kb,
            cursorColor: AppColors.gold,
            cursorWidth: 1.6,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              // ВАЖНО: гасим глобальную заливку темы (в светлой теме она белая
              // и «съедала» белый текст). Фон даёт сам контейнер — тёмный.
              filled: false,
              fillColor: Colors.transparent,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E93AC),
              ),
              prefixIcon: Icon(widget.icon, size: 17, color: AppColors.gold),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЗОЛОТАЯ КНОПКА С АНИМАЦИЕЙ НАЖАТИЯ
/// ═══════════════════════════════════════════════════════════════════
class _GoldButton extends StatefulWidget {
  const _GoldButton(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen(flashOriginOf(context));
        widget.onTap();
      },
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
///  ПРОЗРАЧНАЯ КНОПКА «НАЗАД» (стеклянная, с золотой рамкой)
/// ═══════════════════════════════════════════════════════════════════
class _GhostButton extends StatefulWidget {
  const _GhostButton(this.text, this.icon, this.onTap);
  final String text;
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
      onTap: () {
        flashScreen(flashOriginOf(context));
        widget.onTap();
      },
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

/// ═══════════════════════════════════════════════════════════════════
///  КРУГЛАЯ КНОПКА-ИКОНКА (назад на главный экран)
/// ═══════════════════════════════════════════════════════════════════
class _RoundButton extends StatefulWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen(flashOriginOf(context));
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withOpacity(0.42)),
          ),
          child: Icon(widget.icon, size: 19, color: AppColors.gold),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРОБЕГАЮЩИЙ БЛИК ПО КАРТОЧКЕ
/// ═══════════════════════════════════════════════════════════════════
class _ShinePainter extends CustomPainter {
  _ShinePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final x = (t * 1.6 - 0.3) * size.width;
    final w = size.width * 0.22;
    final rect = Rect.fromLTWH(x, 0, w, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, 0),
          Offset(x + w, size.height),
          [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.045),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ShinePainter old) => old.t != t;
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ ФОН — тёмный градиент, золотые орбы, парящие частицы
/// ═══════════════════════════════════════════════════════════════════
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
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
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
        builder: (_, __) => CustomPaint(painter: _BgPainter(_c.value)),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // База — глубокий графитово-синий
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1522), Color(0xFF060C16)],
        ).createShader(rect),
    );

    // Три медленно плывущих орба
    _orb(canvas, size, 0.22, 0.18, 0.55, AppColors.gold, 0.16, 0.0);
    _orb(canvas, size, 0.82, 0.72, 0.62, const Color(0xFF2E6FB8), 0.18, 0.33);
    _orb(canvas, size, 0.50, 0.95, 0.48, AppColors.bronze, 0.12, 0.66);

    // Парящие частицы
    final p = Paint();
    for (var i = 0; i < 46; i++) {
      final seed = i * 7.13;
      final bx = (math.sin(seed) * 0.5 + 0.5);
      final by = (math.cos(seed * 1.7) * 0.5 + 0.5);
      final drift = math.sin(t * math.pi * 2 + seed) * 0.035;
      final x = (bx + drift) * size.width;
      final y = ((by - t * 0.06) % 1.0) * size.height;
      final r = 0.7 + (i % 4) * 0.55;
      final a = 0.10 + (i % 5) * 0.055;
      p.color = (i % 3 == 0 ? AppColors.gold : const Color(0xFF9FB0C6))
          .withOpacity(a);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _orb(Canvas canvas, Size size, double cx, double cy, double r,
      Color color, double alpha, double phase) {
    final ang = t * math.pi * 2 + phase * math.pi * 2;
    final ox = cx + math.sin(ang) * 0.06;
    final oy = cy + math.cos(ang * 0.8) * 0.05;
    final center = Offset(ox * size.width, oy * size.height);
    final radius = r * size.width;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          color.withOpacity(alpha),
          color.withOpacity(0.0),
        ]),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}

/// ═══════════════════════════════════════════════════════════════════
///  ЧИП ВАРИАНТА (текстовая плашка с золотой рамкой)
/// ═══════════════════════════════════════════════════════════════════
class _OptChip extends StatelessWidget {
  const _OptChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        flashScreen(flashOriginOf(context));
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12233A) : const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.gold.withOpacity(0.80)
                : const Color(0xFF1B2C44),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: selected ? AppColors.gold : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  КНОПКА «ОТЗЕРКАЛИТЬ» (окно ⇄ дверь)
/// ═══════════════════════════════════════════════════════════════════
class _MirrorBtn extends StatelessWidget {
  const _MirrorBtn({required this.doorOnLeft, required this.onTap});

  final bool doorOnLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        flashScreen(flashOriginOf(context));
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF12233A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withOpacity(0.70)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.flip(
              flipX: doorOnLeft,
              child: const Icon(Icons.compare_arrows_rounded,
                  size: 14, color: AppColors.gold),
            ),
            const SizedBox(width: 5),
            const Text(
              'ЗЕРКАЛО',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЧИП ЧИСЛА СТВОРОК (1..4)
/// ═══════════════════════════════════════════════════════════════════
class _SashCountChip extends StatelessWidget {
  const _SashCountChip({
    required this.n,
    required this.selected,
    required this.onTap,
  });

  final int n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        flashScreen(flashOriginOf(context));
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF12233A) : const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.gold.withOpacity(0.80)
                : const Color(0xFF1B2C44),
          ),
        ),
        child: Text(
          '$n',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.gold : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  СТРОКА ШИРИНЫ СЕКЦИИ: номер · мм · − / +
/// ═══════════════════════════════════════════════════════════════════
class _SectionWidthRow extends StatelessWidget {
  const _SectionWidthRow({
    required this.index,
    required this.mm,
    required this.onMinus,
    required this.onPlus,
  });

  final int index;
  final int mm;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'СЕКЦИЯ ${index + 1}',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF7E93AC),
          ),
        ),
        const Spacer(),
        _StepBtn(icon: Icons.remove_rounded, onTap: onMinus),
        SizedBox(
          width: 74,
          child: Text(
            mm > 0 ? '$mm ММ' : '—',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        _StepBtn(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  КНОПКА ШАГА (− / +)
/// ═══════════════════════════════════════════════════════════════════
class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        flashScreen(flashOriginOf(context));
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.gold.withOpacity(0.42)),
        ),
        child: Icon(icon, size: 15, color: AppColors.gold),
      ),
    );
  }
}
