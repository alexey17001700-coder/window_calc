import 'package:flutter/material.dart';
import 'main.dart';

class ServiceListScreen extends StatefulWidget {
  final PriceSettings price;
  final List<ServiceMeasurement> measurements;
  final Function(ServiceMeasurement) onAdded;
  final Function(String) onDeleted;

  const ServiceListScreen({
    super.key,
    required this.price,
    required this.measurements,
    required this.onAdded,
    required this.onDeleted,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late List<ServiceMeasurement> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.measurements);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сервис и ремонт'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F1B2D).withOpacity(0.06),
                    ),
                    child: const Icon(Icons.build_outlined,
                        size: 42, color: Color(0xFF0F1B2D)),
                  ),
                  const SizedBox(height: 18),
                  const Text('СЕРВИСНЫХ ЗАКАЗОВ НЕТ',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: Color(0xFF0F1B2D))),
                  const SizedBox(height: 6),
                  const Text('Создайте первый заказ на ремонт',
                      style: TextStyle(fontSize: 13, color: Colors.black45)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final m = _list[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final result = await Navigator.push<ServiceMeasurement>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceEditorScreen(
                              price: widget.price,
                              existing: m,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            final idx =
                                _list.indexWhere((x) => x.id == result.id);
                            if (idx >= 0) {
                              _list[idx] = result;
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFFC9A227), Color(0xFFE0C25A)]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.build,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.clientName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text(
                                      '${ServiceMeasurement.fmtDate(m.createdAt)} · ${m.items.length} работ',
                                      style: const TextStyle(
                                          fontSize: 12.5, color: Colors.black45)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${m.totalPrice.toStringAsFixed(0)} ₽',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F1B2D))),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _confirmDelete(m),
                                  child: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.black26),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<ServiceMeasurement>(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceEditorScreen(price: widget.price),
            ),
          );
          if (result != null) {
            setState(() => _list.insert(0, result));
            widget.onAdded(result);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Новый заказ'),
      ),
    );
  }

  void _confirmDelete(ServiceMeasurement m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: Text('Заказ для "${m.clientName}" будет удалён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _list.removeWhere((x) => x.id == m.id));
              widget.onDeleted(m.id);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
class ServiceEditorScreen extends StatefulWidget {
  final PriceSettings price;
  final ServiceMeasurement? existing;
  const ServiceEditorScreen({super.key, required this.price, this.existing});

  @override
  State<ServiceEditorScreen> createState() => _ServiceEditorScreenState();
}

class _ServiceEditorScreenState extends State<ServiceEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<ServiceItem> _items = [];

  static const List<String> _allTypes = [
    'Монтаж подоконника',
    'Монтаж откоса',
    'Монтаж сетки',
    'Регулировка',
    'Замена ручки',
    'Замена резинки',
    'Замена стеклопакета',
    'Замена фурнитуры',
    'Замена подоконника',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameCtrl.text = e.clientName;
      _phoneCtrl.text = e.clientPhone;
      _addrCtrl.text = e.clientAddress;
      _notesCtrl.text = e.notes;
      _items.addAll(e.items);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _getDefaultPrice(String type) {
    final p = widget.price;
    switch (type) {
      case 'Монтаж подоконника': return p.mountSillServicePerM;
      case 'Монтаж откоса': return p.mountSlopeServicePerM;
      case 'Монтаж сетки': return p.mountNetServicePerPc;
      case 'Регулировка': return p.regulationPerPc;
      case 'Замена ручки': return p.handleReplacePerPc;
      case 'Замена резинки': return p.rubberReplacePerSash;
      case 'Замена стеклопакета': return p.glassReplacePerPc;
      case 'Замена фурнитуры': return p.furnitureReplacePerPc;
      case 'Замена подоконника': return p.sillReplacePerM;
      default: return 0;
    }
  }

  void _addItem(String type) {
    setState(() {
      _items.add(ServiceItem(
        type: type,
        pricePerUnit: _getDefaultPrice(type),
      ));
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одну работу')),
      );
      return;
    }
    final m = ServiceMeasurement(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: _nameCtrl.text.trim(),
      clientPhone: _phoneCtrl.text.trim(),
      clientAddress: _addrCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: List.from(_items),
      priceSettings: widget.price,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    Navigator.pop(context, m);
  }

  double get _total =>
      _items.fold(0.0, (s, it) => s + it.calcPrice(widget.price));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Новый заказ' : 'Редактировать'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          Row(children: [
            Container(width: 3, height: 16,
                decoration: BoxDecoration(
                    color: const Color(0xFFC9A227),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('КЛИЕНТ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    letterSpacing: 1.6, color: Color(0xFF0F1B2D))),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 1, color: Colors.black12)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05),
                    blurRadius: 18, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Имя клиента',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Телефон',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addrCtrl,
                decoration: const InputDecoration(
                    labelText: 'Адрес',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    border: OutlineInputBorder()),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Container(width: 3, height: 16,
                decoration: BoxDecoration(
                    color: const Color(0xFFC9A227),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('РАБОТЫ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    letterSpacing: 1.6, color: Color(0xFF0F1B2D))),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 1, color: Colors.black12)),
          ]),
          const SizedBox(height: 12),
          ..._items.asMap().entries.map((e) => _itemCard(e.key, e.value)),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('ДОБАВИТЬ РАБОТУ',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16233A), Color(0xFF0F1B2D)]),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0F1B2D).withOpacity(0.28),
                    blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ИТОГО',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        letterSpacing: 1.6, color: Colors.white70)),
                Row(children: [
                  Text('${_total.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 30,
                          fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(width: 4),
                  const Text('₽', style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w700, color: Color(0xFFC9A227))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Container(width: 3, height: 16,
                decoration: BoxDecoration(
                    color: const Color(0xFFC9A227),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('ПРИМЕЧАНИЕ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    letterSpacing: 1.6, color: Color(0xFF0F1B2D))),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 1, color: Colors.black12)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Например: завтра в 10:00'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text('СОХРАНИТЬ ЗАКАЗ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Выберите работу'),
        children: _allTypes.map((t) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _addItem(t);
            },
            child: Text(t),
          );
        }).toList(),
      ),
    );
  }
    Widget _itemCard(int index, ServiceItem it) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(it.type,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _items.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: it.pricePerUnit.toStringAsFixed(0),
              decoration: const InputDecoration(labelText: 'Цена за единицу, ₽'),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => it.pricePerUnit = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 8),
            if (it.type == 'Монтаж подоконника' ||
                it.type == 'Монтаж откоса' ||
                it.type == 'Замена подоконника')
              TextFormField(
                initialValue: it.lengthMm.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Длина, мм'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.lengthMm = double.tryParse(v) ?? 0),
              ),
            if (it.type == 'Монтаж сетки' ||
                it.type == 'Регулировка' ||
                it.type == 'Замена ручки' ||
                it.type == 'Замена фурнитуры')
              TextFormField(
                initialValue: it.count.toString(),
                decoration: const InputDecoration(labelText: 'Количество, шт'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.count = int.tryParse(v) ?? 1),
              ),
            if (it.type == 'Замена резинки') ...[
              Row(children: [
                Expanded(child: TextFormField(
                  initialValue: it.sashesCount.toString(),
                  decoration: const InputDecoration(labelText: 'Створок'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.sashesCount = int.tryParse(v) ?? 0),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  initialValue: it.blindCount.toString(),
                  decoration: const InputDecoration(labelText: 'Глушняков'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.blindCount = int.tryParse(v) ?? 0),
                )),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: Text('Метраж: ${it.rubberMeters} м',
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: it.rubberColor,
                    decoration: const InputDecoration(labelText: 'Цвет'),
                    items: const [
                      DropdownMenuItem(value: 'Серая', child: Text('Серая')),
                      DropdownMenuItem(value: 'Черная', child: Text('Черная')),
                    ],
                    onChanged: (v) => setState(() => it.rubberColor = v!),
                  ),
                ),
              ]),
            ],
            if (it.type == 'Замена стеклопакета') ...[
              Row(children: [
                Expanded(child: TextFormField(
                  initialValue: it.glassWidthMm.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: 'Ширина, мм'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.glassWidthMm = double.tryParse(v) ?? 0),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  initialValue: it.glassHeightMm.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: 'Высота, мм'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.glassHeightMm = double.tryParse(v) ?? 0),
                )),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: TextFormField(
                  initialValue: it.glassSashesCount.toString(),
                  decoration: const InputDecoration(labelText: 'Створок'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.glassSashesCount = int.tryParse(v) ?? 0),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  initialValue: it.glassBlindCount.toString(),
                  decoration: const InputDecoration(labelText: 'Глушняков'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.glassBlindCount = int.tryParse(v) ?? 0),
                )),
              ]),
              const SizedBox(height: 6),
              Text('Площадь: ${it.glassAreaM2.toStringAsFixed(2)} м²  •  Всего: ${it.totalGlassPieces} шт',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Стоимость:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('${it.calcPrice(widget.price).toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
