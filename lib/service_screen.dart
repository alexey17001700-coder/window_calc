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
