import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
          ? const Center(child: Text('Нет заказов на сервис'))
          : ListView.separated(
              itemCount: _list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = _list[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.build)),
                  title: Text(m.clientName),
                  subtitle: Text(
                      '${ServiceMeasurement.fmtDate(m.createdAt)} • ${m.items.length} работ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${m.totalPrice.toStringAsFixed(0)} ₽',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(m),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceResultScreen(measurement: m),
                      ),
                    );
                  },
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

// Заглушка — редактор сделаем в следующей части
class ServiceEditorScreen extends StatelessWidget {
  final PriceSettings price;
  const ServiceEditorScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый сервисный заказ')),
      body: const Center(child: Text('Редактор будет в следующей части')),
    );
  }
}

// Заглушка — результат сделаем позже
class ServiceResultScreen extends StatelessWidget {
  final ServiceMeasurement measurement;
  const ServiceResultScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ сервиса')),
      body: const Center(child: Text('Экран результата будет позже')),
    );
  }
}
class ServiceEditorScreen extends StatefulWidget {
  final PriceSettings price;
  const ServiceEditorScreen({super.key, required this.price});

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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: _nameCtrl.text.trim(),
      clientPhone: _phoneCtrl.text.trim(),
      clientAddress: _addrCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: List.from(_items),
      priceSettings: widget.price,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, m);
  }

  double get _total =>
      _items.fold(0.0, (s, it) => s + it.calcPrice(widget.price));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый заказ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Клиент', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Имя клиента', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addrCtrl,
            decoration: const InputDecoration(labelText: 'Адрес', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const Text('Работы', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._items.asMap().entries.map((e) => _itemCard(e.key, e.value)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Добавить работу'),
          ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ИТОГО:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_total.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Примечание', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Например: завтра в 10:00'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить заказ'),
          ),
          const SizedBox(height: 40),
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

            // За м
            if (it.type == 'Монтаж подоконника' ||
                it.type == 'Монтаж откоса' ||
                it.type == 'Замена подоконника') ...[
              TextFormField(
                initialValue: it.lengthMm.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Длина, мм'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.lengthMm = double.tryParse(v) ?? 0),
              ),
            ],

            // За шт
            if (it.type == 'Монтаж сетки' ||
                it.type == 'Регулировка' ||
                it.type == 'Замена ручки' ||
                it.type == 'Замена фурнитуры') ...[
              TextFormField(
                initialValue: it.count.toString(),
                decoration: const InputDecoration(labelText: 'Количество, шт'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.count = int.tryParse(v) ?? 1),
              ),
            ],

            // Замена резинки
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

            // Замена стеклопакета
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
