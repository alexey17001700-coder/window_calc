import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'theme.dart';
import 'measure_item.dart';
import 'measure_media.dart';
import 'window_visual.dart';
import 'work_tree.dart';

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
    this.items = const [],
    this.sashModes = const [],
    this.widthMm = 0,
    this.sectionWidths = const [],
  });

  /// Все изделия замера (новый режим: один замер — несколько изделий).
  /// Пусто — лист показывает одно изделие из одиночных полей ниже.
  final List<MeasureItem> items;

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

  /// Обозначения створок по ГОСТ (по порядку слева направо).
  final List<String> sashModes;

  /// Габарит по ширине, мм (0 — неизвестно) — для ширин секций.
  final int widthMm;

  /// Доли ширины секций (сумма ≈ 1.0). Пусто — секции равные.
  final List<double> sectionWidths;

  /// Назад — к визуальному замеру.
  final VoidCallback onBack;

  /// Готово — в главное меню.
  final VoidCallback onFinish;

  @override
  State<MeasureSheetView> createState() => _MeasureSheetViewState();
}

/// Одно изделие, разобранное для показа в листе:
/// стеклопакет — уже текстом, створки — названиями по ГОСТ.
class _SheetItem {
  _SheetItem({
    required this.path,
    required this.multi,
    required this.sizes,
    required this.glass,
    required this.sashModes,
    required this.widthMm,
    required this.sectionWidths,
  });

  final List<String> path;
  final List<String> multi;
  final Map<String, Map<String, int>> sizes;
  final String glass;
  final List<String> sashModes;
  final int widthMm;
  final List<double> sectionWidths;
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

  /// Все изделия листа: из списка MeasureItem либо из одиночных полей.
  List<_SheetItem> get _items {
    if (widget.items.isNotEmpty) {
      return [
        for (final it in widget.items)
          _SheetItem(
            path: it.path,
            multi: it.multi,
            sizes: it.sizes,
            glass: (it.glass >= 0 && it.glass < glassTypes.length)
                ? glassTypes[it.glass].title
                : '',
            sashModes: [
              for (final m in it.modes)
                kSashModeNames[m.clamp(0, kSashModeNames.length - 1)],
            ],
            widthMm: it.mmOf('ШИРИНА'),
            sectionWidths: it.secWidths,
          ),
      ];
    }
    return [
      _SheetItem(
        path: widget.path,
        multi: widget.multi,
        sizes: widget.sizes,
        glass: widget.glass,
        sashModes: widget.sashModes,
        widthMm: widget.widthMm,
        sectionWidths: widget.sectionWidths,
      ),
    ];
  }

  /// Текст замерного листа — все размеры в миллиметрах.
  String _sheetText() {
    final b = StringBuffer();
    b.writeln('ЗАМЕРНЫЙ ЛИСТ');
    b.writeln(_dash);

    b.writeln('КЛИЕНТ: ${_or(widget.name, '—')}');
    b.writeln('ТЕЛЕФОН: ${_or(widget.phone, '—')}');
    b.writeln('АДРЕС: ${_or(widget.addr, '—')}');
    b.writeln(
        'КВАРТИРА / ЭТАЖ: ${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}');
    b.writeln('ФОТО ПРОЁМА: ${_photos.isEmpty ? '—' : '${_photos.length} шт'}');
    b.writeln(_dash);

    final items = _items;
    for (var n = 0; n < items.length; n++) {
      final it = items[n];
      b.writeln(
          'ИЗДЕЛИЕ ${n + 1}: ${it.path.isEmpty ? '—' : it.path.join(' · ')}');
      b.writeln('СТЕКЛОПАКЕТ: ${it.glass.isEmpty ? '—' : it.glass}');
      if (it.sashModes.isNotEmpty) {
        final s = <String>[];
        for (var i = 0; i < it.sashModes.length; i++) {
          s.add('${i + 1}-${it.sashModes[i]}');
        }
        b.writeln('СТВОРКИ: ${s.join(' · ')}');
        b.writeln('КОНСТРУКЦИЯ: ${it.sashModes.length} '
            '${_sashWord(it.sashModes.length)} · ${_sashLettersOf(it.sashModes)}');
        if (it.widthMm > 0) {
          b.writeln('ШИРИНА СЕКЦИЙ (ММ): ${_sectionsMmOf(it)}');
        }
      }
      b.writeln('РАЗМЕРЫ (ММ):');
      if (it.multi.isEmpty) {
        b.writeln('— НЕ ВЫБРАНО');
      } else {
        for (final item in it.multi) {
          b.writeln('• $item');
          final f = it.sizes[item];
          if (f == null || f.isEmpty) {
            b.writeln('   РАЗМЕРЫ НЕ ЗАПОЛНЕНЫ');
          } else {
            f.forEach((k, v) => b.writeln('   $k: $v мм'));
          }
        }
      }
      b.writeln(_dash);
    }
    return b.toString();
  }

  /// «1-ПОВОРОТНАЯ · 2-ГЛУХАЯ» — обозначения створок по ГОСТ.
  String _sashLineOf(List<String> modes) {
    final s = <String>[];
    for (var i = 0; i < modes.length; i++) {
      s.add('${i + 1} · ${modes[i]}');
    }
    return s.join('   ');
  }

  /// «Г · ПО» — буквы по ГОСТ.
  String _sashLettersOf(List<String> modes) =>
      modes.map((m) => kSashModeLetter[_modeIndex(m)]).join(' · ');

  /// «1 · 600 мм   2 · 700 мм» — ширина каждой секции (с учётом ручной).
  String _sectionsMmOf(_SheetItem it) {
    final n = it.sashModes.length;
    if (n == 0) return '—';
    final s = <String>[];
    for (var i = 0; i < n; i++) {
      s.add('${i + 1} · ${(it.widthMm * _secShareOf(it, i, n)).round()} мм');
    }
    return s.join('   ');
  }

  /// Доля ширины секции i (ручная или равная).
  double _secShareOf(_SheetItem it, int i, int n) {
    final w = it.sectionWidths;
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

  Future<void> _share() async {
    await Share.share(_sheetText(), subject: 'Замерный лист');
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
    final items = _items;

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
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _itemBlock(i, items[i], items.length),
                ],
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
                child: _SheetGold('ОТПРАВИТЬ', Icons.send_rounded, _share),
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
        ],
      ),
    );
  }

  // ─────────────────────── БЛОК ОДНОГО ИЗДЕЛИЯ ───────────────────────
  Widget _itemBlock(int i, _SheetItem it, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _itemHead(i, total),
        const SizedBox(height: 10),
        _block('ИЗДЕЛИЕ', [
          ('ЦЕПОЧКА', it.path.isEmpty ? '—' : it.path.join(' · ')),
          ('СТЕКЛОПАКЕТ', it.glass.isEmpty ? 'НЕ ВЫБРАН' : it.glass),
        ]),
        if (it.sashModes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _block('КОНСТРУКЦИЯ', [
            ('СТВОРОК', '${it.sashModes.length}'),
            ('СТВОРКИ', _sashLineOf(it.sashModes)),
            ('ПО ГОСТ', _sashLettersOf(it.sashModes)),
            if (it.widthMm > 0) ('ШИРИНА СЕКЦИЙ', _sectionsMmOf(it)),
          ]),
        ],
        const SizedBox(height: 12),
        _sizesBlock(it.multi, it.sizes),
      ],
    );
  }

  /// Заголовок изделия: «ИЗДЕЛИЕ 2 ИЗ 3».
  Widget _itemHead(int i, int total) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'ИЗДЕЛИЕ ${i + 1} ИЗ $total',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
  Widget _sizesBlock(List<String> items, Map<String, Map<String, int>> sizes) {
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
              _sizeItem(items[i], sizes),
            ],
        ],
      ),
    );
  }

  Widget _sizeItem(String item, Map<String, Map<String, int>> sizes) {
    final f = sizes[item];
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
      onTap: _copy,
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

  /// Собрать лист в HTML (с фото) и отдать на печать → PDF / отправку.
  Future<void> _exportSheet() async {
    final photos = await PhotoStore.asBase64(_photos);
    final rows = <(String, String)>[
      ('ТЕЛЕФОН', _or(widget.phone, '—')),
      ('АДРЕС', _or(widget.addr, '—')),
      ('КВ. / ЭТАЖ', '${_or(widget.flat, '—')} / ${_or(widget.floor, '—')}'),
      ('СТЕКЛОПАКЕТ', widget.glass.isEmpty ? 'НЕ ВЫБРАН' : widget.glass),
      if (widget.sashModes.isNotEmpty)
        ('КОНСТРУКЦИЯ',
            '${widget.sashModes.length} СТВ. · ${_sashLetters()}'),
      if (widget.sashModes.isNotEmpty && widget.widthMm > 0)
        ('ШИРИНА СЕКЦИЙ', _sectionsMm()),
      for (final item in widget.multi) (item, _sizesLine(item)),
    ];

    final html = SheetExport.html(
      client: _or(widget.name, '—'),
      product: widget.path.isEmpty ? '—' : widget.path.join(' · '),
      rows: rows,
      photos: photos,
    );
    final path = await SheetExport.save(html, 'zamer');
    if (!mounted) return;
    await SheetExport.share(path, _sheetText());
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
      'sash': widget.sashModes,
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
      onTap: widget.onTap,
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
      onTap: widget.onTap,
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
