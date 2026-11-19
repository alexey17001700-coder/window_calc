import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ДЕРЕВО ВИДОВ РАБОТ  ·  v3.5
///  Дерево живёт НА ЭКРАНЕ (не внутри карточки).
///  • Корневая карточка «ВИД РАБОТ» — с кнопками-пунктами.
///  • Нажал пункт → корневая карточка ужимается.
///  • Ветки растут ВПРАВО, столбиком по центру, того же компактного вида.
///  • Автоскролл вправо + ручной скролл вперёд/назад.
///  • Тап по ветке раскрывает её подпункты, повторный тап — сворачивает.
/// ═══════════════════════════════════════════════════════════════════

/// Ветка дерева: иконка + название + подпункты.
class WorkNode {
  const WorkNode(this.icon, this.title, [this.children = const []]);
  final IconData icon;
  final String title;
  final List<WorkNode> children;
}

/// Данные дерева. Подпункты — заготовка, наполняется как нужно.
const List<WorkNode> workTree = [
  WorkNode(Icons.straighten_rounded, 'ЗАМЕР', [
    WorkNode(Icons.directions_car_rounded, 'ВЫЕЗД'),
    WorkNode(Icons.square_foot_rounded, 'ОБМЕР ПРОЁМА'),
    WorkNode(Icons.architecture_rounded, 'ЭСКИЗ'),
  ]),
  WorkNode(Icons.construction_rounded, 'МОНТАЖ', [
    WorkNode(Icons.delete_sweep_rounded, 'ДЕМОНТАЖ'),
    WorkNode(Icons.build_rounded, 'УСТАНОВКА'),
    WorkNode(Icons.water_drop_rounded, 'ОТКОСЫ И ОТЛИВЫ'),
    WorkNode(Icons.cleaning_services_rounded, 'УБОРКА'),
  ]),
  WorkNode(Icons.build_circle_rounded, 'РЕМОНТ', [
    WorkNode(Icons.tune_rounded, 'РЕГУЛИРОВКА'),
    WorkNode(Icons.swap_horiz_rounded, 'ЗАМЕНА УЗЛА'),
    WorkNode(Icons.window_rounded, 'ЗАМЕНА СТЕКЛОПАКЕТА'),
  ]),
  WorkNode(Icons.report_problem_rounded, 'РЕКЛАМАЦИИ', [
    WorkNode(Icons.verified_rounded, 'ГАРАНТИЙНЫЙ СЛУЧАЙ'),
    WorkNode(Icons.replay_rounded, 'ПОВТОРНЫЙ ВЫЕЗД'),
  ]),
];

class WorkTreeView extends StatefulWidget {
  const WorkTreeView({
    super.key,
    this.onWorkType,
    this.rootTitle = 'ВИД РАБОТ',
    this.rootSub = 'Что делаем на объекте',
  });

  /// Индекс выбранного вида работ на 1-м уровне (или -1, если свёрнуто).
  final ValueChanged<int>? onWorkType;

  /// Заголовок корневой карточки.
  final String rootTitle;

  /// Подпись под заголовком корневой карточки.
  final String rootSub;

  @override
  State<WorkTreeView> createState() => _WorkTreeViewState();
}

class _WorkTreeViewState extends State<WorkTreeView> {
  // ── габариты ──
  static const double _cardW = 138; // компактная карточка-ветка
  static const double _cardH = 52;
  static const double _rootW = 196; // корневая карточка «ВИД РАБОТ»
  static const double _rootH = 284;
  static const double _gapX = 56; // место под линии-ветки
  static const double _gapY = 10;
  static const double _pad = 10;

  /// Выбранная цепочка: индекс на каждом уровне.
  final List<int> _path = [];

  final ScrollController _h = ScrollController();
  final ScrollController _v = ScrollController();

  double _vw = 320;
  List<double> _xs = const [];
  List<double> _ws = const [];

  @override
  void dispose() {
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
    return nodes[_path[k - 1]].children;
  }

  /// Колонки дерева: 0 — корень, дальше — раскрытые ветки.
  List<List<WorkNode>> _columns() {
    if (_path.isEmpty) return [workTree];
    final cols = <List<WorkNode>>[
      [workTree[_path[0]]],
    ];
    for (var k = 1; k <= _path.length; k++) {
      final ch = _level(k);
      if (ch.isEmpty) break;
      cols.add(ch);
    }
    return cols;
  }

  // ─────────────────────── ВЫБОР ───────────────────────
  void _select(int level, int index) {
    final same = _path.length > level && _path[level] == index;
    setState(() {
      if (_path.length > level) _path.removeRange(level, _path.length);
      if (!same) _path.add(index);
    });
    if (level == 0) {
      widget.onWorkType?.call(same ? -1 : index);
    }
    _autoScroll();
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
        final rootExpanded = _path.isEmpty;

        final xs = List<double>.filled(n, 0);
        final ws = List<double>.filled(n, 0);
        final hs = List<double>.filled(n, 0);
        final colH = List<double>.filled(n, 0);

        for (var k = 0; k < n; k++) {
          final tall = k == 0 && rootExpanded;
          ws[k] = tall ? _rootW : _cardW;
          hs[k] = tall ? _rootH : _cardH;
          xs[k] = k == 0 ? _pad : xs[k - 1] + ws[k - 1] + _gapX;
          final cnt = cols[k].length;
          colH[k] = cnt == 0 ? 0 : cnt * hs[k] + (cnt - 1) * _gapY;
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
                startY + j * (hs[k] + _gapY),
                ws[k],
                hs[k],
              ),
          ]);
        }

        // Связи: корень → ветки, ветка → её подпункты.
        final edges = <List<Rect>>[];
        for (var k = 1; k < n; k++) {
          final parent =
              (k == 1) ? rects[0][0] : rects[k - 1][_path[k - 1]];
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
                          child: CustomPaint(painter: _EdgePainter(edges)),
                        ),
                      ),
                      // ── КОРЕНЬ ──
                      Positioned(
                        left: rects[0][0].left,
                        top: rects[0][0].top,
                        width: ws[0],
                        height: hs[0],
                        child: rootExpanded
                            ? _rootCard()
                            : _compactCard(
                                workTree[_path[0]],
                                selected: true,
                                onTap: () => _select(0, _path[0]),
                              ),
                      ),
                      // ── ВЕТКИ ──
                      for (var k = 1; k < n; k++)
                        for (var j = 0; j < cols[k].length; j++)
                          Positioned(
                            left: rects[k][j].left,
                            top: rects[k][j].top,
                            width: ws[k],
                            height: hs[k],
                            child: _appear(
                              k,
                              j,
                              _compactCard(
                                cols[k][j],
                                selected:
                                    _path.length > k && _path[k] == j,
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

  // ─────────────────── КОРНЕВАЯ КАРТОЧКА ───────────────────
  Widget _rootCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152740), Color(0xFF0B1524)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withOpacity(0.34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.gold.withOpacity(0.10),
            blurRadius: 34,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 15,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.rootTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              widget.rootSub,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E93AC),
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < workTree.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i < workTree.length - 1 ? 7 : 0),
              child: _rootRow(i),
            ),
        ],
      ),
    );
  }

  /// Кнопка-пункт корневой карточки — ТАКАЯ ЖЕ карточка, как ветки дерева.
  Widget _rootRow(int i) {
    final node = workTree[i];
    return GestureDetector(
      onTap: () => _select(0, i),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: _dec(false),
        child: Row(
          children: [
            _iconBox(node.icon, 28, 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: Color(0xFF3D5169)),
          ],
        ),
      ),
    );
  }

  // ─────────────────── КОМПАКТНАЯ КАРТОЧКА ───────────────────
  Widget _compactCard(WorkNode node,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: _dec(selected),
        child: Row(
          children: [
            _iconBox(node.icon, 28, 14),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                node.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, size: 13, color: AppColors.gold)
            else if (node.children.isNotEmpty)
              const Icon(Icons.chevron_right_rounded,
                  size: 14, color: Color(0xFF3D5169)),
          ],
        ),
      ),
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
///  ЛИНИИ-ВЕТКИ: от правого торца карточки к левому торцу подпункта
/// ═══════════════════════════════════════════════════════════════════
class _EdgePainter extends CustomPainter {
  _EdgePainter(this.edges);
  final List<List<Rect>> edges;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
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
      // узелки на концах
      canvas.drawCircle(
          p1, 2.4, Paint()..color = AppColors.gold.withOpacity(0.75));
      canvas.drawCircle(
          p2, 2.0, Paint()..color = AppColors.gold.withOpacity(0.55));
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) => true;
}
