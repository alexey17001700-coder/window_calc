import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'price_estimate.dart';
import 'theme.dart';
import 'screen_flash.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ИСТОРИЯ ЗАМЕРОВ И БАЗА КЛИЕНТОВ  ·  v3.4.28
///  Хранится локально: shared_preferences, ключ window_calc_history.
///  Запись = готовый замер: клиент, дерево, комплектация, размеры,
///  стеклопакет, створки и итог сметы.
/// ═══════════════════════════════════════════════════════════════════

/// Дата: «14.03.2026 · 18:40».
String stamp(DateTime d) {
  String p(int v) => v < 10 ? '0$v' : '$v';
  return '${p(d.day)}.${p(d.month)}.${d.year} · ${p(d.hour)}:${p(d.minute)}';
}

/// ─────────────────────────── ЗАПИСЬ ЗАМЕРА ───────────────────────────
class MeasureRecord {
  MeasureRecord({
    required this.id,
    required this.createdAt,
    this.name = '',
    this.phone = '',
    this.addr = '',
    this.flat = '',
    this.floor = '',
    this.path = const [],
    this.multi = const [],
    this.sizes = const {},
    this.glass = '',
    this.widthMm = 0,
    this.heightMm = 0,
    this.sashModes = const [],
    this.total = 0,
  });

  final String id;
  final DateTime createdAt;
  final String name;
  final String phone;
  final String addr;
  final String flat;
  final String floor;
  final List<String> path;
  final List<String> multi;
  final Map<String, Map<String, int>> sizes;
  final String glass;
  final int widthMm;
  final int heightMm;
  final List<String> sashModes;
  final int total;

  String get clientLabel => name.trim().isEmpty ? 'БЕЗ ИМЕНИ' : name.trim();

  String get sizeLabel =>
      (widthMm > 0 && heightMm > 0) ? '$widthMm × $heightMm ММ' : 'РАЗМЕР НЕ ЗАДАН';

  String get addressLabel {
    final parts = <String>[
      if (addr.trim().isNotEmpty) addr.trim(),
      if (flat.trim().isNotEmpty) 'КВ. ${flat.trim()}',
      if (floor.trim().isNotEmpty) 'ЭТ. ${floor.trim()}',
    ];
    return parts.isEmpty ? 'АДРЕС НЕ УКАЗАН' : parts.join(', ');
  }

  String get titleLabel {
    final t = <String>[
      if (path.length > 2) path[2],
      if (path.length > 3) path[3],
      ...multi,
    ];
    return t.isEmpty ? 'ЗАМЕР' : t.join(' · ');
  }

  String get dateLabel => stamp(createdAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
        'phone': phone,
        'addr': addr,
        'flat': flat,
        'floor': floor,
        'path': path,
        'multi': multi,
        'sizes': sizes,
        'glass': glass,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'sashModes': sashModes,
        'total': total,
      };

  factory MeasureRecord.fromJson(Map<String, dynamic> j) {
    final rawSizes = (j['sizes'] as Map?) ?? const {};
    return MeasureRecord(
      id: (j['id'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      addr: (j['addr'] ?? '').toString(),
      flat: (j['flat'] ?? '').toString(),
      floor: (j['floor'] ?? '').toString(),
      path: ((j['path'] as List?) ?? const []).map((e) => '$e').toList(),
      multi: ((j['multi'] as List?) ?? const []).map((e) => '$e').toList(),
      sizes: rawSizes.map(
        (k, v) => MapEntry(
          '$k',
          ((v as Map?) ?? const {}).map(
            (a, b) => MapEntry('$a', (b as num?)?.toInt() ?? 0),
          ),
        ),
      ),
      glass: (j['glass'] ?? '').toString(),
      widthMm: (j['widthMm'] as num?)?.toInt() ?? 0,
      heightMm: (j['heightMm'] as num?)?.toInt() ?? 0,
      sashModes:
          ((j['sashModes'] as List?) ?? const []).map((e) => '$e').toList(),
      total: (j['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// ─────────────────────────── ХРАНИЛИЩЕ ───────────────────────────
class MeasureHistory {
  static const _key = 'window_calc_history';

  /// Больше 300 замеров не держим — старое уходит.
  static const maxRecords = 300;

  static Future<List<MeasureRecord>> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      final out = list
          .map((e) => MeasureRecord.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return out;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(List<MeasureRecord> list) async {
    final sp = await SharedPreferences.getInstance();
    final cut = list.length > maxRecords ? list.sublist(0, maxRecords) : list;
    await sp.setString(_key, jsonEncode(cut.map((e) => e.toJson()).toList()));
  }

  static Future<List<MeasureRecord>> add(MeasureRecord r) async {
    final list = await load();
    list.insert(0, r);
    await _write(list);
    return list;
  }

  static Future<List<MeasureRecord>> remove(String id) async {
    final list = await load();
    list.removeWhere((e) => e.id == id);
    await _write(list);
    return list;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}

/// ─────────────────────────── БАЗА КЛИЕНТОВ ───────────────────────────
class ClientEntry {
  ClientEntry({
    required this.name,
    required this.phone,
    required this.orders,
    required this.last,
    required this.sum,
  });

  final String name;
  final String phone;
  final int orders;
  final DateTime last;
  final int sum;

  String get label => name.trim().isEmpty ? 'БЕЗ ИМЕНИ' : name.trim();
}

class ClientBook {
  /// Собираем клиентов из истории: ключ — телефон, иначе имя.
  static List<ClientEntry> build(List<MeasureRecord> records) {
    final map = <String, ClientEntry>{};
    for (final r in records) {
      final key = r.phone.trim().isNotEmpty
          ? r.phone.trim()
          : '${r.name.trim()}|${r.addr.trim()}';
      final old = map[key];
      if (old == null) {
        map[key] = ClientEntry(
          name: r.name,
          phone: r.phone,
          orders: 1,
          last: r.createdAt,
          sum: r.total,
        );
      } else {
        map[key] = ClientEntry(
          name: old.name.trim().isEmpty ? r.name : old.name,
          phone: old.phone.trim().isEmpty ? r.phone : old.phone,
          orders: old.orders + 1,
          last: r.createdAt.isAfter(old.last) ? r.createdAt : old.last,
          sum: old.sum + r.total,
        );
      }
    }
    final out = map.values.toList()
      ..sort((a, b) => b.last.compareTo(a.last));
    return out;
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЭКРАН: ИСТОРИЯ ЗАМЕРОВ / БАЗА КЛИЕНТОВ
/// ═══════════════════════════════════════════════════════════════════
class HistoryView extends StatefulWidget {
  const HistoryView({super.key, this.onBack});

  /// Возврат (если экран открыт не через Navigator).
  final VoidCallback? onBack;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<MeasureRecord> _records = const [];
  bool _loading = true;
  int _tab = 0; // 0 — замеры, 1 — клиенты
  String? _open;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final r = await MeasureHistory.load();
    if (!mounted) return;
    setState(() {
      _records = r;
      _loading = false;
    });
  }

  Future<void> _delete(MeasureRecord r) async {
    final ok = await _confirm('УДАЛИТЬ ЗАМЕР?', '${r.clientLabel} · ${r.dateLabel}');
    if (!ok) return;
    final list = await MeasureHistory.remove(r.id);
    if (!mounted) return;
    setState(() => _records = list);
  }

  Future<void> _clearAll() async {
    final ok = await _confirm('ОЧИСТИТЬ ВСЮ ИСТОРИЮ?',
        'Будет удалено записей: ${_records.length}. Действие необратимо.');
    if (!ok) return;
    await MeasureHistory.clear();
    if (!mounted) return;
    setState(() => _records = const []);
  }

  Future<bool> _confirm(String title, String body) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1524),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withOpacity(0.35)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.45,
            color: Color(0xFF9FB0C6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ОТМЕНА',
                style: TextStyle(color: Color(0xFF9FB0C6), fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('УДАЛИТЬ',
                style: TextStyle(color: AppColors.gold, fontSize: 12)),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold))
                  : _tab == 0
                      ? _recordsList()
                      : _clientsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              flashScreen();
              if (widget.onBack != null) {
                widget.onBack!.call();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1220),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.42)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 19, color: AppColors.gold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ИСТОРИЯ ЗАМЕРОВ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ЗАПИСЕЙ: ${_records.length}  ·  КЛИЕНТОВ: ${ClientBook.build(_records).length}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          if (_records.isNotEmpty)
            GestureDetector(
              onTap: () {
                flashScreen();
                _clearAll();
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1220),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF7A2E2E)),
                ),
                child: const Center(
                  child: Text(
                    'ОЧИСТИТЬ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: Color(0xFFE07A7A),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget t(String text, int i) {
      final on = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            flashScreen();
            setState(() => _tab = i);
          },
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: on ? AppColors.goldGradient : null,
              color: on ? null : const Color(0xFF0A1220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: on ? Colors.transparent : const Color(0xFF1B2C44),
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: on ? AppColors.navy900 : const Color(0xFF9FB0C6),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
      child: Row(children: [t('ЗАМЕРЫ', 0), t('КЛИЕНТЫ', 1)]),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded,
                size: 52, color: AppColors.gold.withOpacity(0.35)),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7E93AC),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordsList() {
    if (_records.isEmpty) {
      return _empty('ПОКА ПУСТО.\nЗаверши замер в мастере — он появится здесь.');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 20),
      itemCount: _records.length,
      itemBuilder: (_, i) => _recordCard(_records[i]),
    );
  }

  Widget _recordCard(MeasureRecord r) {
    final open = _open == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152740), Color(0xFF0B1524)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withOpacity(0.26)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              flashScreen();
              setState(() => _open = open ? null : r.id);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1220),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.gold.withOpacity(0.35)),
                    ),
                    child: const Icon(Icons.window_rounded,
                        size: 19, color: AppColors.gold),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.clientLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r.sizeLabel}  ·  ${r.dateLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Color(0xFF7E93AC),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        r.total > 0 ? money(r.total) : '—',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Icon(
                        open
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: const Color(0xFF7E93AC),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (open) _recordDetails(r),
        ],
      ),
    );
  }

  Widget _recordDetails(MeasureRecord r) {
    Widget line(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  k,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: Color(0xFF7E93AC),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  v.isEmpty ? '—' : v,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );

    final sizes = <String>[];
    r.sizes.forEach((item, fields) {
      final f = fields.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key}: ${e.value} ММ')
          .join(', ');
      if (f.isNotEmpty) sizes.add('$item — $f');
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF08101C),
        border: Border(top: BorderSide(color: Color(0xFF1B2C44))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line('ТЕЛЕФОН', r.phone),
          line('АДРЕС', r.addressLabel),
          line('ИЗДЕЛИЕ', r.titleLabel),
          line('СТЕКЛОПАКЕТ', r.glass),
          line('СТВОРКИ', r.sashModes.join(' · ')),
          line('РАЗМЕРЫ', sizes.join('\n')),
          line('ИТОГО', r.total > 0 ? money(r.total) : '—'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _delete(r),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF140C0C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7A2E2E)),
              ),
              child: const Center(
                child: Text(
                  'УДАЛИТЬ ЗАМЕР',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFFE07A7A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientsList() {
    final clients = ClientBook.build(_records);
    if (clients.isEmpty) {
      return _empty('БАЗА КЛИЕНТОВ ПУСТА.\nОна собирается сама из истории замеров.');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 20),
      itemCount: clients.length,
      itemBuilder: (_, i) {
        final c = clients[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1524),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1B2C44)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    c.label.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.phone.trim().isEmpty ? 'ТЕЛЕФОН НЕ УКАЗАН' : c.phone}  ·  ЗАМЕРОВ: ${c.orders}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: Color(0xFF7E93AC),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    c.sum > 0 ? money(c.sum) : '—',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stamp(c.last),
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
