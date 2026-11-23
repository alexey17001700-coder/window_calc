import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'measure_item.dart';
import 'price_estimate.dart';

/// Хранилище замеров в памяти устройства.
class MeasureStore {
  static const _key = 'almas_measures_v1';

  static Future<List<Measure>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? [];
    return raw.map((e) => Measure.decode(e)).toList();
  }

  static Future<void> save(Measure m) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? [];
    final list = raw.map((e) => Measure.decode(e)).toList();
    final i = list.indexWhere((e) => e.id == m.id);
    if (i >= 0) {
      list[i] = m;
    } else {
      list.insert(0, m);
    }
    await sp.setStringList(_key, list.map((e) => e.encode()).toList());
  }

  static Future<void> remove(String id) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? [];
    final list = raw.map((e) => Measure.decode(e)).toList()
      ..removeWhere((e) => e.id == id);
    await sp.setStringList(_key, list.map((e) => e.encode()).toList());
  }
}

/// Экран «ИСТОРИЯ».
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<Measure> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await MeasureStore.load();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Замеров пока нет',
          style: TextStyle(color: AppColors.dim),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final m = _items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: AppUi.card(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.client.isEmpty ? 'Без имени' : m.client,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${m.items.length} изд. · ${m.totalArea.toStringAsFixed(2)} м² · '
                      '${buildEstimate(m.items).round()} ₽',
                      style: const TextStyle(color: AppColors.dim, fontSize: 12),
                    ),
                    if (m.date.isNotEmpty)
                      Text(
                        m.date,
                        style: const TextStyle(color: AppColors.dim, fontSize: 11),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                onPressed: () async {
                  await MeasureStore.remove(m.id);
                  _reload();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
