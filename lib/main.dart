import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const WindowCalcApp());

class PriceSettings {
  double window1Panel = 15000;
  double window1Stalin = 17000;
  double window1Brick = 19000;
  double window2Panel = 25000;
  double window2Stalin = 28000;
  double window2Brick = 31000;
  double window3Panel = 35000;
  double window3Stalin = 39000;
  double window3Brick = 43000;
  double blockSmallPanel = 40000;
  double blockSmallStalin = 45000;
  double blockSmallBrick = 50000;
  double blockBigPanel = 60000;
  double blockBigStalin = 68000;
  double blockBigBrick = 75000;
  double balconyPerM2 = 8000;
  double bezParapetPerM2 = 9500;
  double slopesPanel = 3000;
  double slopesStalin = 4000;
  double slopesBrick = 5000;
  double glass24 = 2500;
  double glass32 = 3500;
  double glass40 = 4500;
  double extraTinting = 1000;
  double extraMulti = 1500;
  double sillPerM = 2500;
  double dripPerM = 1500;
  double slopePerM = 2000;
  double mosquitoPerUnit = 2500;
  double demontagePerUnit = 3000;

  PriceSettings();

  double basePrice(String type, String houseType) {
    final p = type;
    final h = houseType;
    if (p == 'Окно 1-створчатое') {
      return h == 'Панелька' ? window1Panel : (h == 'Сталинка' ? window1Stalin : window1Brick);
    }
    if (p == 'Окно 2-створчатое') {
      return h == 'Панелька' ? window2Panel : (h == 'Сталинка' ? window2Stalin : window2Brick);
    }
    if (p == 'Окно 3-створчатое') {
      return h == 'Панелька' ? window3Panel : (h == 'Сталинка' ? window3Stalin : window3Brick);
    }
    if (p == 'Балконный блок малый') {
      return h == 'Панелька' ? blockSmallPanel : (h == 'Сталинка' ? blockSmallStalin : blockSmallBrick);
    }
    if (p == 'Балконный блок большой') {
      return h == 'Панелька' ? blockBigPanel : (h == 'Сталинка' ? blockBigStalin : blockBigBrick);
    }
    return 0;
  }

  double slopesPrice(String houseType) {
    if (houseType == 'Панелька') return slopesPanel;
    if (houseType == 'Сталинка') return slopesStalin;
    return slopesBrick;
  }

  double glassPrice(double thickness) {
    if (thickness <= 24) return glass24;
    if (thickness <= 32) return glass32;
    return glass40;
  }

  Map<String, double> toMap() => {
    'window1Panel': window1Panel, 'window1Stalin': window1Stalin, 'window1Brick': window1Brick,
    'window2Panel': window2Panel, 'window2Stalin': window2Stalin, 'window2Brick': window2Brick,
    'window3Panel': window3Panel, 'window3Stalin': window3Stalin, 'window3Brick': window3Brick,
    'blockSmallPanel': blockSmallPanel, 'blockSmallStalin': blockSmallStalin, 'blockSmallBrick': blockSmallBrick,
    'blockBigPanel': blockBigPanel, 'blockBigStalin': blockBigStalin, 'blockBigBrick': blockBigBrick,
    'balconyPerM2': balconyPerM2, 'bezParapetPerM2': bezParapetPerM2,
    'slopesPanel': slopesPanel, 'slopesStalin': slopesStalin, 'slopesBrick': slopesBrick,
    'glass24': glass24, 'glass32': glass32, 'glass40': glass40,
    'extraTinting': extraTinting, 'extraMulti': extraMulti,
    'sillPerM': sillPerM, 'dripPerM': dripPerM, 'slopePerM': slopePerM,
    'mosquitoPerUnit': mosquitoPerUnit, 'demontagePerUnit': demontagePerUnit,
  };
}
class ProductItem {
  String type;
  String houseType;
  double widthMm;
  double heightMm;
  int count;
  double glassThickness;
  bool tinted;
  bool multi;
  bool hasSlopes;
  bool hasSill;
  double sillLengthM;
  bool hasDrip;
  double dripLengthM;
  bool hasExtraSlope;
  double extraSlopeLengthM;
  bool hasMosquito;
  bool complexInstall;
  bool separateDemontage;

  ProductItem({
    this.type = 'Окно 2-створчатое',
    this.houseType = 'Панелька',
    this.widthMm = 1300,
    this.heightMm = 1400,
    this.count = 1,
    this.glassThickness = 32,
    this.tinted = false,
    this.multi = false,
    this.hasSlopes = false,
    this.hasSill = false,
    this.sillLengthM = 1.5,
    this.hasDrip = false,
    this.dripLengthM = 1.5,
    this.hasExtraSlope = false,
    this.extraSlopeLengthM = 1.5,
    this.hasMosquito = false,
    this.complexInstall = true,
    this.separateDemontage = false,
  });

  bool get isBalcony => type == 'Балкон' || type == 'Безпарапетка';
  double get areaM2 => (widthMm / 1000) * (heightMm / 1000) * count;

  double calcPrice(PriceSettings ps) {
    double total = 0;
    if (isBalcony) {
      final perM2 = type == 'Балкон' ? ps.balconyPerM2 : ps.bezParapetPerM2;
      total += perM2 * areaM2;
    } else {
      total += ps.basePrice(type, houseType) * count;
    }
    total += ps.glassPrice(glassThickness) * areaM2;
    if (tinted) total += ps.extraTinting * areaM2;
    if (multi) total += ps.extraMulti * areaM2;
    if (hasSlopes) total += ps.slopesPrice(houseType) * count;
    if (hasSill) total += ps.sillPerM * sillLengthM;
    if (hasDrip) total += ps.dripPerM * dripLengthM;
    if (hasExtraSlope) total += ps.slopePerM * extraSlopeLengthM;
    if (hasMosquito) total += ps.mosquitoPerUnit * count;
    if (separateDemontage && !complexInstall) {
      total += ps.demontagePerUnit * count;
    }
    return total;
  }
}

class Measurement {
  String id;
  String clientName;
  String clientPhone;
  String clientAddress;
  String notes;
  List<ProductItem> items;
  PriceSettings priceSettings;
  DateTime createdAt;

  Measurement({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    this.notes = '',
    required this.items,
    required this.priceSettings,
    required this.createdAt,
  });

  double get totalPrice =>
      items.fold(0.0, (s, it) => s + it.calcPrice(priceSettings));

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String toShareText() {
    final b = StringBuffer();
    b.writeln('🧾 ЗАМЕРНЫЙ ЛИСТ');
    b.writeln('═══════════════════════');
    b.writeln('Дата: ${_fmtDate(createdAt)}');
    b.writeln('Клиент: $clientName');
    b.writeln('Телефон: $clientPhone');
    b.writeln('Адрес: $clientAddress');
    b.writeln('═══════════════════════');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      b.writeln('');
      b.writeln('Позиция ${i + 1}: ${it.type}');
      b.writeln('  Тип дома: ${it.houseType}');
      b.writeln('  Размер: ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count} шт.');
      b.writeln('  Площадь: ${it.areaM2.toStringAsFixed(2)} м²');
      b.writeln('  Стеклопакет: ${it.glassThickness.toInt()} мм');
      if (it.hasSlopes) b.writeln('  Откосы: да');
      if (it.hasSill) b.writeln('  Подоконник: ${it.sillLengthM} м');
      if (it.hasDrip) b.writeln('  Отлив: ${it.dripLengthM} м');
      if (it.hasMosquito) b.writeln('  Москитная сетка: да');
      b.writeln('  Цена: ${it.calcPrice(priceSettings).toStringAsFixed(0)} ₽');
    }
    if (notes.isNotEmpty) {
      b.writeln('');
      b.writeln('Примечание: $notes');
    }
    b.writeln('═══════════════════════');
    b.writeln('ИТОГО: ${totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}
class WindowCalcApp extends StatefulWidget {
  const WindowCalcApp({super.key});

  @override
  State<WindowCalcApp> createState() => _WindowCalcAppState();
}

class _WindowCalcAppState extends State<WindowCalcApp> {
  final PriceSettings _price = PriceSettings();
  final List<Measurement> _measurements = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор окон',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MainMenuScreen(
        price: _price,
        measurements: _measurements,
        onPriceChanged: () => setState(() {}),
        onMeasurementAdded: (m) => setState(() => _measurements.insert(0, m)),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  final PriceSettings price;
  final List<Measurement> measurements;
  final VoidCallback onPriceChanged;
  final Function(Measurement) onMeasurementAdded;

  const MainMenuScreen({
    super.key,
    required this.price,
    required this.measurements,
    required this.onPriceChanged,
    required this.onMeasurementAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор окон'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            context,
            icon: Icons.add_circle,
            color: Colors.blue,
            title: 'Создать замер',
            subtitle: 'Новый замер клиента',
            onTap: () async {
              final result = await Navigator.push<Measurement>(
                context,
                MaterialPageRoute(
                  builder: (_) => MeasurementEditorScreen(price: price),
                ),
              );
              if (result != null) onMeasurementAdded(result);
            },
          ),
          _menuCard(
            context,
            icon: Icons.folder,
            color: Colors.green,
            title: 'Сохранённые замеры',
            subtitle: '${measurements.length} шт.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedMeasurementsScreen(
                    measurements: measurements,
                  ),
                ),
              );
            },
          ),
          _menuCard(
            context,
            icon: Icons.settings,
            color: Colors.orange,
            title: 'Настройки (прайс)',
            subtitle: 'Цены на изделия и услуги',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PriceSettingsScreen(
                    price: price,
                    onChanged: onPriceChanged,
                  ),
                ),
              );
              onPriceChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class SavedMeasurementsScreen extends StatelessWidget {
  final List<Measurement> measurements;
  const SavedMeasurementsScreen({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранённые замеры'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: measurements.isEmpty
          ? const Center(child: Text('Пока нет сохранённых замеров'))
          : ListView.separated(
              itemCount: measurements.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = measurements[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.window)),
                  title: Text(m.clientName),
                  subtitle: Text('${Measurement._fmtDate(m.createdAt)} • ${m.items.length} поз.'),
                  trailing: Text(
                    '${m.totalPrice.toStringAsFixed(0)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(measurement: m),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
class PriceSettingsScreen extends StatefulWidget {
  final PriceSettings price;
  final VoidCallback onChanged;
  const PriceSettingsScreen({super.key, required this.price, required this.onChanged});

  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = {};
    widget.price.toMap().forEach((k, v) {
      _ctrls[k] = TextEditingController(text: v.toStringAsFixed(0));
    });
  }

  @override
  void dispose() {
    for (var c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _apply() {
    final p = widget.price;
    double g(String k) => double.tryParse(_ctrls[k]!.text) ?? 0;
    p.window1Panel = g('window1Panel');
    p.window1Stalin = g('window1Stalin');
    p.window1Brick = g('window1Brick');
    p.window2Panel = g('window2Panel');
    p.window2Stalin = g('window2Stalin');
    p.window2Brick = g('window2Brick');
    p.window3Panel = g('window3Panel');
    p.window3Stalin = g('window3Stalin');
    p.window3Brick = g('window3Brick');
    p.blockSmallPanel = g('blockSmallPanel');
    p.blockSmallStalin = g('blockSmallStalin');
    p.blockSmallBrick = g('blockSmallBrick');
    p.blockBigPanel = g('blockBigPanel');
    p.blockBigStalin = g('blockBigStalin');
    p.blockBigBrick = g('blockBigBrick');
    p.balconyPerM2 = g('balconyPerM2');
    p.bezParapetPerM2 = g('bezParapetPerM2');
    p.slopesPanel = g('slopesPanel');
    p.slopesStalin = g('slopesStalin');
    p.slopesBrick = g('slopesBrick');
    p.glass24 = g('glass24');
    p.glass32 = g('glass32');
    p.glass40 = g('glass40');
    p.extraTinting = g('extraTinting');
    p.extraMulti = g('extraMulti');
    p.sillPerM = g('sillPerM');
    p.dripPerM = g('dripPerM');
    p.slopePerM = g('slopePerM');
    p.mosquitoPerUnit = g('mosquitoPerUnit');
    p.demontagePerUnit = g('demontagePerUnit');
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прайс сохранён')),
    );
  }

  Widget _row(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _ctrls[key],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                suffixText: '₽',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки прайса'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _apply),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _title('Окно 1-створчатое'),
          _row('Панелька', 'window1Panel'),
          _row('Сталинка', 'window1Stalin'),
          _row('Кирпич', 'window1Brick'),
          _title('Окно 2-створчатое'),
          _row('Панелька', 'window2Panel'),
          _row('Сталинка', 'window2Stalin'),
          _row('Кирпич', 'window2Brick'),
          _title('Окно 3-створчатое'),
          _row('Панелька', 'window3Panel'),
          _row('Сталинка', 'window3Stalin'),
          _row('Кирпич', 'window3Brick'),
          _title('Балконный блок (малый)'),
          _row('Панелька', 'blockSmallPanel'),
          _row('Сталинка', 'blockSmallStalin'),
          _row('Кирпич', 'blockSmallBrick'),
          _title('Балконный блок (большой)'),
          _row('Панелька', 'blockBigPanel'),
          _row('Сталинка', 'blockBigStalin'),
          _row('Кирпич', 'blockBigBrick'),
          _title('Балкон (за м²)'),
          _row('Остекление балкона', 'balconyPerM2'),
          _row('Безпарапетка', 'bezParapetPerM2'),
          _title('Откосы (доплата)'),
          _row('Панелька', 'slopesPanel'),
          _row('Сталинка', 'slopesStalin'),
          _row('Кирпич', 'slopesBrick'),
          _title('Стеклопакеты (за м²)'),
          _row('24 мм', 'glass24'),
          _row('32 мм', 'glass32'),
          _row('40 мм', 'glass40'),
          _row('Тонировка (доплата)', 'extraTinting'),
          _row('Мультифункция (доплата)', 'extraMulti'),
          _title('Доп. услуги'),
          _row('Подоконник (за м)', 'sillPerM'),
          _row('Отлив (за м)', 'dripPerM'),
          _row('Откосы доп. (за м)', 'slopePerM'),
          _row('Москитная сетка (шт.)', 'mosquitoPerUnit'),
          _row('Демонтаж (за изделие)', 'demontagePerUnit'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _apply,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить прайс'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class MeasurementEditorScreen extends StatefulWidget {
  final PriceSettings price;
  const MeasurementEditorScreen({super.key, required this.price});

  @override
  State<MeasurementEditorScreen> createState() => _MeasurementEditorScreenState();
}

class _MeasurementEditorScreenState extends State<MeasurementEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<ProductItem> _items = [ProductItem()];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    final m = Measurement(
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

  double get _total => _items.fold(0.0, (s, it) => s + it.calcPrice(widget.price));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый замер'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Клиент'),
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
          const _SectionTitle('Изделия'),
          ...List.generate(_items.length, (i) => _itemCard(i)),
          OutlinedButton.icon(
            onPressed: () => setState(() => _items.add(ProductItem())),
            icon: const Icon(Icons.add),
            label: const Text('Добавить изделие'),
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
          const _SectionTitle('Примечание'),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Например: монтаж в субботу'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить замер'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _itemCard(int index) {
    final it = _items[index];
    final price = it.calcPrice(widget.price);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Изделие ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _items.removeAt(index)),
                  ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: it.type,
              decoration: const InputDecoration(labelText: 'Тип изделия'),
              items: const [
                DropdownMenuItem(value: 'Окно 1-створчатое', child: Text('Окно 1-створчатое')),
                DropdownMenuItem(value: 'Окно 2-створчатое', child: Text('Окно 2-створчатое')),
                DropdownMenuItem(value: 'Окно 3-створчатое', child: Text('Окно 3-створчатое')),
                DropdownMenuItem(value: 'Балкон', child: Text('Балкон')),
                DropdownMenuItem(value: 'Безпарапетка', child: Text('Безпарапетка')),
                DropdownMenuItem(value: 'Балконный блок малый', child: Text('Балконный блок малый')),
                DropdownMenuItem(value: 'Балконный блок большой', child: Text('Балконный блок большой')),
              ],
              onChanged: (v) => setState(() => it.type = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: it.houseType,
              decoration: const InputDecoration(labelText: 'Тип дома'),
              items: const [
                DropdownMenuItem(value: 'Панелька', child: Text('Панелька')),
                DropdownMenuItem(value: 'Сталинка', child: Text('Сталинка')),
                DropdownMenuItem(value: 'Кирпич', child: Text('Кирпич')),
              ],
              onChanged: (v) => setState(() => it.houseType = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: it.widthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Ширина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.widthMm = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: it.heightMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Высота, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.heightMm = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: it.count.toString(),
                    decoration: const InputDecoration(labelText: 'Кол-во'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.count = int.tryParse(v) ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<double>(
              value: it.glassThickness,
              decoration: const InputDecoration(labelText: 'Стеклопакет, мм'),
              items: const [
                DropdownMenuItem(value: 24, child: Text('24 мм')),
                DropdownMenuItem(value: 32, child: Text('32 мм')),
                DropdownMenuItem(value: 40, child: Text('40 мм')),
              ],
              onChanged: (v) => setState(() => it.glassThickness = v!),
            ),
            CheckboxListTile(
              value: it.tinted,
              onChanged: (v) => setState(() => it.tinted = v!),
              title: const Text('Тонировка'),
              dense: true,
            ),
            CheckboxListTile(
              value: it.multi,
              onChanged: (v) => setState(() => it.multi = v!),
              title: const Text('Мультифункциональное'),
              dense: true,
            ),
            const Divider(),
            CheckboxListTile(
              value: it.hasSlopes,
              onChanged: (v) => setState(() => it.hasSlopes = v!),
              title: const Text('Откосы (в комплекте)'),
              dense: true,
            ),
            CheckboxListTile(
              value: it.hasSill,
              onChanged: (v) => setState(() => it.hasSill = v!),
              title: const Text('Подоконник'),
              dense: true,
            ),
            if (it.hasSill)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: TextFormField(
                  initialValue: it.sillLengthM.toString(),
                  decoration: const InputDecoration(labelText: 'Длина, м'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.sillLengthM = double.tryParse(v) ?? 0),
                ),
              ),
            CheckboxListTile(
              value: it.hasDrip,
              onChanged: (v) => setState(() => it.hasDrip = v!),
              title: const Text('Отлив'),
              dense: true,
            ),
            if (it.hasDrip)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: TextFormField(
                  initialValue: it.dripLengthM.toString(),
                  decoration: const InputDecoration(labelText: 'Длина, м'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.dripLengthM = double.tryParse(v) ?? 0),
                ),
              ),
            CheckboxListTile(
              value: it.hasExtraSlope,
              onChanged: (v) => setState(() => it.hasExtraSlope = v!),
              title: const Text('Откосы доп. (за м)'),
              dense: true,
            ),
            if (it.hasExtraSlope)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: TextFormField(
                  initialValue: it.extraSlopeLengthM.toString(),
                  decoration: const InputDecoration(labelText: 'Длина, м'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.extraSlopeLengthM = double.tryParse(v) ?? 0),
                ),
              ),
            CheckboxListTile(
              value: it.hasMosquito,
              onChanged: (v) => setState(() => it.hasMosquito = v!),
              title: const Text('Москитная сетка'),
              dense: true,
            ),
            const Divider(),
            CheckboxListTile(
              value: it.complexInstall,
              onChanged: (v) => setState(() => it.complexInstall = v!),
              title: const Text('Комплекс (демонтаж включён)'),
              dense: true,
            ),
            if (!it.complexInstall)
              CheckboxListTile(
                value: it.separateDemontage,
                onChanged: (v) => setState(() => it.separateDemontage = v!),
                title: const Text('Демонтаж отдельно'),
                dense: true,
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Стоимость позиции:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('${price.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ResultScreen extends StatelessWidget {
  final Measurement measurement;
  const ResultScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Замерный лист'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(m.clientPhone),
                  Text(m.clientAddress),
                  const Divider(height: 24),
                  const Text('Позиции:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...m.items.asMap().entries.map((e) {
                    final it = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e.key + 1}. ${it.type} — ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count}'),
                          Text('   ${it.houseType} • стекло ${it.glassThickness.toInt()} мм', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('   ${it.calcPrice(m.priceSettings).toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }),
                  if (m.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Примечание: ${m.notes}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ИТОГО:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${m.totalPrice.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Поделиться замерным листом:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _shareButton(context, icon: Icons.copy, label: 'Скопировать полный текст', color: Colors.blue, onTap: () async {
            await Clipboard.setData(ClipboardData(text: m.toShareText()));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано')));
            }
          }),
          _shareButton(context, icon: Icons.person, label: 'Версия для клиента', color: Colors.green, onTap: () => _showText(context, _clientVersion(m))),
          _shareButton(context, icon: Icons.factory, label: 'Версия для завода', color: Colors.orange, onTap: () => _showText(context, _factoryVersion(m))),
          _shareButton(context, icon: Icons.handshake, label: 'Версия для дилера', color: Colors.purple, onTap: () => _showText(context, _dealerVersion(m))),
        ],
      ),
    );
  }

  Widget _shareButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _showText(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Предпросмотр'),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано')));
            },
            child: const Text('Скопировать'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        ],
      ),
    );
  }

  String _clientVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('Здравствуйте, ${m.clientName}!');
    b.writeln('');
    b.writeln('Ваш заказ на окна:');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('  ${i + 1}. ${it.type} ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм — ${it.count} шт.');
    }
    b.writeln('');
    b.writeln('ИТОГО: ${m.totalPrice.toStringAsFixed(0)} ₽');
    b.writeln('');
    b.writeln('По вопросам — звоните!');
    return b.toString();
  }

  String _factoryVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('=== ЗАКАЗ НА ПРОИЗВОДСТВО ===');
    b.writeln('Клиент: ${m.clientName}');
    b.writeln('Адрес: ${m.clientAddress}');
    b.writeln('Тел: ${m.clientPhone}');
    b.writeln('');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('ПОЗИЦИЯ ${i + 1}:');
      b.writeln('  Тип: ${it.type}');
      b.writeln('  Тип дома: ${it.houseType}');
      b.writeln('  Размер: ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count}');
      b.writeln('  Стеклопакет: ${it.glassThickness.toInt()} мм');
      if (it.tinted) b.writeln('  + Тонировка');
      if (it.multi) b.writeln('  + Мультифункция');
      if (it.hasSlopes) b.writeln('  Откосы: да');
      if (it.hasSill) b.writeln('  Подоконник: ${it.sillLengthM} м');
      if (it.hasDrip) b.writeln('  Отлив: ${it.dripLengthM} м');
      if (it.hasMosquito) b.writeln('  Москитка: да');
      b.writeln('');
    }
    if (m.notes.isNotEmpty) b.writeln('Примечание: ${m.notes}');
    return b.toString();
  }

  String _dealerVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('ЗАМЕР #${m.id}');
    b.writeln('');
    b.writeln('Клиент: ${m.clientName} (${m.clientPhone})');
    b.writeln('Адрес: ${m.clientAddress}');
    b.writeln('Дата: ${Measurement._fmtDate(m.createdAt)}');
    b.writeln('');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('${i + 1}. ${it.type} ${it.widthMm.toInt()}×${it.heightMm.toInt()} ×${it.count} — ${it.calcPrice(m.priceSettings).toStringAsFixed(0)} ₽');
    }
    b.writeln('');
    b.writeln('К ОПЛАТЕ: ${m.totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
