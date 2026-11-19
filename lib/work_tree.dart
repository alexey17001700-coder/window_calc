import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ДЕРЕВО ВИДОВ РАБОТ  ·  v3.5.2
///  Дерево собрано из ОДИНАКОВЫХ КАРТОЧЕК — одна карточка = один пункт.
///  • 1-й уровень: 4 ОТДЕЛЬНЫЕ карточки (ЗАМЕР, МОНТАЖ, РЕМОНТ, РЕКЛАМАЦИИ).
///  • Нажал карточку → справа вырастает столбик её подпунктов.
///  • НИКАКОЙ общей карточки-обёртки с меню внутри.
///  • Автоскролл вправо + ручной скролл вперёд/назад.
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
    WorkNode(Icons.window_rounded, 'ОКНО', [
      WorkNode(Icons.crop_portrait_rounded, 'ОДНОСТВОРЧАТОЕ'),
      WorkNode(Icons.splitscreen_rounded, 'ДВУХСТВОРЧАТОЕ'),
      WorkNode(Icons.view_column_rounded, 'ТРЁХСТВОРЧАТОЕ'),
      WorkNode(Icons.polyline_rounded, 'ФИГУРНОЕ'),
    ]),
    WorkNode(Icons.door_sliding_rounded, 'БАЛКОННЫЙ БЛОК'),
    WorkNode(Icons.roofing_rounded, 'БАЛКОН'),
    WorkNode(Icons.deck_rounded, 'ЛОДЖИЯ'),
    WorkNode(Icons.door_front_door_rounded, 'ДВЕРЬ'),
    WorkNode(Icons.architecture_rounded, 'ОТКОСЫ'),
    WorkNode(Icons.water_drop_rounded, 'ОТЛИВ'),
    WorkNode(Icons.shelves, 'ПОДОКОННИКИ'),
    WorkNode(Icons.apartment_rounded, 'ФАСАДНОЕ ОСТЕКЛЕНИЕ'),
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
  const WorkTreeView({super.key, this.onWorkType});

  /// Индекс выбранного вида работ на 1-м уровне (или -1, если снят выбор).
  final ValueChanged<int>? onWorkType;

  @override
  State<WorkTreeView> createState() => _WorkTreeViewState();
}

class _WorkTreeViewState extends State<WorkTreeView> {
  // ── габариты ──
  static const double _cardW = 180; // карточка-пункт
  static const double _cardH = 66;
  static const double _gapX = 62; // место под линии-ветки
  static const double _gapY = 12;
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
                          child: CustomPaint(painter: _EdgePainter(edges)),
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
                                      selected: _path.length > k &&
                                          _path[k] == j,
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
            if (selected)
              const Icon(Icons.check_rounded, size: 16, color: AppColors.gold)
            else if (node.children.isNotEmpty)
              const Icon(Icons.chevron_right_rounded,
                  size: 17, color: Color(0xFF3D5169)),
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
