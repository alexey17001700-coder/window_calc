import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ШАГ «ЗАМЕРНЫЙ ЛИСТ»  ·  v3.4.17
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
    this.sashModes = const [],
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

  /// Обозначения створок по ГОСТ (по порядку слева направо).
  final List<String> sashModes;

  /// Назад — к визуальному замеру.
  final VoidCallback onBack;

  /// Готово — в главное меню.
  final VoidCallback onFinish;

  @override
  State<MeasureSheetView> createState() => _MeasureSheetViewState();
}

class _MeasureSheetViewState extends State<MeasureSheetView> {
  bool _copied = false;

  String get _dash => '─' * 26;

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
    b.writeln(_dash);

    b.writeln('ИЗДЕЛИЕ: ${widget.path.isEmpty ? '—' : widget.path.join(' · ')}');
    b.writeln('СТЕКЛОПАКЕТ: ${widget.glass.isEmpty ? '—' : widget.glass}');
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
                  ('СТЕКЛОПАКЕТ',
                      widget.glass.isEmpty ? 'НЕ ВЫБРАН' : widget.glass),
                ]),
                const SizedBox(height: 12),
                _sizesBlock(items),
                const SizedBox(height: 12),
                _sheetButton(),
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
