import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'screen_flash.dart';
import 'measure_media.dart';
import 'price_estimate.dart';
import 'price_settings.dart';
import 'sheet_recipient.dart';
import 'sheet_visual.dart';
import 'window_visual.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ШАГ «ЗАМЕРНЫЙ ЛИСТ»  ·  v3.4.25
///  Итог замера: клиент + вся цепочка по дереву + комплектация +
///  стеклопакет + размеры. Все размеры показаны УЖЕ В МИЛЛИМЕТРАХ.
///  Лист можно СКОПИРОВАТЬ или ОТПРАВИТЬ (share_plus).
/// ═══════════════════════════════════════════════════════════════════
class MeasureSheetView extends StatefulWidget {
  const MeasureSheetView({
    super.key,
    required this.name,
    required this.phone,
    required this.addr,
    required this.flat,
    required this.floor,
    required this.path,
    required this.multi,
    required this.sizes,
    required this.glass,
    required this.onBack,
    required this.onFinish,
    this.profile = '',
    this.brand = '',
    this.series = '',
    this.armirovka = '',
    this.glassThk = 0,
    this.frameMm = 0,
    this.orderNo = '',
    this.sashModes = const [],
    this.widthMm = 0,
    this.visSizes = const {},
    this.sectionWidths = const [],
    this.hinges = const [],
    this.sandwich = 0,
    this.heightMm = 0,
    this.balcony = false,
    this.doorOnLeft = false,
    this.doorKind = 1,
    this.winParts = 1,
    this.winCellModes = const [],
    this.winSectionWidths = const [],
    this.winWidthMm = 0,
    this.winHeightMm = 0,
    this.doorWidthMm = 0,
  });

  /// Данные клиента.
  final String name;
  final String phone;
  final String addr;
  final String flat;
  final String floor;

  /// Цепочка дерева: ЗАМЕР · ОКНО · ДВУХСТВОРЧАТОЕ · КИРПИЧКА.
  final List<String> path;

  /// Отмеченная комплектация.
  final List<String> multi;

  /// Размеры: пункт → поле → МИЛЛИМЕТРЫ.
  final Map<String, Map<String, int>> sizes;

  /// Выбранный стеклопакет ('' — не выбран).
  final String glass;

  /// Толщина профиля (рамы) из дерева: 'ПРОФИЛЬ 60 ММ' / 'ПРОФИЛЬ 70 ММ'.
  final String profile;

  /// Марка профиля из дерева: REHAU, VEKA, KBE и т.п.
  final String brand;

  /// Серия профиля из дерева: GRAZIO · 70, SOFTLINE 70 и т.п.
  final String series;

  /// АРМИРОВКА (армирование) профиля: «ЗАМКНУТЫЙ КОНТУР · 1,5 ММ».
  /// Считается по толщине серии (lib/price_estimate.dart → armirovkaFor).
  final String armirovka;

  /// Толщина стеклопакета, ММ (24 / 32 / 40).
  final int glassThk;

  /// Толщина рамы, ММ (60 / 70 / 75 …). По ней видно, что влезает.
  final int frameMm;

  /// НОМЕР ЗАКАЗА — свой у каждого замера («ЗК-0001»). Пусто — не присвоен.
  final String orderNo;

  /// Обозначения створок по ГОСТ (по порядку слева направо).
  final List<String> sashModes;

  /// Габарит по ширине, мм (0 — неизвестно) — для ширин секций.
  final int widthMm;

  /// РАЗМЕРЫ С ЧЕРТЕЖА (тап по цифре): ШИРИНА, ВЫСОТА, ШИРИНА ОКНА,
  /// ВЫСОТА ОКНА, ШИРИНА ДВЕРИ. У изделий с чертежом пункты комплектации
  /// размеров не имеют — размеры берём отсюда.
  final Map<String, int> visSizes;

  /// Доли ширины секций (сумма ≈ 1.0). Пусто — секции равные.
  final List<double> sectionWidths;

  /// Число петель на каждой створке (пусто — по 2: верхняя и нижняя).
  /// Нужно ЗАВОДУ: сколько петель заказывать на изделие.
  final List<int> hinges;

  /// Число СЭНДВИЧ-ПАНЕЛЕЙ в изделии (0 — нет).
  /// Балконная дверь с низом из сэндвича — 1 панель.
  final int sandwich;

  /// ГАБАРИТ ПО ВЫСОТЕ, ММ (0 — взять из размеров пунктов).
  /// У изделий с чертежом размеры вводятся тапом по цифре и в пункты
  /// комплектации не попадают — высоту передаём отдельно.
  final int heightMm;

  /// БАЛКОННЫЙ БЛОК: окно + дверь в ОДНОЙ раме.
  /// В PDF рисуется СВОИМ чертежом (SheetVisual.balconySvg), а не окном.
  final bool balcony;

  /// Зеркало балконного блока: дверь СЛЕВА (иначе окно слева).
  final bool doorOnLeft;

  /// Вид балконной двери: 0 — стекло в пол, 1 — стекло + сэндвич,
  /// 2 — стекло + стекло.
  final int doorKind;

  /// Частей в оконной части балконного блока: 1 или 2.
  final int winParts;

  /// Обозначение частей окна: 0 — глухарь, 1 — створка.
  final List<int> winCellModes;

  /// Доли ширины частей окна (пусто — поровну).
  final List<double> winSectionWidths;

  /// Ширина окна балконного блока, ММ.
  final int winWidthMm;

  /// Высота окна балконного блока, ММ.
  final int winHeightMm;

  /// Ширина двери балконного блока, ММ.
  final int doorWidthMm;

  /// Назад — к визуальному замеру.
  final VoidCallback onBack;

  /// Готово — в главное меню.
  final VoidCallback onFinish;

  @override
  State<MeasureSheetView> createState() => _MeasureSheetViewState();
}

class _MeasureSheetViewState extends State<MeasureSheetView> {
  bool _copied = false;

  /// Фото проёма этого замера (привязаны к клиенту и адресу).
  List<MeasurePhoto> _photos = [];

  /// Идёт отправка на сервер.
  bool _syncBusy = false;

  /// Ключ сессии замера для хранилища фото.
  String get _mediaKey =>
      '${widget.name.trim().toLowerCase()}_${widget.addr.trim().toLowerCase()}';

  @override
  void initState() {
    super.initState();
    PhotoStore.load(_mediaKey).then((p) {
      if (mounted) setState(() => _photos = p);
    });
  }

  String get _dash => '─' * 26;

  /// Стеклопакет одной строкой: «2-КАМ · 32 ММ · РАМА 70 ММ».
  /// Камерность и толщина — ОДНИ на всё изделие (все стеклопакеты сразу).
  String get _glassLine {
    final g = widget.glass.isEmpty ? 'НЕ ВЫБРАН' : widget.glass;
    final parts = <String>[g];
    if (widget.glassThk > 0) parts.add('${widget.glassThk} ММ');
    if (widget.frameMm > 0) parts.add('РАМА ${widget.frameMm} ММ');
    return parts.join(' · ');
  }

  /// ГАБАРИТ ПО ШИРИНЕ, ММ: из дерева, иначе — из размеров пунктов.
  int get _widthMm {
    if (widget.widthMm > 0) return widget.widthMm;
    final v = widget.visSizes['ШИРИНА'] ?? 0;
    if (v > 0) return v;
    var best = 0;
    for (final f in widget.sizes.values) {
      f.forEach((k, v) {
        if (k.toUpperCase().contains('ШИРИН') && v > best) best = v;
      });
    }
    return best;
  }

  /// ГАБАРИТ ПО ВЫСОТЕ, ММ: переданный явно, иначе — из размеров пунктов.
  int get _heightMm {
    if (widget.heightMm > 0) return widget.heightMm;
    final v = widget.visSizes['ВЫСОТА'] ?? 0;
    if (v > 0) return v;
    var best = 0;
    for (final f in widget.sizes.values) {
      f.forEach((k, v) {
        if (k.toUpperCase().contains('ВЫСОТ') && v > best) best = v;
      });
    }
    return best;
  }

  /// БАЛКОННЫЙ БЛОК — окно + дверь в ОДНОЙ раме.
  /// Флаг из мастера, а если он не дошёл — определяем по цепочке дерева:
  /// так чертёж в PDF всё равно будет балконным блоком, а не окном.
  bool get _balcony =>
      widget.balcony ||
      (widget.path.length > 1 &&
          widget.path[1].toUpperCase() == 'БАЛКОННЫЙ БЛОК');

  /// Вид низа балконной двери: 0 — стекло в пол, 1 — стекло + сэндвич,
  /// 2 — стекло + стекло.
  String get _doorKindName =>
      const ['СТЕКЛО В ПОЛ', 'СТЕКЛО + СЭНДВИЧ', 'СТЕКЛО + СТЕКЛО']
          [widget.doorKind.clamp(0, 2)];

  /// Частей в оконной части балконного блока (1 или 2).
  int get _winParts => widget.winParts.clamp(1, 2);

  /// «ОКНО 1 ЧАСТ. · ДВЕРЬ СТЕКЛО + СЭНДВИЧ» — состав балконного блока.
  String get _balconyLine => 'ОКНО $_winParts ЧАСТ. · ДВЕРЬ $_doorKindName';

  /// СТВОРОК ВСЕГО, ШТ. У балконного блока — дверь + части окна.
  int get _sashTotal => _balcony ? _winParts + 1 : widget.sashModes.length;

  /// ОТКРЫВАЮЩИХСЯ створок: у блока — дверь + открывающиеся части окна.
  int get _openingSashes => _balcony
      ? 1 + widget.winCellModes.where((m) => m != 0).length
      : widget.sashModes.where((m) => _modeIndex(m) != 0).length;

  /// РУЧКИ, ШТ — по одной на каждую ОТКРЫВАЮЩУЮСЯ створку (авто).
  int get _handles => _openingSashes;

  /// ПЕТЛИ, ШТ — по створкам: по 2 на открывающуюся, если не задано иначе.
  int get _hingesTotal {
    // Балконный блок: по 2 петли на дверь и на каждую открывающуюся
    // часть окна.
    if (_balcony) return _openingSashes * 2;
    final n = widget.sashModes.length;
    if (n == 0) return 0;
    final h = widget.hinges;
    var sum = 0;
    for (var i = 0; i < n; i++) {
      if (_modeIndex(widget.sashModes[i]) == 0) continue; // глухая — без петель
      sum += (h.length == n ? h[i] : 2).clamp(2, 6);
    }
    return sum;
  }

  /// СТЕКЛОПАКЕТОВ, ШТ — по одному на каждую створку.
  /// У балконного блока — части окна + дверь (в двери стекло всегда).
  int get _glassUnits => _balcony
      ? _winParts + 1
      : (widget.sashModes.isEmpty ? 0 : widget.sashModes.length);

  /// СПЕЦИФИКАЦИЯ ДЛЯ ЗАВОДА — всё, что завод изготавливает и поставляет:
  /// название изделия, размеры, профиль, армировка, стеклопакеты,
  /// сэндвич-панели, фурнитура (ручки и петли — количество авто),
  /// комплектация.
  List<(String, String)> get _factorySpec => [
        ('ИЗДЕЛИЕ', widget.path.isEmpty ? '—' : widget.path.join(' · ')),
        ('ПРОФИЛЬ', _or(widget.profile, '—')),
        ('МАРКА', _or(widget.brand, '—')),
        ('СЕРИЯ', _or(widget.series, '—')),
        ('АРМИРОВКА', _or(widget.armirovka, '—')),
        ('СТЕКЛОПАКЕТ', widget.glass.isEmpty ? 'НЕ ВЫБРАН' : _glassLine),
        if (_glassUnits > 0) ('СТЕКЛОПАКЕТОВ, ШТ', '$_glassUnits'),
        if (widget.sandwich > 0) ('СЭНДВИЧ-ПАНЕЛИ, ШТ', '${widget.sandwich}'),
        if (_sashTotal > 0) ('СТВОРОК, ШТ', '$_sashTotal'),
        if (_sashTotal > 0) ('ОТКРЫВАЮЩИХСЯ, ШТ', '$_openingSashes'),
        if (_handles > 0) ('РУЧКИ, ШТ', '$_handles'),
        if (_hingesTotal > 0) ('ПЕТЛИ, ШТ', '$_hingesTotal'),
        if (_widthMm > 0) ('ШИРИНА', '$_widthMm ММ'),
        if (_heightMm > 0) ('ВЫСОТА', '$_heightMm ММ'),
        if (_balcony && widget.winWidthMm > 0)
          ('ШИРИНА ОКНА', '${widget.winWidthMm} ММ'),
        if (_balcony && widget.winHeightMm > 0)
          ('ВЫСОТА ОКНА', '${widget.winHeightMm} ММ'),
        if (_balcony && widget.doorWidthMm > 0)
          ('ШИРИНА ДВЕРИ', '${widget.doorWidthMm} ММ'),
        if (_balcony)
          ('СТОРОНА ДВЕРИ', widget.doorOnLeft ? 'СЛЕВА' : 'СПРАВА'),
        if (_balcony) ('ДВЕРЬ', _doorKindName),
        if (_balcony) ('ОКОННАЯ ЧАСТЬ', '$_winParts ЧАСТ.'),
        if (!_balcony && widget.sashModes.isNotEmpty && widget.widthMm > 0)
          ('ШИРИНА СЕКЦИЙ', _sectionsMm()),
        ('КОМПЛЕКТАЦИЯ', widget.multi.isEmpty ? '—' : widget.multi.join(' · ')),
      ];

  /// Строки СПЕЦИФИКАЦИИ для правой колонки A4-листа.
  List<(String, String)> get _specRows => [
        ('ПРОФИЛЬ', _or(widget.profile, '—')),
        ('МАРКА', _or(widget.brand, '—')),
        ('СЕРИЯ', _or(widget.series, '—')),
        ('АРМИРОВКА', _or(widget.armirovka, '—')),
        ('СТЕКЛОПАКЕТ', widget.glass.isEmpty ? 'НЕ ВЫБРАН' : _glassLine),
        if (_balcony) ('КОНСТРУКЦИЯ', _balconyLine),
        if (!_balcony && widget.sashModes.isNotEmpty)
          ('КОНСТРУКЦИЯ',
              '${widget.sashModes.length} СТВ. · ${_sashLetters()}'),
        if (_widthMm > 0) ('ШИРИНА', '$_widthMm ММ'),
        if (_heightMm > 0) ('ВЫСОТА', '$_heightMm ММ'),
        if (_balcony && widget.winWidthMm > 0)
          ('ШИРИНА ОКНА', '${widget.winWidthMm} ММ'),
        if (_balcony && widget.winHeightMm > 0)
          ('ВЫСОТА ОКНА', '${widget.winHeightMm} ММ'),
        if (_balcony && widget.doorWidthMm > 0)
          ('ШИРИНА ДВЕРИ', '${widget.doorWidthMm} ММ'),
      ];

  /// Текст замерного листа — все размеры в миллиметрах.
  String _sheetText() {
    final b = StringBuffer();
    b.writeln('ЗАМЕРНЫЙ ЛИСТ');
    if (widget.orderNo.trim().isNotEmpty) {
      b.writeln('ЗАКАЗ № ${widget.orderNo.trim()}');
    }
    b.writeln(_dash);

    b.writeln('КЛИЕНТ: ${_or(widget.name, '—')}');
    b.writeln('ТЕЛЕФОН: ${_or(widget.phone, '—')}');
    b.writeln('АДРЕС: ${_or(widget.addr, '—')}');
    b.writeln(
        'КВАРТИРА / ЭТАЖ: ${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}');
    b.writeln(_dash);

    b.writeln('ИЗДЕЛИЕ: ${widget.path.isEmpty ? '—' : widget.path.join(' · ')}');
    b.writeln('ПРОФИЛЬ: ${_or(widget.profile, '—')}');
    b.writeln('МАРКА: ${_or(widget.brand, '—')}');
    b.writeln('СЕРИЯ: ${_or(widget.series, '—')}');
    b.writeln('АРМИРОВКА: ${_or(widget.armirovka, '—')}');
    b.writeln('СТЕКЛОПАКЕТ: ${widget.glass.isEmpty ? '—' : _glassLine}');
    if (_balcony) {
      b.writeln('БАЛКОННЫЙ БЛОК: $_balconyLine');
      for (final r in _visRows()) {
        b.writeln('${r.$1}: ${r.$2}');
      }
    }
    b.writeln('ФОТО ПРОЁМА: ${_photos.isEmpty ? '—' : '${_photos.length} шт'}');
    if (widget.sashModes.isNotEmpty) {
      final s = <String>[];
      for (var i = 0; i < widget.sashModes.length; i++) {
        s.add('${i + 1}-${widget.sashModes[i]}');
      }
      b.writeln('СТВОРКИ: ${s.join(' · ')}');
      b.writeln('КОНСТРУКЦИЯ: ${widget.sashModes.length} '
          '${_sashWord(widget.sashModes.length)} · ${_sashLetters()}');
      if (widget.widthMm > 0) {
        b.writeln('ШИРИНА СЕКЦИЙ (ММ): ${_sectionsMm()}');
      }
    }
    b.writeln(_dash);

    b.writeln('РАЗМЕРЫ (ММ):');
    if (widget.multi.isEmpty) {
      b.writeln('— НЕ ВЫБРАНО');
    } else {
      for (final item in widget.multi) {
        b.writeln('• $item');
        final f = widget.sizes[item];
        if (f == null || f.isEmpty) {
          b.writeln('   РАЗМЕРЫ НЕ ЗАПОЛНЕНЫ');
        } else {
          f.forEach((k, v) => b.writeln('   $k: $v мм'));
        }
      }
    }
    b.writeln(_dash);
    return b.toString();
  }

  /// «1-ПОВОРОТНАЯ · 2-ГЛУХАЯ» — обозначения створок по ГОСТ.
  String _sashLine() {
    final s = <String>[];
    for (var i = 0; i < widget.sashModes.length; i++) {
      s.add('${i + 1} · ${widget.sashModes[i]}');
    }
    return s.join('   ');
  }

  /// «Г · ПО» — буквы по ГОСТ.
  String _sashLetters() => widget.sashModes
      .map((m) => kSashModeLetter[_modeIndex(m)])
      .join(' · ');

  /// «1 · 600 мм   2 · 700 мм» — ширина каждой секции (с учётом ручной).
  String _sectionsMm() {
    final n = widget.sashModes.length;
    if (n == 0) return '—';
    final s = <String>[];
    for (var i = 0; i < n; i++) {
      s.add('${i + 1} · ${(widget.widthMm * _secShare(i, n)).round()} мм');
    }
    return s.join('   ');
  }

  /// Доля ширины секции i (ручная или равная).
  double _secShare(int i, int n) {
    final w = widget.sectionWidths;
    if (w.length == n) {
      final sum = w.fold<double>(0, (a, b) => a + b);
      if (sum > 0) return w[i] / sum;
    }
    return 1.0 / n;
  }

  String _sashWord(int n) => n == 1 ? 'СТВОРКА' : 'СТВОРКИ';

  /// Индекс типа створки по её названию (для буквы по ГОСТ).
  int _modeIndex(String name) {
    final i = kSashModeNames.indexOf(name.toUpperCase());
    return i < 0 ? 0 : i;
  }

  String _or(String v, String fallback) {
    final t = v.trim();
    return t.isEmpty ? fallback : t;
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _sheetText()));
    if (!mounted) return;
    setState(() => _copied = true);
    _snack('ЗАМЕРНЫЙ ЛИСТ СКОПИРОВАН');
  }

  /// Выбор адресата: лист ПЕРЕСОБИРАЕТСЯ под того, кому отправляем.
  Future<void> _pickRecipient() async {
    final r = await showModalBottomSheet<SheetRecipient>(
      context: context,
      backgroundColor: const Color(0xFF0B1524),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _recipientSheet(),
    );
    if (r == null) return;
    await _exportFor(r);
  }

  /// Шторка «КОМУ ОТПРАВИТЬ ЛИСТ».
  Widget _recipientSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'КОМУ ОТПРАВИТЬ ЛИСТ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),
            for (final r in SheetRecipient.values) ...[
              _recipientTile(r),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _recipientTile(SheetRecipient r) {
    return GestureDetector(
      onTap: () {
        flashScreen();
        Navigator.pop(context, r);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1220),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.42)),
        ),
        child: Row(
          children: [
            const Icon(Icons.send_rounded, size: 16, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.hint,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: Color(0xFF7E93AC)),
          ],
        ),
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF12233A),
        content: Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.multi;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _head(),
                const SizedBox(height: 12),
                _block('КЛИЕНТ', [
                  ('ИМЯ', _or(widget.name, '—')),
                  ('ТЕЛЕФОН', _or(widget.phone, '—')),
                  ('АДРЕС', _or(widget.addr, '—')),
                  ('КВ. / ЭТАЖ',
                      '${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}'),
                ]),
                const SizedBox(height: 12),
                _block('ИЗДЕЛИЕ', [
                  ('ЦЕПОЧКА',
                      widget.path.isEmpty ? '—' : widget.path.join(' · ')),
                  ('ПРОФИЛЬ', _or(widget.profile, '—')),
                  ('МАРКА', _or(widget.brand, '—')),
                  ('СЕРИЯ', _or(widget.series, '—')),
                  ('АРМИРОВКА', _or(widget.armirovka, '—')),
                  ('СТЕКЛОПАКЕТ',
                      widget.glass.isEmpty ? 'НЕ ВЫБРАН' : _glassLine),
                ]),
                const SizedBox(height: 12),
                if (widget.sashModes.isNotEmpty) ...[
                  _block('КОНСТРУКЦИЯ', [
                    ('СТВОРОК', '${widget.sashModes.length}'),
                    ('СТВОРКИ', _sashLine()),
                    ('ПО ГОСТ', _sashLetters()),
                    if (widget.widthMm > 0)
                      ('ШИРИНА СЕКЦИЙ', _sectionsMm()),
                  ]),
                  const SizedBox(height: 12),
                ],
                _sizesBlock(items),
                const SizedBox(height: 12),
                MeasureMediaPanel(
                  sessionKey: _mediaKey,
                  photos: _photos,
                  onChanged: (p) => setState(() => _photos = p),
                ),
                const SizedBox(height: 12),
                _sheetButton(),
                const SizedBox(height: 10),
                _pdfRow(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _SheetGhost('НАЗАД', Icons.arrow_back_rounded, widget.onBack),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetGold(
                    'ОТПРАВИТЬ', Icons.send_rounded, _pickRecipient),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── ЗАГОЛОВОК ───────────────────────────
  Widget _head() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152740), Color(0xFF0B1524)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
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
            child: const Icon(Icons.receipt_long_rounded,
                size: 20, color: AppColors.navy900),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ЗАМЕРНЫЙ ЛИСТ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ВСЕ РАЗМЕРЫ В МИЛЛИМЕТРАХ',
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
          if (widget.orderNo.trim().isNotEmpty) ...[
            const SizedBox(width: 10),
            _orderChip(),
          ],
        ],
      ),
    );
  }

  /// Плашка НОМЕРА ЗАКАЗА в шапке листа («ЗАКАЗ · ЗК-0001»).
  Widget _orderChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.14),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.gold.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'ЗАКАЗ',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF7E93AC),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.orderNo.trim(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── БЛОК СТРОК ───────────────────────────
  Widget _block(String title, List<(String, String)> rows) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    rows[i].$1,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────── БЛОК РАЗМЕРОВ ───────────────────────────
  Widget _sizesBlock(List<String> items) {
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
                  'РАЗМЕРЫ',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                ),
                child: Text(
                  'ММ',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'НИЧЕГО НЕ ВЫБРАНО',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Color(0xFF7E93AC),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _sizeItem(items[i]),
            ],
        ],
      ),
    );
  }

  Widget _sizeItem(String item) {
    final f = widget.sizes[item];
    final rows = <MapEntry<String, int>>[
      if (f != null) ...f.entries,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 14, color: AppColors.gold),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 21),
            child: Text(
              'РАЗМЕРЫ НЕ ЗАПОЛНЕНЫ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF7E93AC),
              ),
            ),
          )
        else
          for (final e in rows)
            Padding(
              padding: const EdgeInsets.only(left: 21, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9FB0C6),
                      ),
                    ),
                  ),
                  Text(
                    '${e.value} мм',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  // ─────────────────────────── КОПИРОВАТЬ ───────────────────────────
  Widget _sheetButton() {
    return GestureDetector(
      onTap: () {
        flashScreen();
        _copy();
      },
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1220),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.42)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 16,
              color: AppColors.gold,
            ),
            const SizedBox(width: 8),
            Text(
              _copied ? 'СКОПИРОВАНО' : 'СКОПИРОВАТЬ ЛИСТ',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── PDF-ЛИСТ И ОТПРАВКА НА СЕРВЕР ───────────────────
  Widget _pdfRow() {
    return Row(
      children: [
        Expanded(
          child: _SheetGhost(
            'PDF / ЛИСТ',
            Icons.picture_as_pdf_rounded,
            _exportSheet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SheetGhost(
            _syncBusy ? 'ОТПРАВКА...' : 'НА СЕРВЕР',
            Icons.cloud_upload_rounded,
            _syncBusy ? _noop : _pushToServer,
          ),
        ),
      ],
    );
  }

  void _noop() {}

  /// Полный лист замерщика — все блоки, все данные.
  Future<void> _exportSheet() => _exportFor(SheetRecipient.measurer);

  /// Все строки «ДАННЫЕ ЗАМЕРА» (полный лист).
  List<(String, String)> _allRows() => [
        ('ТЕЛЕФОН', _or(widget.phone, '—')),
        ('АДРЕС', _or(widget.addr, '—')),
        ('КВ. / ЭТАЖ', '${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}'),
        ('ПРОФИЛЬ', _or(widget.profile, '—')),
        ('МАРКА', _or(widget.brand, '—')),
        ('СЕРИЯ', _or(widget.series, '—')),
        ('АРМИРОВКА', _or(widget.armirovka, '—')),
        ('СТЕКЛОПАКЕТ', widget.glass.isEmpty ? 'НЕ ВЫБРАН' : _glassLine),
        if (_balcony) ('КОНСТРУКЦИЯ', _balconyLine),
        if (!_balcony && widget.sashModes.isNotEmpty)
          ('КОНСТРУКЦИЯ',
              '${widget.sashModes.length} СТВ. · ${_sashLetters()}'),
        if (!_balcony && widget.sashModes.isNotEmpty && widget.widthMm > 0)
          ('ШИРИНА СЕКЦИЙ', _sectionsMm()),
        ..._visRows(),
        for (final item in widget.multi)
          if ((widget.sizes[item] ?? const <String, int>{}).isNotEmpty)
            (item, _sizesLine(item)),
      ];

  /// Спецификация под адресата — что показываем в правой колонке A4.
  List<(String, String)> _specFor(SheetRecipient r) {
    switch (r) {
      case SheetRecipient.measurer:
        return _specRows;
      case SheetRecipient.factory:
        return _factorySpec;
      case SheetRecipient.client:
        return [
          ('ИЗДЕЛИЕ', widget.path.isEmpty ? '—' : widget.path.join(' · ')),
          ('ПРОФИЛЬ', _or(widget.series, _or(widget.brand, '—'))),
          ('СТЕКЛОПАКЕТ', widget.glass.isEmpty ? 'НЕ ВЫБРАН' : _glassLine),
          if (_balcony) ('КОНСТРУКЦИЯ', _balconyLine),
          if (!_balcony && widget.sashModes.isNotEmpty)
            ('КОНСТРУКЦИЯ',
                '${widget.sashModes.length} СТВ. · ${_sashLetters()}'),
          if (_widthMm > 0) ('ШИРИНА', '$_widthMm ММ'),
          if (_heightMm > 0) ('ВЫСОТА', '$_heightMm ММ'),
          ('КОМПЛЕКТАЦИЯ',
              widget.multi.isEmpty ? '—' : widget.multi.join(' · ')),
        ];
      case SheetRecipient.installer:
        return [
          if (_widthMm > 0) ('ШИРИНА', '$_widthMm ММ'),
          if (_heightMm > 0) ('ВЫСОТА', '$_heightMm ММ'),
          if (_balcony) ('КОНСТРУКЦИЯ', _balconyLine),
          if (!_balcony && widget.sashModes.isNotEmpty)
            ('КОНСТРУКЦИЯ',
                '${widget.sashModes.length} СТВ. · ${_sashLetters()}'),
          if (!_balcony && widget.sashModes.isNotEmpty && widget.widthMm > 0)
            ('ШИРИНА СЕКЦИЙ', _sectionsMm()),
        ];
    }
  }

  /// Строки «ДАННЫЕ ЗАМЕРА» под адресата.
  List<(String, String)> _rowsFor(SheetRecipient r) {
    switch (r) {
      case SheetRecipient.measurer:
        return _allRows();
      case SheetRecipient.factory:
        return [for (final item in widget.multi) (item, _sizesLine(item))];
      case SheetRecipient.installer:
        return [
          ('АДРЕС', _or(widget.addr, '—')),
          ('КВ. / ЭТАЖ',
              '${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}'),
          ('ТЕЛЕФОН', _or(widget.phone, '—')),
          for (final item in widget.multi) (item, _sizesLine(item)),
        ];
      case SheetRecipient.client:
        return [];
    }
  }

  /// Чей прайс брать для адресата. ЗАВОД цен не видит — null.
  PriceOwner? _ownerFor(SheetRecipient r) => switch (r) {
        SheetRecipient.measurer => PriceOwner.measurer,
        SheetRecipient.client => PriceOwner.client,
        SheetRecipient.installer => PriceOwner.installer,
        SheetRecipient.factory => null,
      };

  /// СМЕТА под адресата — по ЕГО прайсу из настроек.
  /// null — считать нечего или цену показывать не нужно.
  Future<Estimate?> _estimateFor(SheetRecipient r) async {
    final owner = _ownerFor(r);
    if (owner == null) return null;
    final book = await PriceSettings.load(owner);
    final e = buildEstimate(
      widthMm: _widthMm,
      heightMm: _heightMm,
      windowType: widget.path.join(' · '),
      parts: widget.multi,
      glass: widget.glass,
      profile: widget.profile,
      brand: widget.brand,
      series: widget.series,
      book: book,
    );
    return e.isEmpty ? null : e;
  }

  /// Подпись итога под адресата.
  String _priceLabel(SheetRecipient r) => switch (r) {
        SheetRecipient.client => 'ИТОГО · ПРИБЛИЗИТЕЛЬНО',
        SheetRecipient.installer => 'ИТОГО ЗА РАБОТУ',
        _ => 'ИТОГО · ПРИБЛИЗИТЕЛЬНО',
      };

  /// Собрать лист ПОД АДРЕСАТА и отдать на печать → PDF / отправку.
  Future<void> _exportFor(SheetRecipient r) async {
    final photos = r.showPhotos
        ? await PhotoStore.asBase64(_photos)
        : <(MeasurePhoto, String)>[];
    // БАЛКОННЫЙ БЛОК рисуется СВОИМ чертежом (окно + дверь в одной раме).
    // Иначе в PDF выходило одностворчатое окно: у блока створок в замере
    // одна, и обычный чертёж рисовал её как целое изделие.
    final visual = r.showVisual
        ? (_balcony
            ? SheetVisual.balconySvg(
                widthMm: _widthMm,
                heightMm: _heightMm,
                winWidthMm: widget.winWidthMm,
                winHeightMm: widget.winHeightMm,
                doorWidthMm: widget.doorWidthMm,
                doorOnLeft: widget.doorOnLeft,
                doorKind: widget.doorKind,
                winParts: widget.winParts,
                winCellModes: widget.winCellModes,
                winSectionWidths: widget.winSectionWidths,
                glassLabel: widget.glass.isEmpty ? '' : widget.glass,
                glassThk: widget.glassThk,
              )
            : SheetVisual.svg(
                sashes: widget.sashModes.isEmpty ? 1 : widget.sashModes.length,
                modes: [for (final m in widget.sashModes) _modeIndex(m)],
                sectionWidths: widget.sectionWidths,
                widthMm: _widthMm,
                heightMm: _heightMm,
                glassLabel: widget.glass.isEmpty ? '' : widget.glass,
                glassThk: widget.glassThk,
              ))
        : '';
    final est = await _estimateFor(r);
    final html = SheetExport.html(
      client: _or(widget.name, '—'),
      product: widget.path.isEmpty ? '—' : widget.path.join(' · '),
      order: r.showOrder ? widget.orderNo.trim() : '',
      title: r.sheetTitle,
      visual: visual,
      spec: _specFor(r),
      rows: _rowsFor(r),
      photos: photos,
      showVisual: r.showVisual,
      showSpec: r.showSpec,
      showRows: r.showRows,
      showPhotos: r.showPhotos,
      showClient: r.showClient,
      price: est == null ? '' : money(est.total),
      priceLabel: _priceLabel(r),
      priceLines: r == SheetRecipient.measurer && est != null
          ? [for (final l in est.lines) (l.title, money(l.sum))]
          : const [],
    );
    final path = await SheetExport.save(html, 'zamer_${r.name}');
    if (!mounted) return;
    await SheetExport.share(path, _sheetText());
  }

  /// Размеры С ЧЕРТЕЖА (изделия с визуалкой: окно, балконный блок, дверь).
  /// У них размеры вводятся тапом по цифре, а не по пунктам комплектации.
  List<(String, String)> _visRows() {
    final out = <(String, String)>[];
    for (final f in const [
      'ШИРИНА',
      'ВЫСОТА',
      'ШИРИНА ОКНА',
      'ВЫСОТА ОКНА',
      'ШИРИНА ДВЕРИ',
    ]) {
      final v = widget.visSizes[f] ?? 0;
      if (v > 0) out.add((f, '$v ММ'));
    }
    return out;
  }

  /// «ШИРИНА: 1300 мм · ВЫСОТА: 1400 мм» — размеры одного пункта.
  String _sizesLine(String item) {
    final f = widget.sizes[item];
    if (f == null || f.isEmpty) return 'РАЗМЕРЫ НЕ ЗАПОЛНЕНЫ';
    return f.entries.map((e) => '${e.key}: ${e.value} мм').join(' · ');
  }

  /// Отправить замер на сервер Штаба; нет сети — замер уходит в очередь.
  Future<void> _pushToServer() async {
    setState(() => _syncBusy = true);
    final payload = <String, dynamic>{
      'client': _or(widget.name, '—'),
      'phone': _or(widget.phone, '—'),
      'address': _or(widget.addr, '—'),
      'flat': _or(widget.flat, '—'),
      'floor': _or(widget.floor, '—'),
      'product': widget.path,
      'multi': widget.multi,
      'glass': widget.glass,
      'glassThk': widget.glassThk,
      'frameMm': widget.frameMm,
      'profile': widget.profile,
      'brand': widget.brand,
      'series': widget.series,
      'armirovka': widget.armirovka,
      'order': widget.orderNo.trim(),
      'sash': widget.sashModes,
      'hinges': widget.hinges,
      'sandwich': widget.sandwich,
      'widthMm': widget.widthMm,
      'sizes': widget.sizes,
      'photos': _photos.length,
      'at': DateTime.now().millisecondsSinceEpoch,
    };
    final ok = await MeasureSync.push(payload);
    final pending = await MeasureSync.pending();
    if (!mounted) return;
    setState(() => _syncBusy = false);
    _snack(ok
        ? 'ЗАМЕР ОТПРАВЛЕН НА СЕРВЕР'
        : 'СЕТИ НЕТ · ЗАМЕР В ОЧЕРЕДИ (${pending})');
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЗОЛОТАЯ КНОПКА
/// ═══════════════════════════════════════════════════════════════════
class _SheetGold extends StatefulWidget {
  const _SheetGold(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SheetGold> createState() => _SheetGoldState();
}

class _SheetGoldState extends State<_SheetGold> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen();
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
///  ПРОЗРАЧНАЯ КНОПКА «НАЗАД»
/// ═══════════════════════════════════════════════════════════════════
class _SheetGhost extends StatefulWidget {
  const _SheetGhost(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SheetGhost> createState() => _SheetGhostState();
}

class _SheetGhostState extends State<_SheetGhost> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen();
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
