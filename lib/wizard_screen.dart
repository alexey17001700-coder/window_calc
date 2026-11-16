import 'package:flutter/material.dart';

import 'theme.dart';

/// Пошаговый мастер создания замера.
/// ШАГ 1 — данные клиента. Шаги 2 и 3 — заготовки под наполнение.

class WizardStep1Screen extends StatefulWidget {
  const WizardStep1Screen({super.key});

  @override
  State<WizardStep1Screen> createState() => _WizardStep1ScreenState();
}

class _WizardStep1ScreenState extends State<WizardStep1Screen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _next() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WizardStep2Screen(
          clientName: name,
          phone: _phone.text.trim(),
          address: _address.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Новый замер')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          const WizardHeader(
            step: 1,
            total: 3,
            title: 'Данные клиента',
            subtitle: 'Кому считаем окна',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? AppColors.navy : AppColors.paperCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.07)
                    : AppColors.ink.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDeep.withOpacity(dark ? 0.30 : 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Имя клиента',
                    hintText: 'Например: Иванов Иван',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    hintText: '+7 (___) ___-__-__',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _address,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Адрес объекта',
                    hintText: 'Город, улица, дом, квартира',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 15,
                  color: dark ? Colors.white38 : AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Имя обязательно, телефон и адрес можно уточнить позже',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dark ? Colors.white38 : AppColors.inkSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: _next,
            child: const Text('ДАЛЕЕ'),
          ),
        ],
      ),
    );
  }
}

/// ШАГ 2 — заготовка (изделия, размеры, чертежи).
class WizardStep2Screen extends StatelessWidget {
  final String clientName;
  final String phone;
  final String address;
  const WizardStep2Screen({
    super.key,
    required this.clientName,
    this.phone = '',
    this.address = '',
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Новый замер')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          WizardHeader(
            step: 2,
            total: 3,
            title: 'Изделия',
            subtitle: clientName,
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.35),
                    blurRadius: 26,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.grid_view_rounded,
                  size: 44, color: AppColors.navyDeep),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'ШАГ 2 В РАЗРАБОТКЕ',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Здесь появится выбор изделий, размеры, шаблоны и чертежи.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: dark ? Colors.white70 : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('НАЗАД'),
          ),
        ],
      ),
    );
  }
}

/// Премиальная шапка шага мастера с полосой прогресса.
class WizardHeader extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String subtitle;
  const WizardHeader({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDeep.withOpacity(0.30),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
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
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.40),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ШАГ $step ИЗ $total',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.goldLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: Colors.white,
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
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.62),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(total, (i) {
              final done = i < step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    gradient: done ? AppColors.goldGradient : null,
                    color: done ? null : Colors.white.withOpacity(0.14),
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
