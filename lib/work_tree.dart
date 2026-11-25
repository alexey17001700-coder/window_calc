import 'package:flutter/material.dart';

import 'theme.dart';

/// Узел дерева работ.
class WorkNode {
  final String title;
  final IconData icon;
  final List<WorkNode> children;
  const WorkNode(this.title, this.icon, [this.children = const []]);
}

// ─────────────────────────── уровень 1: что делаем ───────────────────────────

const List<WorkNode> rootNodes = [
  WorkNode('НОВОЕ ОКНО', Icons.window_rounded, productNodes),
  WorkNode('ЗАМЕНА РЕЗИНОК', Icons.water_drop_rounded, rubberNodes),
  WorkNode('РЕМОНТ', Icons.build_rounded, repairNodes),
  WorkNode('ОТДЕЛКА', Icons.format_paint_rounded, finishNodes),
];

// ─────────────────────────── изделия (НОВОЕ ОКНО) ───────────────────────────

const List<WorkNode> productNodes = [
  WorkNode('ОКНО', Icons.window_rounded, windowKinds),
  WorkNode('БАЛКОННЫЙ БЛОК', Icons.door_sliding_rounded, balconyBlockKinds),
  WorkNode('БАЛКОН', Icons.deck_rounded, balconyKinds),
  WorkNode('ЛОДЖИЯ', Icons.balcony_rounded, loggiaKinds),
  WorkNode('ДВЕРЬ', Icons.door_front_door_rounded, doorKinds),
  WorkNode('ОТКОСЫ', Icons.architecture_rounded, slopeKinds),
  WorkNode('ОТЛИВ', Icons.water_drop_rounded, flashingKinds),
  WorkNode('ПОДОКОННИКИ', Icons.shelves, sillKinds),
  WorkNode('ФАСАДНОЕ ОСТЕКЛЕНИЕ', Icons.apartment_rounded, facadeKinds),
];

// ─────────────────────────── виды изделий (уровень 3) ───────────────────────

const List<WorkNode> windowKinds = [
  WorkNode('ОДНОСТВОРЧАТОЕ', Icons.crop_portrait_rounded, houseTypes),
  WorkNode('ДВУХСТВОРЧАТОЕ', Icons.splitscreen_rounded, houseTypes),
  WorkNode('ТРЁХСТВОРЧАТОЕ', Icons.view_column_rounded, houseTypes),
  WorkNode('ФИГУРНОЕ', Icons.polyline_rounded, houseTypes),
];

const List<WorkNode> balconyBlockKinds = [
  WorkNode('ДВУХСТВОРЧАТЫЙ', Icons.splitscreen_rounded, houseTypes),
  WorkNode('ТРЁХСТВОРЧАТЫЙ', Icons.view_column_rounded, houseTypes),
  WorkNode('С ДВЕРЬЮ', Icons.door_front_door_rounded, houseTypes),
  WorkNode('УГЛОВОЙ', Icons.turn_right_rounded, houseTypes),
];

const List<WorkNode> balconyKinds = [
  WorkNode('ОСТЕКЛЕНИЕ', Icons.window_rounded, houseTypes),
  WorkNode('С ВЫНОСОМ', Icons.open_in_full_rounded, houseTypes),
  WorkNode('С КРЫШЕЙ', Icons.roofing_rounded, houseTypes),
  WorkNode('БЕЗ ПАРАПЕТА', Icons.horizontal_rule_rounded, houseTypes),
];

const List<WorkNode> loggiaKinds = [
  WorkNode('ОСТЕКЛЕНИЕ', Icons.window_rounded, houseTypes),
  WorkNode('С ВЫНОСОМ', Icons.open_in_full_rounded, houseTypes),
  WorkNode('РАЗДВИЖНАЯ', Icons.swap_horiz_rounded, houseTypes),
  WorkNode('УГЛОВАЯ', Icons.turn_right_rounded, houseTypes),
];

const List<WorkNode> doorKinds = [
  WorkNode('БАЛКОННАЯ ПВХ', Icons.door_sliding_rounded, houseTypes),
  WorkNode('ВХОДНАЯ ПВХ', Icons.door_front_door_rounded, houseTypes),
  WorkNode('РАЗДВИЖНАЯ', Icons.swap_horiz_rounded, houseTypes),
  WorkNode('АЛЮМИНИЕВАЯ', Icons.door_back_door_rounded, houseTypes),
];

const List<WorkNode> slopeKinds = [
  WorkNode('ВНУТРЕННИЕ', Icons.architecture_rounded, houseTypes),
  WorkNode('НАРУЖНЫЕ', Icons.architecture_rounded, houseTypes),
  WorkNode('ВНУТРЕННИЕ И НАРУЖНЫЕ', Icons.layers_rounded, houseTypes),
  WorkNode('УГЛОВЫЕ', Icons.turn_right_rounded, houseTypes),
];

const List<WorkNode> flashingKinds = [
  WorkNode('МЕТАЛЛИЧЕСКИЙ', Icons.water_drop_rounded, houseTypes),
  WorkNode('ПЛАСТИКОВЫЙ', Icons.water_drop_rounded, houseTypes),
  WorkNode('С ЗАГЛУШКАМИ', Icons.crop_square_rounded, houseTypes),
  WorkNode('ШИРОКИЙ', Icons.open_in_full_rounded, houseTypes),
];

const List<WorkNode> sillKinds = [
  WorkNode('ПВХ', Icons.shelves, houseTypes),
  WorkNode('ЛАМИНИРОВАННЫЙ', Icons.layers_rounded, houseTypes),
  WorkNode('С ЗАГЛУШКАМИ', Icons.crop_square_rounded, houseTypes),
  WorkNode('С КРОНШТЕЙНАМИ', Icons.hardware_rounded, houseTypes),
];

const List<WorkNode> facadeKinds = [
  WorkNode('СТОЙКА-РИГЕЛЬ', Icons.grid_on_rounded, houseTypes),
  WorkNode('СПАЙДЕР', Icons.blur_on_rounded, houseTypes),
  WorkNode('СТРУКТУРНОЕ', Icons.view_module_rounded, houseTypes),
  WorkNode('ЗЕНИТНЫЙ ФОНАРЬ', Icons.roofing_rounded, houseTypes),
];

// ─────────────────────────── тип дома (уровень 4) ───────────────────────────

const List<WorkNode> houseTypes = [
  WorkNode('КИРПИЧКА', Icons.grid_on_rounded, glassTypes),
  WorkNode('ПАНЕЛЬКА', Icons.view_module_rounded, glassTypes),
  WorkNode('ХРУЩЁВКА', Icons.holiday_village_rounded, glassTypes),
  WorkNode('СТАЛИНКА', Icons.account_balance_rounded, glassTypes),
  WorkNode('ДЕРЕВЯННЫЙ ДОМ', Icons.cottage_rounded, glassTypes),
  WorkNode('ИЗ БЛОКА', Icons.widgets_rounded, glassTypes),
];

// ─────────────────────────── стеклопакет (уровень 5) ────────────────────────

const List<WorkNode> glassTypes = [
  WorkNode('ОДНОКАМЕРНЫЙ', Icons.crop_square_rounded, finishingTypes),
  WorkNode('ДВУХКАМЕРНЫЙ', Icons.layers_rounded, finishingTypes),
  WorkNode('ТРЁХКАМЕРНЫЙ', Icons.layers_clear_rounded, finishingTypes),
  WorkNode('ЭНЕРГОСБЕРЕГАЮЩИЙ', Icons.energy_savings_leaf_rounded, finishingTypes),
  WorkNode('УДАРОПРОЧНЫЙ', Icons.shield_rounded, finishingTypes),
  WorkNode('МАТОВЫЙ', Icons.blur_on_rounded, finishingTypes),
];

// ─────────────────────────── комплектация (финал, мультивыбор) ──────────────

const List<WorkNode> finishingTypes = [
  WorkNode('ПРОСТО ОКНО', Icons.window_rounded),
  WorkNode('С ОТЛИВОМ', Icons.water_drop_rounded),
  WorkNode('С ПОДОКОННИКОМ', Icons.shelves),
  WorkNode('С ОТКОСАМИ', Icons.architecture_rounded),
  WorkNode('ОТКОСЫ С ДВУХ СТОРОН', Icons.layers_rounded),
  WorkNode('АБРИС', Icons.crop_square_rounded),
  WorkNode('ПСУЛ', Icons.vertical_align_center_rounded),
  WorkNode('ОТМАЗКА', Icons.cleaning_services_rounded),
  WorkNode('ОТМАЗКА С ДВУХ СТОРОН', Icons.cleaning_services_rounded),
];

// ─────────────────────────── замена резинок ─────────────────────────────────

const List<WorkNode> rubberNodes = [
  WorkNode('ПВХ', Icons.window_rounded, serviceTypes),
  WorkNode('АЛЮМИНИЙ', Icons.door_sliding_rounded, serviceTypes),
  WorkNode('ДЕРЕВО', Icons.cottage_rounded, serviceTypes),
];

// ─────────────────────────── ремонт ─────────────────────────────────────────

const List<WorkNode> repairNodes = [
  WorkNode('РЕГУЛИРОВКА', Icons.tune_rounded, serviceTypes),
  WorkNode('ЗАМЕНА УЗЛА', Icons.hardware_rounded, serviceTypes),
  WorkNode('ЗАМЕНА СТЕКЛОПАКЕТА', Icons.layers_clear_rounded, serviceTypes),
];

// ─────────────────────────── отделка ────────────────────────────────────────

const List<WorkNode> finishNodes = [
  WorkNode('ОТКОСЫ', Icons.architecture_rounded, serviceTypes),
  WorkNode('ОТЛИВ', Icons.water_drop_rounded, serviceTypes),
  WorkNode('ПОДОКОННИК', Icons.shelves, serviceTypes),
  WorkNode('ОТМАЗКА', Icons.cleaning_services_rounded, serviceTypes),
];

// ─────────────────────────── финал услуг (мультивыбор) ──────────────────────

const List<WorkNode> serviceTypes = [
  WorkNode('БЕЗ УБОРКИ', Icons.cleaning_services_rounded),
  WorkNode('С УБОРКОЙ', Icons.cleaning_services_rounded),
  WorkNode('С ОТЛИВОМ', Icons.water_drop_rounded),
  WorkNode('ПСУЛ', Icons.vertical_align_center_rounded),
  WorkNode('ОТМАЗКА', Icons.cleaning_services_rounded),
  WorkNode('С ВЫВОЗОМ МУСОРА', Icons.delete_sweep_rounded),
];

// ─────────────────────────── геометрия дерева ───────────────────────────────

const double kCardW = 180;
const double kCardH = 66;
const double kGapX = 62;
const double kGapY = 12;

/// Дерево работ: карточки, золотые линии-ветки, автоскролл, мультивыбор.
class WorkTreeView extends StatefulWidget {
  const WorkTreeView({
    super.key,
    this.onPathChanged,
    this.onMultiChanged,
  });

  final void Function(List<String> path)? onPathChanged;
  final void Function(List<String> multi)? onMultiChanged;

  @override
  State<WorkTreeView> createState() => _WorkTreeViewState();
}

class _WorkTreeViewState extends State<WorkTreeView>
    with SingleTickerProviderStateMixin {
  final List<int> _path = [];
  final Set<String> _multi = {};
  final ScrollController _scroll = ScrollController();
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _glow.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<List<WorkNode>> _columns() {
    final cols = <List<WorkNode>>[rootNodes];
    var nodes = rootNodes;
    for (var i = 0; i < _path.length; i++) {
      final n = nodes[_path[i]];
      if (n.children.isEmpty) break;
      cols.add(n.children);
      nodes = n.children;
    }
    return cols;
  }

  List<String> _pathTitles() {
    final cols = _columns();
    final out = <String>[];
    for (var i = 0; i < _path.length && i < cols.length; i++) {
      out.add(cols[i][_path[i]].title);
    }
    return out;
  }

  void _tap(int col, int idx) {
    final cols = _columns();
    final node = cols[col][idx];

    if (node.children.isEmpty) {
      setState(() {
        if (!_multi.remove(node.title)) _multi.add(node.title);
      });
      widget.onMultiChanged?.call(_multi.toList());
      return;
    }

    setState(() {
      if (_path.length > col) _path.removeRange(col, _path.length);
      _path.add(idx);
      _multi.clear();
    });
    widget.onPathChanged?.call(_pathTitles());
    widget.onMultiChanged?.call(const []);
    _autoScroll(col + 1);
  }

  void _autoScroll(int col) {
    if (!_scroll.hasClients) return;
    final target = (col * (kCardW + kGapX) - 24).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  List<List<Rect>> _rects(double h) {
    final cols = _columns();
    final out = <List<Rect>>[];
    for (var c = 0; c < cols.length; c++) {
      final n = cols[c].length;
      final total = n * kCardH + (n - 1) * kGapY;
      final startY = ((h - total) / 2).clamp(8.0, double.infinity);
      final list = <Rect>[];
      for (var i = 0; i < n; i++) {
        list.add(Rect.fromLTWH(
          c * (kCardW + kGapX),
          startY + i * (kCardH + kGapY),
          kCardW,
          kCardH,
        ));
      }
      out.add(list);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cols = _columns();
    final totalW = cols.length * (kCardW + kGapX);

    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight.isFinite ? box.maxHeight : 420.0;
        final rects = _rects(h);

        final edges = <List<Offset>>[];
        for (var c = 1; c < rects.length; c++) {
          final from = rects[c - 1][_path[c - 1]];
          final start = Offset(from.right, from.center.dy);
          for (final r in rects[c]) {
            edges.add([start, Offset(r.left, r.center.dy)]);
          }
        }

        return SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => CustomPaint(
                      painter: _EdgePainter(edges: edges, t: _glow.value),
                    ),
                  ),
                ),
                for (var c = 0; c < cols.length; c++)
                  for (var i = 0; i < cols[c].length; i++)
                    Positioned(
                      left: rects[c][i].left,
                      top: rects[c][i].top,
                      width: kCardW,
                      height: kCardH,
                      child: _PressCard(
                        node: cols[c][i],
                        selected: c < _path.length && _path[c] == i,
                        checked: _multi.contains(cols[c][i].title),
                        onTap: () => _tap(c, i),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Карточка дерева: сжимается при касании.
class _PressCard extends StatefulWidget {
  const _PressCard({
    required this.node,
    required this.selected,
    required this.checked,
    required this.onTap,
  });

  final WorkNode node;
  final bool selected;
  final bool checked;
  final VoidCallback onTap;

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final leaf = widget.node.children.isEmpty;
    final active = widget.selected || widget.checked;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: Duration(milliseconds: _down ? 90 : 190),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppUi.cardGrad,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.gold : AppColors.line,
              width: active ? 1.4 : 1,
            ),
            boxShadow: active
                ? const [
                    BoxShadow(color: Color(0x33C9A227), blurRadius: 16),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppUi.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.node.icon,
                    size: 18, color: AppColors.bg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.node.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (leaf)
                _checkBox(widget.checked)
              else
                const Icon(Icons.chevron_right_rounded,
                    size: 17, color: AppColors.dim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkBox(bool on) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: on ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: on ? AppColors.gold : AppColors.dim,
          width: 1.2,
        ),
      ),
      child: on
          ? const Icon(Icons.check_rounded, size: 12, color: AppColors.bg)
          : null,
    );
  }
}

/// Золотые линии-ветки с бегущим свечением.
class _EdgePainter extends CustomPainter {
  _EdgePainter({required this.edges, required this.t});

  final List<List<Offset>> edges;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x55C9A227);

    for (var i = 0; i < edges.length; i++) {
      final a = edges[i][0];
      final b = edges[i][1];
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx + 30, a.dy, b.dx - 30, b.dy, b.dx, b.dy);

      canvas.drawPath(path, base);

      final metric = path.computeMetrics().first;
      final len = metric.length;
      final phase = (t + i * 0.13) % 1.0;
      final head = phase * len;
      const tail = 52.0;
      final start = (head - tail).clamp(0.0, len);
      if (head <= start) continue;

      final seg = metric.extractPath(start, head);
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0x00C9A227), Color(0xCCC9A227), Color(0xFFFFFFFF)],
        ).createShader(Rect.fromPoints(a, b));
      canvas.drawPath(seg, glow);

      final pos = metric.getTangentForOffset(head)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 4.2, Paint()..color = const Color(0x33FFE9A8));
        canvas.drawCircle(pos, 1.7, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) =>
      old.t != t || old.edges.length != edges.length;
}
