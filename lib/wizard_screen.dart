import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// ПОШАГОВЫЙ МАСТЕР СОЗДАНИЯ ЗАМЕРА (WIZARD)
// Шаг 1: Данные клиента
// Шаг 2: заглушка (наполним позже)
// ═══════════════════════════════════════════════════════════

const _gold = Color(0xFFC9A227);
const _goldLight = Color(0xFFE8C766);
const _bronze = Color(0xFF9C7A3C);
const _navy = Color(0xFF0E1626);

/// Данные клиента, собранные на Шаге 1.
class WizardClientData {
  String name;
  String phone;
  String address;
  WizardClientData({this.name = '', this.phone = '', this.address = ''});
}

// ───────────────────────────────────────────────────────────
// ШАГ 1 — ДАННЫЕ КЛИЕНТА
// ───────────────────────────────────────────────────────────

class WizardStep1Screen extends StatefulWidget {
  const WizardStep1Screen({super.key});

  @override
  State<WizardStep1Screen> createState() => _WizardStep1ScreenState();
}

class _WizardStep1ScreenState extends State<WizardStep1Screen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    final data = WizardClientData(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WizardStep2Screen(client: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Новый замер')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WizardHeader(
            step: 1,
            total: 3,
            title: 'ДАННЫЕ КЛИЕНТА',
            subtitle: 'Кому считаем окна',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Имя клиента',
                      hintText: 'Иван Иванович',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                      hintText: '+7 900 000-00-00',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _addrCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Адрес',
                      hintText: 'г. Саратов, ул. Ленина, д. 1, кв. 2',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: onSurface.withOpacity(0.45)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Имя обязательно. Телефон и адрес можно уточнить позже.',
                  style: TextStyle(fontSize: 12, height: 1.35, color: onSurface.withOpacity(0.55)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text('ДАЛЕЕ'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                backgroundColor: isDark ? _goldLight : _navy,
                foregroundColor: isDark ? const Color(0xFF20180A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// ШАГ 2 — ЗАГЛУШКА (наполним позже)
// ───────────────────────────────────────────────────────────

class WizardStep2Screen extends StatelessWidget {
  final WizardClientData client;
  const WizardStep2Screen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(title: const Text('Новый замер')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WizardHeader(
            step: 2,
            total: 3,
            title: 'ИЗДЕЛИЯ',
            subtitle: client.name.isEmpty ? 'Клиент' : client.name,
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withOpacity(0.10),
                    border: Border.all(color: _gold.withOpacity(0.28)),
                  ),
                  child: const Icon(Icons.construction_rounded, size: 40, color: _bronze),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ШАГ 2 В РАЗРАБОТКЕ',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Здесь появится выбор изделий, размеры и чертежи',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.4, color: onSurface.withOpacity(0.55)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 19),
              label: const Text('НАЗАД'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                foregroundColor: _bronze,
                side: BorderSide(color: _gold.withOpacity(0.5), width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// ОБЩАЯ ШАПКА МАСТЕРА
// ───────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String subtitle;
  const _WizardHeader({
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16233C), Color(0xFF0A1120)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_goldLight, _bronze],
                  ),
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: Color(0xFF1A1305),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ШАГ $step ИЗ $total',
                      style: const TextStyle(
                        color: Color(0xFF9FB0CC),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF9FB0CC), fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(total, (i) {
              final active = i < step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: active ? _gold : const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
