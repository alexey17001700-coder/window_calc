import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'work_tree.dart';

part 'visual/chips.dart';
part 'visual/geo.dart';
part 'visual/painter.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕРТЁЖ ОКНА ПО ГОСТ  ·  v3.4.56
///  Рабочий чертёж, а не картинка:
///   • белый лист, ТОЛЬКО тонкие чёрные линии — без заливок и градиентов;
///   • стена со штриховкой, проём, рама двойной линией;
///   • ОСЕВЫЕ линии штрихпунктиром (вертикальная и горизонтальная);
///   • УГЛОВЫЕ ВЫНОСКИ 90° по четырём углам проёма;
///   • створки — ОДНОЙ линией обвязки, БЕЗ штапика (упрощённый контур);
///   • РАЗМЕРНЫЕ ЛИНИИ: габарит сверху и слева, промежуточные — по секциям
///     (нижний ряд) и по высоте стеклопакета / арки (справа), с выносными
///     линиями, стрелками и числами в мм.
///  СТВОРКИ КЛИКАБЕЛЬНЫ: нажатие меняет обозначение открывания
///  по кругу (глухая → поворотная → поворотно-откидная → откидная
///  → снова глухая) — как на реальном чертеже.
/// ═══════════════════════════════════════════════════════════════════

/// Обозначения створок — циклически сменяются по нажатию.
/// 0 — Г (глухая), 1 — П (поворотная), 2 — ПО (поворотно-откидная),
/// 3 — О (откидная).
const List<String> kSashModeNames = [
  'ГЛУХАЯ',
  'ПОВОРОТНАЯ',
  'ПОВОРОТНО-ОТКИДНАЯ',
  'ОТКИДНАЯ',
];

/// Буквенные обозначения по ГОСТ — рисуются прямо на створке.
const List<String> kSashModeLetter = ['Г', 'П', 'ПО', 'О'];

/// Короткие подписи для плашек под чертежом.
const List<String> kSashModeShort = [
  'Г · ГЛУХАЯ',
  'П · ПОВОР.',
  'ПО · ПОВ.-ОТКИД.',
  'О · ОТКИД.',
];

class WindowVisual extends StatefulWidget {
  const WindowVisual({
    super.key,
    required this.sashes,
    required this.arched,
    required this.selectedGlass,
    required this.onGlass,
    this.parts = const [],
    this.sashModes = const [],
    this.onSashTap,
    this.widthMm = 0,
    this.heightMm = 0,
    this.sectionWidths = const [],
    this.hingeCounts = const [],
    this.onWidthEdit,
    this.onHeightEdit,
    this.onSectionEdit,
    this.balconyBlock = false,
    this.doorMode = 1,
    this.fixedMode = 0,
    this.doorWidthMm = 600,
    this.doorHeightMm = 2100,
    this.fixedWidthMm = 600,
    this.fixedHeightMm = 500,
    this.onBalconyTap,
    this.onBalconyEdit,
  });

  /// Число створок: 1, 2, 3 или 4.
  final int sashes;

  /// Фигурное окно (арочный верх).
  final bool arched;

  /// Выбранный стеклопакет (-1 — не выбран).
  final int selectedGlass;

  /// Нажатие на стеклопакет.
  final ValueChanged<int> onGlass;

  /// Отмеченная комплектация (влияет на чертёж).
  final List<String> parts;

  /// Обозначение каждой створки (индекс в kSashModeNames).
  final List<int> sashModes;

  /// Нажатие на створку — сменить обозначение.
  final ValueChanged<int>? onSashTap;

  /// Габарит по ширине, мм (0 — неизвестно).
  final int widthMm;

  /// Габарит по высоте, мм (0 — неизвестно).
  final int heightMm;

  /// Доли ширины секций (сумма ≈ 1.0). Пусто — секции равные.
  final List<double> sectionWidths;

  /// Число петель на каждой створке. По умолчанию 2 — верхняя и нижняя.
  /// Дополнительные петли замерщик добавляет ВРУЧНУЮ (например, на дверь).
  final List<int> hingeCounts;

  /// Ввод ШИРИНЫ прямо на чертеже: тап по размерной линии сверху.
  final ValueChanged<int>? onWidthEdit;

  /// Ввод ВЫСОТЫ прямо на чертеже: тап по размерной линии слева.
  final ValueChanged<int>? onHeightEdit;

  /// Ввод ширины СЕКЦИИ прямо на чертеже: тап по её нижней размерной линии.
  /// Передаёт номер секции и ширину в ММ. Остальные секции пересчитываются
  /// автоматически из общего габарита.
  final void Function(int index, int mm)? onSectionEdit;

  /// БАЛКОННЫЙ БЛОК: дверь + боковая колонна (сверху глухой стеклопакет,
  /// снизу сэндвич-панель). Если true — чертёж рисуется как блок,
  /// створки / секции / арка не используются.
  final bool balconyBlock;

  /// Обозначение ДВЕРИ блока (индекс в kSashModeNames).
  final int doorMode;

  /// Обозначение ГЛУХНЯКА блока (индекс в kSashModeNames). Обычно 0 — Г.
  final int fixedMode;

  /// Ширина двери блока, мм.
  final int doorWidthMm;

  /// Высота двери блока (= общей высоте блока), мм.
  final int doorHeightMm;

  /// Ширина глухого стеклопакета (боковой колонны), мм.
  final int fixedWidthMm;

  /// Высота глухого стеклопакета сверху колонны, мм.
  final int fixedHeightMm;

  /// Тап по двери (0) или по глухняку (1) — смена обозначения.
  final ValueChanged<int>? onBalconyTap;

  /// Ввод размера блока прямо на чертеже.
  /// Поля: 'DOOR_W' · 'DOOR_H' · 'FIXED_W' · 'FIXED_H'.
  final void Function(String field, int mm)? onBalconyEdit;

  @override
  State<WindowVisual> createState() => _WindowVisualState();
}

class _WindowVisualState extends State<WindowVisual> {
  /// Подсвеченная створка.
  int _sel = 0;

  List<int> get _modes => widget.sashModes.length == widget.sashes
      ? widget.sashModes
      : List<int>.filled(widget.sashes, 1);

  void _tap(int i) {
    HapticFeedback.selectionClick();
    setState(() => _sel = i);
    widget.onSashTap?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final modes = _modes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── ЗАГОЛОВОК ЧЕРТЕЖА ──
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ЧЕРТЁЖ · ГОСТ',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _headText(modes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E93AC),
                ),
              ),
            ),
            const Icon(Icons.touch_app_rounded,
                size: 13, color: Color(0xFF7E93AC)),
          ],
        ),
        const SizedBox(height: 10),

        // ── САМ ЧЕРТЁЖ ──
        LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxWidth / 1.16);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                // 0) БАЛКОННЫЙ БЛОК — своя логика тапов.
                if (widget.balconyBlock) {
                  final f = _hitBalconyDim(size, d.localPosition);
                  if (f != null) {
                    _editBalcony(f);
                    return;
                  }
                  final i = _hitBalcony(size, d.localPosition);
                  if (i >= 0) _balconyTap(i);
                  return;
                }
                // 1) Тап по РАЗМЕРНОЙ ЛИНИИ → ввод размера в ММ.
                final dim = _hitDim(size, d.localPosition);
                if (dim == 'w') {
                  _editDim('ШИРИНА ИЗДЕЛИЯ', '1300', widget.widthMm,
                      widget.onWidthEdit);
                  return;
                }
                if (dim == 'h') {
                  _editDim('ВЫСОТА ИЗДЕЛИЯ', '1400', widget.heightMm,
                      widget.onHeightEdit);
                  return;
                }
                // 1б) Тап по НИЖНЕЙ размерной линии секции → ввод её ширины.
                final sec = _hitSectionDim(size, d.localPosition);
                if (sec >= 0) {
                  _editSection(sec);
                  return;
                }
                // 2) Иначе — выбор створки (смена обозначения по ГОСТ).
                final i = _hit(size, d.localPosition);
                if (i >= 0) _tap(i);
              },
              child: CustomPaint(
                size: size,
                painter: _GostPainter(
                  sashes: widget.sashes,
                  arched: widget.arched,
                  parts: widget.parts,
                  modes: modes,
                  selected: _sel,
                  widthMm: widget.widthMm,
                  heightMm: widget.heightMm,
                  sectionWidths: widget.sectionWidths,
                  hingeCounts: widget.hingeCounts,
                  balconyBlock: widget.balconyBlock,
                  doorMode: widget.doorMode,
                  fixedMode: widget.fixedMode,
                  doorWidthMm: widget.doorWidthMm,
                  doorHeightMm: widget.doorHeightMm,
                  fixedWidthMm: widget.fixedWidthMm,
                  fixedHeightMm: widget.fixedHeightMm,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // ── ПОДСКАЗКА: РАЗМЕРЫ ПРАВЯТСЯ ТАПОМ ПО ЧЕРТЕЖУ ──
        Row(
          children: [
            const Icon(Icons.touch_app_rounded,
                size: 13, color: AppColors.gold),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.balconyBlock
                    ? 'ТАП: ПОД ДВЕРЬЮ — ШИРИНА ДВЕРИ, ПОД ГЛУХНЯКОМ — ЕГО ШИРИНА, СЛЕВА — ВЫСОТА, СПРАВА — ВЫСОТА ГЛУХНЯКА'
                    : 'ТАП: СВЕРХУ — ШИРИНА, СЛЕВА — ВЫСОТА, ПОД СЕКЦИЕЙ — ЕЁ ШИРИНА',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.gold.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── ОБОЗНАЧЕНИЯ СТВОРОК ──
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.balconyBlock
              ? [
                  _SashChip(
                    index: 0,
                    name:
                        'ДВЕРЬ · ${kSashModeShort[widget.doorMode.clamp(0, 3)]}',
                    selected: _sel == 0,
                    onTap: () => _balconyTap(0),
                  ),
                  _SashChip(
                    index: 1,
                    name: 'ГЛУХНЯК · ${kSashModeShort[widget.fixedMode.clamp(0, 3)]}',
                    selected: _sel == 1,
                    onTap: () => _balconyTap(1),
                  ),
                ]
              : [
                  for (var i = 0; i < widget.sashes; i++)
                    _SashChip(
                      index: i,
                      name: kSashModeShort[modes[i].clamp(0, 3)],
                      selected: _sel == i,
                      onTap: () => _tap(i),
                    ),
                ],
        ),
        const SizedBox(height: 16),

        // ── ПОДПИСЬ ──
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'СТЕКЛОПАКЕТ',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'выберите наполнение',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E93AC),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── ВЫБОР ПОД ЧЕРТЕЖОМ ──
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < glassTypes.length; i++)
                  SizedBox(
                    width: w,
                    child: _GlassChip(
                      node: glassTypes[i],
                      selected: widget.selectedGlass == i,
                      onTap: () => widget.onGlass(i),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Какая СЕКЦИЯ под пальцем.
  /// Секция — вся ячейка проёма целиком (рама + обвязка + штапик + стекло),
  /// поэтому попадание считается по проёму, а не по стеклу: палец может
  /// промахнуться мимо стекла на профиль — секция всё равно определится.
  int _hit(Size size, Offset p) {
    final g = _geo(size);
    // Палец вне проёма (стена, поле листа) — не наша секция.
    if (!_openPath(g.opening, widget.arched).contains(p)) return -1;
    final cells =
        _sashRects(g.opening.deflate(2), widget.sashes, widget.sectionWidths);
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].inflate(4).contains(p)) return i;
    }
    // Попал в проём, но между ячейками (арка) — берём ближайшую по X.
    var best = 0;
    var dist = double.infinity;
    for (var i = 0; i < cells.length; i++) {
      final d = (cells[i].center.dx - p.dx).abs();
      if (d < dist) {
        dist = d;
        best = i;
      }
    }
    return best;
  }

  /// Попадание в РАЗМЕРНУЮ ЛИНИЮ: 'w' — ширина (полоса сверху),
  /// 'h' — высота (полоса слева). Тап по ним открывает ввод в ММ.
  String? _hitDim(Size size, Offset p) {
    final g = _geo(size);
    // Ширина: полоса над стеной, по ширине проёма.
    final wTop = g.wall.top - 15;
    if (p.dy > wTop - 13 &&
        p.dy < g.wall.top &&
        p.dx > g.opening.left - 10 &&
        p.dx < g.opening.right + 10) {
      return 'w';
    }
    // Высота: полоса слева от стены, по высоте проёма.
    final hLeft = g.wall.left - 17;
    if (p.dx > hLeft - 13 &&
        p.dx < g.wall.left &&
        p.dy > g.opening.top - 10 &&
        p.dy < g.opening.bottom + 10) {
      return 'h';
    }
    return null;
  }

  /// Попадание в НИЖНЮЮ размерную линию секции → её номер (-1 — мимо).
  int _hitSectionDim(Size size, Offset p) {
    if (widget.onSectionEdit == null) return -1;
    if (widget.sashes < 2) return -1;
    final g = _geo(size);
    final hasSill = widget.parts.contains('С ПОДОКОННИКОМ');
    final hasDrip = widget.parts.contains('С ОТЛИВОМ');
    // Та же высота, на которой рисуется нижний ряд размеров.
    final y = g.wall.bottom + (hasSill || hasDrip ? 30 : 17);
    if (p.dy < y - 14 || p.dy > y + 14) return -1;
    final cells = _sashRects(g.glass, widget.sashes, widget.sectionWidths);
    for (var i = 0; i < cells.length; i++) {
      if (p.dx > cells[i].left - 9 && p.dx < cells[i].right + 9) return i;
    }
    return -1;
  }

  /// Ввод ширины секции: диалог в ММ, остальные секции — автоматом.
  void _editSection(int i) {
    final cb = widget.onSectionEdit;
    if (cb == null) return;
    final ws = _normWidths(widget.sashes, widget.sectionWidths);
    final cur = widget.widthMm > 0 ? (widget.widthMm * ws[i]).round() : 0;
    _editDim('ШИРИНА СЕКЦИИ ${i + 1}', '800', cur, (v) => cb(i, v));
  }

  /// Ввод размера: диалог с цифровой клавиатурой, значение в ММ.
  Future<void> _editDim(
      String title, String hint, int value, ValueChanged<int>? cb) async {
    if (cb == null) return;
    final c = TextEditingController(text: value > 0 ? '$value' : '');
    HapticFeedback.lightImpact();
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1D31),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.gold.withOpacity(0.45)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.gold,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E93AC),
            ),
            suffixText: 'ММ',
            suffixStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
            filled: true,
            fillColor: const Color(0xFF0A1220),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'ОТМЕНА',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7E93AC),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
              Navigator.pop(ctx, v == null ? null : v.round());
            },
            child: const Text(
              'ОК',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
    if (res != null && res > 0) cb(res);
  }
}