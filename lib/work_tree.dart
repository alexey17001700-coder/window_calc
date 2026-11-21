import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ДЕРЕВО ВИДОВ РАБОТ  ·  v3.4.31
///  Дерево собрано из ОДИНАКОВЫХ КАРТОЧЕК — одна карточка = один пункт.
///  • 1-й уровень: 4 ОТДЕЛЬНЫЕ карточки (ЗАМЕР, МОНТАЖ, РЕМОНТ, РЕКЛАМАЦИИ).
///  • Нажал карточку → справа вырастает столбик её подпунктов.
///  • НИКАКОЙ общей карточки-обёртки с меню внутри.
///  • Автоскролл вправо + ручной скролл вперёд/назад.
///  • Финальный уровень (комплектация) — МУЛЬТИВЫБОР: можно отметить
///    один пункт, несколько или все. Есть хоть одна отметка — мастер
///    показывает кнопку «ПОДТВЕРДИТЬ».
/// ═══════════════════════════════════════════════════════════════════

/// Ветка дерева: иконка + название + подпункты.
class WorkNode {
  const WorkNode(this.icon, this.title, [this.children = const []]);
  final IconData icon;
  final String title;
  final List<WorkNode> children;
}

/// Стеклопакет — выбор ПОД визуальным окном (в дерево не входит).
const List<WorkNode> glassTypes = [
  WorkNode(Icons.crop_square_rounded, 'ОДНОКАМЕРНЫЙ'),
  WorkNode(Icons.layers_rounded, 'ДВУХКАМЕРНЫЙ'),
  WorkNode(Icons.layers_clear_rounded, 'ТРЁХКАМЕРНЫЙ'),
  WorkNode(Icons.energy_savings_leaf_rounded, 'ЭНЕРГОСБЕРЕГАЮЩИЙ'),
  WorkNode(Icons.shield_rounded, 'УДАРОПРОЧНЫЙ'),
  WorkNode(Icons.blur_on_rounded, 'МАТОВЫЙ'),
];

/// Финальный уровень дерева — КОМПЛЕКТАЦИЯ. Мультивыбор.
/// Это ПОСЛЕДНИЕ пункты: дальше дерево не растёт.
const List<WorkNode> finishingTypes = [
  WorkNode(Icons.window_rounded, 'ПРОСТО ОКНО'),
  WorkNode(Icons.water_drop_rounded, 'С ОТЛИВОМ'),
  WorkNode(Icons.shelves, 'С ПОДОКОННИКОМ'),
  WorkNode(Icons.architecture_rounded, 'С ОТКОСАМИ'),
  WorkNode(Icons.change_history_rounded, 'АБРИС'),
  WorkNode(Icons.linear_scale_rounded, 'ПСУЛ'),
  WorkNode(Icons.cleaning_services_rounded, 'ОТМАЗКА'),
  WorkNode(Icons.compare_arrows_rounded, 'ОТМАЗКА С ДВУХ СТОРОН'),
  // Козырёк — только на балконе / лоджии. Длина считается АВТОМАТИЧЕСКИ:
  // ширина изделия + 200 мм (балкон 3000 → козырёк 3200).
  WorkNode(Icons.roofing_rounded, 'КОЗЫРЁК'),
  // Козырёк из двух частей: каждая часть = половина + нахлёст 150 мм
  // (балкон 3000 → 3200 → по 1750 мм).
  WorkNode(Icons.splitscreen_rounded, 'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ'),
];

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕГО НЕ БЫВАЕТ ПРИ РАБОТЕ
///  ПСУЛ (уплотнение), АБРИС (наличник) и замена резинки — работы
///  по проёму: подоконник при них не ставится, поэтому пункт
///  «С ПОДОКОННИКОМ» из комплектации ГАСНЕТ.
/// ═══════════════════════════════════════════════════════════════════
const List<String> noSillWorks = ['ПСУЛ', 'АБРИС', 'ЗАМЕНА РЕЗИНКИ'];

/// Пункты комплектации, которые убираем при работах из [noSillWorks].
const List<String> noSillParts = ['С ПОДОКОННИКОМ'];

/// Убрать из финального уровня пункты, которых НЕ БЫВАЕТ при выбранной
/// работе. [picked] — цепочка дерева + отмеченная комплектация.
List<WorkNode> finishFor(List<WorkNode> nodes, List<String> picked) {
  final all = picked.join(' ').toUpperCase();
  if (!noSillWorks.any(all.contains)) return nodes;
  return [
    for (final n in nodes)
      if (!noSillParts.contains(n.title)) n,
  ];
}

/// Тип дома — 3-й уровень дерева (после выбора изделия и его вида).
/// Дальше идёт финальный уровень — комплектация (мультивыбор).
const List<WorkNode> houseTypes = [
  WorkNode(Icons.grid_on_rounded, 'КИРПИЧКА', finishingTypes),
  WorkNode(Icons.view_module_rounded, 'ПАНЕЛЬКА', finishingTypes),
  WorkNode(Icons.holiday_village_rounded, 'ХРУЩЁВКА', finishingTypes),
  WorkNode(Icons.account_balance_rounded, 'СТАЛИНКА', finishingTypes),
  WorkNode(Icons.cottage_rounded, 'ДЕРЕВЯННЫЙ ДОМ', finishingTypes),
  WorkNode(Icons.widgets_rounded, 'ИЗ БЛОКА', finishingTypes),
];

/// ─── ВИДЫ ИЗДЕЛИЙ (3-й уровень дерева) ───
/// У КАЖДОГО изделия СВОЁ дерево: вид изделия → тип дома → комплектация.
/// Пустых веток нет — галочка-квадратик появляется ТОЛЬКО на финальном
/// уровне (комплектация), а не на изделии.
const List<WorkNode> windowKinds = [
  WorkNode(Icons.crop_portrait_rounded, 'ОДНОСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.splitscreen_rounded, 'ДВУХСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.view_column_rounded, 'ТРЁХСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.polyline_rounded, 'ФИГУРНОЕ', houseTypes),
];

// Балконный блок И ТАК идёт с дверью — отдельный пункт «С ДВЕРЬЮ» убран.
const List<WorkNode> balconyBlockKinds = [
  WorkNode(Icons.splitscreen_rounded, 'ДВУХСТВОРЧАТЫЙ', houseTypes),
  WorkNode(Icons.view_column_rounded, 'ТРЁХСТВОРЧАТЫЙ', houseTypes),
];

/// ФОРМА БАЛКОНА — уровень дерева после вида работ.
/// Дальше идёт комплектация: подоконник, отлив, козырёк.
const List<WorkNode> balconyShapes = [
  WorkNode(Icons.horizontal_rule_rounded, 'ПРЯМОЙ', finishingTypes),
  WorkNode(Icons.space_bar_rounded, 'П-ОБРАЗНЫЙ', finishingTypes),
  WorkNode(Icons.turn_right_rounded, 'Г-ОБРАЗНЫЙ', finishingTypes),
  WorkNode(Icons.remove_circle_outline_rounded, 'БЕЗ ПАРАПЕТА',
      finishingTypes),
];

// «УГЛОВОЙ» убран: угловой балкон = Г-ОБРАЗНЫЙ (он есть в balconyShapes).
const List<WorkNode> balconyKinds = [
  WorkNode(Icons.window_rounded, 'ОСТЕКЛЕНИЕ', balconyShapes),
  WorkNode(Icons.open_in_full_rounded, 'С ВЫНОСОМ', balconyShapes),
  WorkNode(Icons.roofing_rounded, 'С КРЫШЕЙ', balconyShapes),
];

const List<WorkNode> loggiaKinds = [
  WorkNode(Icons.window_rounded, 'ОСТЕКЛЕНИЕ', houseTypes),
  WorkNode(Icons.open_in_full_rounded, 'С ВЫНОСОМ', houseTypes),
  WorkNode(Icons.swap_horiz_rounded, 'РАЗДВИЖНАЯ', houseTypes),
  WorkNode(Icons.crop_landscape_rounded, 'УГЛОВАЯ', houseTypes),
];

const List<WorkNode> doorKinds = [
  WorkNode(Icons.door_front_door_rounded, 'БАЛКОННАЯ ПВХ', houseTypes),
  WorkNode(Icons.door_back_door_rounded, 'ВХОДНАЯ ПВХ', houseTypes),
  WorkNode(Icons.door_sliding_rounded, 'РАЗДВИЖНАЯ', houseTypes),
  WorkNode(Icons.sensor_door_rounded, 'АЛЮМИНИЕВАЯ', houseTypes),
];

const List<WorkNode> slopeKinds = [
  WorkNode(Icons.architecture_rounded, 'ВНУТРЕННИЕ', houseTypes),
  WorkNode(Icons.water_drop_rounded, 'НАРУЖНЫЕ', houseTypes),
  WorkNode(Icons.compare_arrows_rounded, 'ВНУТРЕННИЕ И НАРУЖНЫЕ', houseTypes),
  WorkNode(Icons.crop_landscape_rounded, 'УГЛОВЫЕ', houseTypes),
];

const List<WorkNode> flashingKinds = [
  WorkNode(Icons.water_drop_rounded, 'МЕТАЛЛИЧЕСКИЙ', houseTypes),
  WorkNode(Icons.window_rounded, 'ПЛАСТИКОВЫЙ', houseTypes),
  WorkNode(Icons.linear_scale_rounded, 'С ЗАГЛУШКАМИ', houseTypes),
  WorkNode(Icons.open_in_full_rounded, 'ШИРОКИЙ', houseTypes),
];

const List<WorkNode> sillKinds = [
  WorkNode(Icons.shelves, 'ПВХ', houseTypes),
  WorkNode(Icons.layers_rounded, 'ЛАМИНИРОВАННЫЙ', houseTypes),
  WorkNode(Icons.linear_scale_rounded, 'С ЗАГЛУШКАМИ', houseTypes),
  WorkNode(Icons.build_rounded, 'С КРОНШТЕЙНАМИ', houseTypes),
];

const List<WorkNode> facadeKinds = [
  WorkNode(Icons.grid_on_rounded, 'СТОЙКА-РИГЕЛЬ', houseTypes),
  WorkNode(Icons.blur_on_rounded, 'СПАЙДЕР', houseTypes),
  WorkNode(Icons.view_module_rounded, 'СТРУКТУРНОЕ', houseTypes),
  WorkNode(Icons.roofing_rounded, 'ЗЕНИТНЫЙ ФОНАРЬ', houseTypes),
];

/// Финальный уровень для монтажа, ремонта и рекламаций — работы по месту.
const List<WorkNode> serviceTypes = [
  WorkNode(Icons.cleaning_services_rounded, 'БЕЗ УБОРКИ'),
  WorkNode(Icons.auto_awesome_rounded, 'С УБОРКОЙ'),
  WorkNode(Icons.water_drop_rounded, 'С ОТЛИВОМ'),
  WorkNode(Icons.linear_scale_rounded, 'ПСУЛ'),
  WorkNode(Icons.brush_rounded, 'ОТМАЗКА'),
  WorkNode(Icons.delete_sweep_rounded, 'С ВЫВОЗОМ МУСОРА'),
];

/// Данные дерева. У КАЖДОГО пункта — своё дерево, галочек-тупиков нет.
const List<WorkNode> workTree = [
  WorkNode(Icons.straighten_rounded, 'ЗАМЕР', [
    WorkNode(Icons.window_rounded, 'ОКНО', windowKinds),
    WorkNode(Icons.door_sliding_rounded, 'БАЛКОННЫЙ БЛОК', balconyBlockKinds),
    WorkNode(Icons.roofing_rounded, 'БАЛКОН', balconyKinds),
    WorkNode(Icons.deck_rounded, 'ЛОДЖИЯ', loggiaKinds),
    WorkNode(Icons.door_front_door_rounded, 'ДВЕРЬ', doorKinds),
    WorkNode(Icons.architecture_rounded, 'ОТКОСЫ', slopeKinds),
    WorkNode(Icons.water_drop_rounded, 'ОТЛИВ', flashingKinds),
    WorkNode(Icons.shelves, 'ПОДОКОННИКИ', sillKinds),
    WorkNode(Icons.apartment_rounded, 'ФАСАДНОЕ ОСТЕКЛЕНИЕ', facadeKinds),
  ]),
  WorkNode(Icons.construction_rounded, 'МОНТАЖ', [
    WorkNode(Icons.delete_sweep_rounded, 'ДЕМОНТАЖ', [
      WorkNode(Icons.content_cut_rounded, 'ЧАСТИЧНЫЙ', serviceTypes),
      WorkNode(Icons.delete_forever_rounded, 'ПОЛНЫЙ', serviceTypes),
      WorkNode(Icons.local_shipping_rounded, 'С ВЫВОЗОМ', serviceTypes),
    ]),
    WorkNode(Icons.build_rounded, 'УСТАНОВКА', [
      WorkNode(Icons.hardware_rounded, 'НА АНКЕР', serviceTypes),
      WorkNode(Icons.linear_scale_rounded, 'НА ПЛАСТИНЫ', serviceTypes),
      WorkNode(Icons.blur_on_rounded, 'НА ПЕНУ', serviceTypes),
    ]),
    WorkNode(Icons.water_drop_rounded, 'ОТКОСЫ И ОТЛИВЫ', [
      WorkNode(Icons.architecture_rounded, 'НАРУЖНЫЕ', serviceTypes),
      WorkNode(Icons.home_rounded, 'ВНУТРЕННИЕ', serviceTypes),
      WorkNode(Icons.all_inclusive_rounded, 'ПОЛНЫЙ КОНТУР', serviceTypes),
    ]),
    WorkNode(Icons.cleaning_services_rounded, 'УБОРКА', [
      WorkNode(Icons.auto_awesome_rounded, 'СУХАЯ', serviceTypes),
      WorkNode(Icons.water_drop_rounded, 'ВЛАЖНАЯ', serviceTypes),
      WorkNode(Icons.construction_rounded, 'ПОСЛЕ МОНТАЖА', serviceTypes),
    ]),
  ]),
  WorkNode(Icons.build_circle_rounded, 'РЕМОНТ', [
    WorkNode(Icons.tune_rounded, 'РЕГУЛИРОВКА', [
      WorkNode(Icons.door_sliding_rounded, 'СТВОРКИ', serviceTypes),
      WorkNode(Icons.hardware_rounded, 'ФУРНИТУРЫ', serviceTypes),
      WorkNode(Icons.compress_rounded, 'ПРИЖИМА', serviceTypes),
    ]),
    WorkNode(Icons.swap_horiz_rounded, 'ЗАМЕНА УЗЛА', [
      WorkNode(Icons.hardware_rounded, 'ПЕТЛИ', serviceTypes),
      WorkNode(Icons.back_hand_rounded, 'РУЧКА', serviceTypes),
      WorkNode(Icons.lock_rounded, 'ЗАПОР', serviceTypes),
      WorkNode(Icons.open_in_full_rounded, 'НОЖНИЦЫ', serviceTypes),
      // Резинка (уплотнитель). Подоконника при этой работе не бывает.
      WorkNode(Icons.linear_scale_rounded, 'ЗАМЕНА РЕЗИНКИ', serviceTypes),
    ]),
    WorkNode(Icons.window_rounded, 'ЗАМЕНА СТЕКЛОПАКЕТА', [
      WorkNode(Icons.crop_square_rounded, 'ОДНОКАМЕРНЫЙ', serviceTypes),
      WorkNode(Icons.layers_rounded, 'ДВУХКАМЕРНЫЙ', serviceTypes),
      WorkNode(Icons.shield_rounded, 'ТРИПЛЕКС', serviceTypes),
    ]),
  ]),
  WorkNode(Icons.report_problem_rounded, 'РЕКЛАМАЦИИ', [
    WorkNode(Icons.verified_rounded, 'ГАРАНТИЙНЫЙ СЛУЧАЙ', [
      WorkNode(Icons.air_rounded, 'ПРОДУВАНИЕ', serviceTypes),
      WorkNode(Icons.water_drop_rounded, 'КОНДЕНСАТ', serviceTypes),
      WorkNode(Icons.blur_on_rounded, 'ЗАПОТЕВАНИЕ', serviceTypes),
      WorkNode(Icons.umbrella_rounded, 'ПРОТЕЧКА', serviceTypes),
    ]),
    WorkNode(Icons.replay_rounded, 'ПОВТОРНЫЙ ВЫЕЗД', [
      WorkNode(Icons.verified_rounded, 'ПО ГАРАНТИИ', serviceTypes),
      WorkNode(Icons.payments_rounded, 'ПЛАТНЫЙ', serviceTypes),
    ]),
  ]),
];

class WorkTreeView extends StatefulWidget {
  const WorkTreeView({
    super.key,
    this.onWorkType,
    this.onPathChanged,
    this.onMultiChanged,
  });

  /// Индекс выбранного вида работ на 1-м уровне (или -1, если снят выбор).
  final ValueChanged<int>? onWorkType;

  /// Цепочка выбранных уровней (ЗАМЕР → ОКНО → вид → тип дома).
  final ValueChanged<List<String>>? onPathChanged;

  /// Отмеченные пункты комплектации (финальный уровень, мультивыбор).
  final ValueChanged<List<String>>? onMultiChanged;

  @override
  State<WorkTreeView> createState() => _WorkTreeViewState();
}

class _WorkTreeViewState extends State<WorkTreeView>
    with SingleTickerProviderStateMixin {
  /// Бегущий огонёк по линиям-веткам (слева направо, без остановки).
  late final AnimationController _glow;

  // ── габариты ──
  static const double _cardW = 180; // карточка-пункт
  static const double _cardH = 66;
  static const double _gapX = 62; // место под линии-ветки
  static const double _gapY = 12;
  static const double _pad = 10;

  /// Выбранная цепочка: индекс на каждом уровне.
  final List<int> _path = [];

  /// Отмеченные пункты финального уровня (комплектация) — мультивыбор.
  /// Храним НАЗВАНИЯ, а не индексы: список пунктов меняется (ПСУЛ / АБРИС /
  /// замена резинки гасят «С ПОДОКОННИКОМ»), индексы при этом съезжают.
  final Set<String> _multi = {};

  final ScrollController _h = ScrollController();
  final ScrollController _v = ScrollController();

  double _vw = 320;
  List<double> _xs = const [];
  List<double> _ws = const [];

  @override
  void initState() {
    super.initState();
    // Огонёк бежит по линиям слева направо, цикл бесконечный.
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _glow.dispose();
    _h.dispose();
    _v.dispose();
    super.dispose();
  }

  // ─────────────────────── ДАННЫЕ УРОВНЯ ───────────────────────
  /// Дети узла, стоящего на уровне k-1 (k ≥ 1).
  List<WorkNode> _level(int k) {
    var nodes = workTree;
    for (var i = 0; i < k - 1; i++) {
      nodes = nodes[_path[i]].children;
    }
    if (_path.length < k) return const [];
    final ch = nodes[_path[k - 1]].children;
    // Финальный уровень (комплектация): гасим пункты, которых НЕ БЫВАЕТ
    // при выбранной работе — ПСУЛ / АБРИС / замена резинки → без подоконника.
    if (ch.isNotEmpty && ch.every((n) => n.children.isEmpty)) {
      return finishFor(ch, [..._titles(), ..._multi]);
    }
    return ch;
  }

  /// Колонки дерева: 0 — все 4 карточки 1-го уровня, дальше — раскрытые ветки.
  List<List<WorkNode>> _columns() {
    final cols = <List<WorkNode>>[workTree];
    for (var k = 1; k <= _path.length; k++) {
      final ch = _level(k);
      if (ch.isEmpty) break;
      cols.add(ch);
    }
    return cols;
  }

  // ─────────────────────── ВЫБОР ───────────────────────
  void _select(int level, int index) {
    // Берём узел из ТЕКУЩИХ колонок: финальный уровень может быть отфильтрован.
    final cols = _columns();
    if (level < 0 || level >= cols.length) return;
    if (index < 0 || index >= cols[level].length) return;
    final node = cols[level][index];

    // ── ФИНАЛЬНЫЙ УРОВЕНЬ (комплектация): мультивыбор ──
    if (node.children.isEmpty) {
      setState(() {
        if (!_multi.remove(node.title)) _multi.add(node.title);
        // Отметил ПСУЛ / АБРИС — «С ПОДОКОННИКОМ» гаснет и снимается.
        _pruneMulti();
      });
      widget.onMultiChanged?.call(_multiTitles());
      return;
    }

    // ── ОБЫЧНЫЙ УРОВЕНЬ: одна ветка; смена ветки сбрасывает комплектацию ──
    final same = _path.length > level && _path[level] == index;
    setState(() {
      if (_path.length > level) _path.removeRange(level, _path.length);
      if (!same) _path.add(index);
      _multi.clear();
    });
    if (level == 0) widget.onWorkType?.call(same ? -1 : index);
    widget.onPathChanged?.call(_titles());
    widget.onMultiChanged?.call(const []);
    _autoScroll();
  }

  /// Снять отметки с пунктов, которых больше нет в финальном уровне
  /// (например, подоконник при ПСУЛ / АБРИС / замене резинки).
  void _pruneMulti() {
    final cols = _columns();
    if (cols.isEmpty) {
      _multi.clear();
      return;
    }
    final allowed = {for (final n in cols.last) n.title};
    _multi.removeWhere((t) => !allowed.contains(t));
  }

  /// Названия выбранной цепочки.
  List<String> _titles() {
    final out = <String>[];
    var nodes = workTree;
    for (var i = 0; i < _path.length; i++) {
      final n = nodes[_path[i]];
      out.add(n.title);
      nodes = n.children;
    }
    return out;
  }

  /// Названия отмеченных пунктов комплектации — в порядке колонки.
  List<String> _multiTitles() {
    final cols = _columns();
    if (cols.isEmpty) return const [];
    return [
      for (final n in cols.last)
        if (_multi.contains(n.title)) n.title,
    ];
  }

  /// Автоскролл: новая колонка встаёт в центр экрана.
  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_h.hasClients || _xs.isEmpty) return;
      final i = _xs.length - 1;
      final w = i < _ws.length ? _ws[i] : _cardW;
      final target = (_xs[i] + w / 2 - _vw / 2)
          .clamp(0.0, _h.position.maxScrollExtent)
          .toDouble();
      _h.animateTo(
        target,
        duration: const Duration(milliseconds: 430),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // ─────────────────────── ПОСТРОЕНИЕ ───────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final vp = (c.maxHeight.isFinite && c.maxHeight > 160)
            ? c.maxHeight
            : 340.0;
        _vw = c.maxWidth;

        final cols = _columns();
        final n = cols.length;

        final xs = List<double>.filled(n, 0);
        final ws = List<double>.filled(n, 0);
        final colH = List<double>.filled(n, 0);

        for (var k = 0; k < n; k++) {
          ws[k] = _cardW;
          xs[k] = k == 0 ? _pad : xs[k - 1] + ws[k - 1] + _gapX;
          final cnt = cols[k].length;
          colH[k] = cnt == 0 ? 0 : cnt * _cardH + (cnt - 1) * _gapY;
        }
        _xs = xs;
        _ws = ws;

        final canvasW = xs[n - 1] + ws[n - 1] + _pad;
        var contentH = 0.0;
        for (var k = 0; k < n; k++) {
          if (colH[k] > contentH) contentH = colH[k];
        }
        final canvasH = contentH + _pad * 2;

        // Прямоугольники всех карточек.
        final rects = <List<Rect>>[];
        for (var k = 0; k < n; k++) {
          final startY = (canvasH - colH[k]) / 2;
          rects.add([
            for (var j = 0; j < cols[k].length; j++)
              Rect.fromLTWH(
                xs[k],
                startY + j * (_cardH + _gapY),
                ws[k],
                _cardH,
              ),
          ]);
        }

        // Связи: выбранная карточка → её подпункты.
        final edges = <List<Rect>>[];
        for (var k = 1; k < n; k++) {
          final parent = rects[k - 1][_path[k - 1]];
          for (final child in rects[k]) {
            edges.add([parent, child]);
          }
        }

        return SizedBox(
          height: vp,
          child: SingleChildScrollView(
            controller: _v,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: canvasH,
              child: SingleChildScrollView(
                controller: _h,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: canvasW,
                  height: canvasH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── ЛИНИИ-ВЕТКИ ──
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _glow,
                            builder: (context, _) => CustomPaint(
                              painter: _EdgePainter(edges, _glow.value),
                            ),
                          ),
                        ),
                      ),
                      // ── КАРТОЧКИ ВСЕХ УРОВНЕЙ ──
                      for (var k = 0; k < n; k++)
                        for (var j = 0; j < cols[k].length; j++)
                          Positioned(
                            left: rects[k][j].left,
                            top: rects[k][j].top,
                            width: ws[k],
                            height: _cardH,
                            child: k == 0
                                ? _card(
                                    cols[k][j],
                                    selected: _path.isNotEmpty &&
                                        _path[0] == j,
                                    onTap: () => _select(0, j),
                                  )
                                : _appear(
                                    k,
                                    j,
                                    _card(
                                      cols[k][j],
                                      selected: cols[k][j].children.isEmpty
                                          ? _multi.contains(j)
                                          : (_path.length > k &&
                                              _path[k] == j),
                                      onTap: () => _select(k, j),
                                    ),
                                  ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Появление ветки с «доворотом» (кручение вокруг оси Y).
  Widget _appear(int level, int index, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('wt-$level-$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY((1 - v) * -1.05),
          child: c,
        ),
      ),
      child: child,
    );
  }

  // ─────────────────── КАРТОЧКА-ПУНКТ ───────────────────
  Widget _card(WorkNode node,
      {required bool selected, required VoidCallback onTap}) {
    return _PressCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _dec(selected),
        child: Row(
          children: [
            _iconBox(node.icon, 36, 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                node.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
            if (node.children.isEmpty)
              _checkBox(selected)
            else if (selected)
              const Icon(Icons.check_rounded, size: 16, color: AppColors.gold)
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 17, color: Color(0xFF3D5169)),
          ],
        ),
      ),
    );
  }

  /// Квадратик-галочка для мультивыбора (финальный уровень).
  Widget _checkBox(bool on) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: on ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: on ? AppColors.gold : const Color(0xFF3D5169),
          width: 1.4,
        ),
      ),
      child: on
          ? const Icon(Icons.check_rounded, size: 13, color: AppColors.navy900)
          : null,
    );
  }

  Widget _iconBox(IconData icon, double size, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withOpacity(0.24),
            AppColors.bronze.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Icon(icon, size: iconSize, color: AppColors.gold),
    );
  }

  BoxDecoration _dec(bool selected) {
    return BoxDecoration(
      color: selected ? const Color(0xFF12233A) : const Color(0xFF0A1220),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected
            ? AppColors.gold.withOpacity(0.78)
            : const Color(0xFF1B2C44),
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  КАРТОЧКА С НАЖАТИЕМ: при касании сжимается, при отпускании — назад
/// ═══════════════════════════════════════════════════════════════════
class _PressCard extends StatefulWidget {
  const _PressCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: Duration(milliseconds: _down ? 90 : 190),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЛИНИИ-ВЕТКИ: от правого торца карточки к левому торцу подпункта
/// ═══════════════════════════════════════════════════════════════════
class _EdgePainter extends CustomPainter {
  _EdgePainter(this.edges, this.t);

  final List<List<Rect>> edges;

  /// Фаза бегущего огонька: 0 → 1 (слева направо).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < edges.length; i++) {
      final e = edges[i];
      final p1 = Offset(e[0].right, e[0].center.dy);
      final p2 = Offset(e[1].left, e[1].center.dy);
      final dx = (p2.dx - p1.dx) * 0.5;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(p1.dx + dx, p1.dy, p2.dx - dx, p2.dy, p2.dx, p2.dy);

      // мягкое свечение
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..color = AppColors.gold.withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.6),
      );
      // сама линия
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.gold.withOpacity(0.55),
      );

      // ── БЕГУЩИЙ ОГОНЁК: свечение идёт слева направо ──
      // у каждой ветки своя фаза — линии «переливаются» по очереди
      final phase = (t + i * 0.13) % 1.0;
      for (final m in path.computeMetrics()) {
        final len = m.length;
        if (len <= 1) continue;

        final head = phase * len;
        const tail = 52.0;
        final start = (head - tail).clamp(0.0, len);

        if (head - start > 1.5) {
          final from = m.getTangentForOffset(start)?.position;
          final to = m.getTangentForOffset(head)?.position;
          if (from != null && to != null) {
            canvas.drawPath(
              m.extractPath(start, head),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.4
                ..strokeCap = StrokeCap.round
                ..shader = LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.gold.withOpacity(0.0),
                    AppColors.goldLight.withOpacity(0.85),
                    Colors.white.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ).createShader(Rect.fromPoints(from, to)),
            );
          }
        }

        // головка-искра
        final tip = m.getTangentForOffset(head)?.position;
        if (tip != null) {
          canvas.drawCircle(
            tip,
            4.2,
            Paint()
              ..color = AppColors.goldLight.withOpacity(0.45)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2),
          );
          canvas.drawCircle(
              tip, 1.7, Paint()..color = Colors.white.withOpacity(0.95));
        }
      }

      // узелки на концах
      canvas.drawCircle(
          p1, 2.4, Paint()..color = AppColors.gold.withOpacity(0.75));
      canvas.drawCircle(
          p2, 2.0, Paint()..color = AppColors.gold.withOpacity(0.55));
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.t != t || old.edges != edges;
}
