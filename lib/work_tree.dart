import 'package:flutter/material.dart';

import 'theme.dart';

part 'work_tree_data.dart';
part 'work_tree_painter.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ДЕРЕВО ВИДОВ РАБОТ  ·  v3.4.31
///  Данные дерева — в work_tree_data.dart, линии-ветки — в
///  work_tree_painter.dart. Сборка и состояние — здесь.
/// ═══════════════════════════════════════════════════════════════════
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
                                          ? _multi.contains(cols[k][j].title)
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