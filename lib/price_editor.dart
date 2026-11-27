import 'package:flutter/material.dart';

import 'price_estimate.dart';
import 'price_settings.dart';
import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  НАСТРОЙКИ ПРАЙСА  ·  v3.4.109
///  ТРИ отдельных прайса, как и просил Босс:
///   · ДЛЯ СЕБЯ       — всё изделие, цены ПРИБЛИЗИТЕЛЬНЫЕ;
///   · ДЛЯ КЛИЕНТА    — общая цена изделия;
///   · ДЛЯ МОНТАЖНИКА — цены за работу монтажника.
///  ЗАВОД цен не видит вообще — он сам присылает цены на комплектующие.
///  Замерщик задаёт цены ОДИН РАЗ здесь, лист считает по прайсу адресата
///  (lib/measure_sheet.dart → _estimateFor).
/// ═══════════════════════════════════════════════════════════════════
class PriceEditorScreen extends StatelessWidget {
  const PriceEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: PriceOwner.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('НАСТРОЙКИ ПРАЙСА'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.gold,
            unselectedLabelColor: const Color(0xFF7E93AC),
            indicatorColor: AppColors.gold,
            labelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
            tabs: [for (final o in PriceOwner.values) Tab(text: o.label)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final o in PriceOwner.values) _PriceForm(owner: o),
          ],
        ),
      ),
    );
  }
}

/// Одна строка прайса: ключ, подпись, пояснение.
class _Field {
  const _Field(this.key, this.label, this.hint);
  final String key;
  final String label;
  final String hint;
}

/// Раздел прайса: заголовок + строки.
class _Group {
  const _Group(this.title, this.fields);
  final String title;
  final List<_Field> fields;
}

/// Все поля прайса, сгруппированные по смыслу.
List<_Group> _groupsFor() => [
      _Group('ИЗДЕЛИЕ · ₽ ЗА М²', [
        for (final t in PriceBook.windowPerM2.keys)
          _Field('win:$t', t, '₽ за м²'),
        const _Field('windowDefaultPerM2', 'ТИП НЕИЗВЕСТЕН', '₽ за м²'),
        const _Field('figuredMarkup', 'ФИГУРНОЕ · ДОЛЯ',
            '0,35 = +35 % к изделию'),
      ]),
      _Group('СТЕКЛОПАКЕТ · НАДБАВКА ₽ ЗА М²', [
        const _Field('glassEnergy', 'ЭНЕРГОСБЕРЕГАЮЩИЙ', '₽ за м²'),
        const _Field('glassMulti', 'МУЛЬТИФУНКЦИОНАЛЬНЫЙ', '₽ за м²'),
        const _Field('glassSun', 'СОЛНЦЕЗАЩИТНЫЙ', '₽ за м²'),
      ]),
      _Group('ПРОФИЛЬ', [
        const _Field('profile70PerM2', 'ТОЛЩИНА 70 ММ', '₽ за м²'),
        const _Field('premiumPerMm', 'ПРЕМИУМ ЗА 1 ММ', '₽ за м²'),
        const _Field('premiumFromMm', 'ПРЕМИУМ ОТ', 'мм (75)'),
      ]),
      _Group('КОМПЛЕКТАЦИЯ · ₽ ЗА М.П.', [
        const _Field('sillPerM', 'ПОДОКОННИК', '₽ за м.п.'),
        const _Field('ebbPerM', 'ОТЛИВ', '₽ за м.п.'),
        const _Field('slopePerM', 'ОТКОСЫ', '₽ за м.п.'),
        const _Field('psuPerM', 'ПСУЛ', '₽ за м.п.'),
        const _Field('strippingPerM2', 'ОТМАЗКА · 1 СТОРОНА', '₽ за м²'),
      ]),
      _Group('МОНТАЖ И ДОСТАВКА', [
        const _Field('installPerM2', 'МОНТАЖ', '₽ за м²'),
        const _Field('installMin', 'МОНТАЖ · МИНИМУМ', '₽ за изделие'),
        const _Field('delivery', 'ДОСТАВКА', '₽ за выезд'),
      ]),
    ];

/// Форма одного прайса (владелец задан).
class _PriceForm extends StatefulWidget {
  const _PriceForm({required this.owner});
  final PriceOwner owner;

  @override
  State<_PriceForm> createState() => _PriceFormState();
}

class _PriceFormState extends State<_PriceForm> {
  /// Загруженный прайс (нужен, чтобы сохранить brandPerM2 без изменений).
  PriceBookData _book = PriceBookData.standard;

  /// Контроллеры полей: ключ → текст.
  final Map<String, TextEditingController> _c = {};

  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final b = await PriceSettings.load(widget.owner);
    if (!mounted) return;
    setState(() {
      _book = b;
      _fill(b);
      _loading = false;
      _dirty = false;
    });
  }

  /// Разложить прайс по контроллерам.
  void _fill(PriceBookData b) {
    final v = <String, double>{
      for (final t in PriceBook.windowPerM2.keys)
        'win:$t': b.windowPerM2[t] ?? b.windowDefaultPerM2,
      'windowDefaultPerM2': b.windowDefaultPerM2,
      'figuredMarkup': b.figuredMarkup,
      'glassEnergy': b.glassEnergy,
      'glassMulti': b.glassMulti,
      'glassSun': b.glassSun,
      'profile70PerM2': b.profile70PerM2,
      'premiumPerMm': b.premiumPerMm,
      'premiumFromMm': b.premiumFromMm.toDouble(),
      'sillPerM': b.sillPerM,
      'ebbPerM': b.ebbPerM,
      'slopePerM': b.slopePerM,
      'psuPerM': b.psuPerM,
      'strippingPerM2': b.strippingPerM2,
      'installPerM2': b.installPerM2,
      'installMin': b.installMin,
      'delivery': b.delivery,
    };
    v.forEach((k, val) {
      final txt = _numText(val);
      final c = _c[k];
      if (c == null) {
        _c[k] = TextEditingController(text: txt);
      } else {
        c.text = txt;
      }
    });
  }

  /// Число → текст без хвоста «.0» для целых.
  String _numText(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toString().replaceAll('.', ',');
  }

  /// Текст поля → число (запятая = точка). Пусто/мусор → 0.
  double _val(String key) {
    final t = (_c[key]?.text ?? '').replaceAll(',', '.').replaceAll(' ', '');
    return double.tryParse(t) ?? 0;
  }

  /// Собрать прайс из полей. brandPerM2 берём из загруженного.
  PriceBookData _build() {
    final w = <String, double>{
      for (final t in PriceBook.windowPerM2.keys) t: _val('win:$t'),
    };
    return PriceBookData(
      windowPerM2: w,
      windowDefaultPerM2: _val('windowDefaultPerM2'),
      figuredMarkup: _val('figuredMarkup'),
      glassEnergy: _val('glassEnergy'),
      glassMulti: _val('glassMulti'),
      glassSun: _val('glassSun'),
      profile70PerM2: _val('profile70PerM2'),
      brandPerM2: _book.brandPerM2,
      premiumPerMm: _val('premiumPerMm'),
      premiumFromMm: _val('premiumFromMm').round(),
      sillPerM: _val('sillPerM'),
      ebbPerM: _val('ebbPerM'),
      slopePerM: _val('slopePerM'),
      psuPerM: _val('psuPerM'),
      strippingPerM2: _val('strippingPerM2'),
      installPerM2: _val('installPerM2'),
      installMin: _val('installMin'),
      delivery: _val('delivery'),
    );
  }

  Future<void> _save() async {
    await PriceSettings.save(widget.owner, _build());
    if (!mounted) return;
    setState(() => _dirty = false);
    _snack('ПРАЙС «${widget.owner.label}» СОХРАНЁН');
  }

  Future<void> _reset() async {
    await PriceSettings.reset(widget.owner);
    final b = await PriceSettings.load(widget.owner);
    if (!mounted) return;
    setState(() {
      _book = b;
      _fill(b);
      _dirty = false;
    });
    _snack('ПРАЙС «${widget.owner.label}» СБРОШЕН');
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
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              _head(),
              for (final g in _groupsFor()) ...[
                const SizedBox(height: 12),
                _groupCard(g),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7E93AC),
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Color(0xFF1B2C44)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    child: const Text('СБРОСИТЬ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.navy900,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    child: Text(_dirty ? 'СОХРАНИТЬ *' : 'СОХРАНИТЬ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Шапка: чей прайс и что означает.
  Widget _head() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.owner.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.owner.hint,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  /// Карточка раздела с полями.
  Widget _groupCard(_Group g) {
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
            g.title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < g.fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            _row(g.fields[i]),
          ],
        ],
      ),
    );
  }

  /// Строка: подпись + поле ввода.
  Widget _row(_Field f) {
    final c = _c[f.key];
    if (c == null) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                f.hint,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Color(0xFF7E93AC),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 104,
          child: TextField(
            controller: c,
            textAlign: TextAlign.right,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: const Color(0xFF06101C),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: AppColors.gold.withOpacity(0.28)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
              ),
            ),
            onChanged: (_) {
              if (!_dirty) setState(() => _dirty = true);
            },
          ),
        ),
      ],
    );
  }
}