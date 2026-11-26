import 'package:flutter/material.dart';

import 'theme.dart';
import 'screen_flash.dart';

/// Модель клиента для мастера замера.
class ClientData {
  String name = '';
  String phone = '';
  String address = '';
}

// ═══════════════════════════════════════════════════════════════════
//  ОБЩАЯ ШАПКА МАСТЕРА
// ═══════════════════════════════════════════════════════════════════
class WizardHeader extends StatelessWidget {
  const WizardHeader({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final int total;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 22),
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ШАГ $step ИЗ $total',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _progress(step, total),
          const SizedBox(height: 18),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9FB0C6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(int step, int total) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: done ? AppColors.goldGradient : null,
                color: done ? null : Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Поле ввода в премиальном стиле.
class WizardField extends StatelessWidget {
  const WizardField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboard;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(label, size: 10.5),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 19, color: AppColors.bronze),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ШАГ 1 — ДАННЫЕ КЛИЕНТА
// ═══════════════════════════════════════════════════════════════════
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
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    final client = ClientData()
      ..name = _name.text.trim()
      ..phone = _phone.text.trim()
      ..address = _address.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WizardStep2Screen(client: client)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WizardHeader(
            step: 1,
            total: 3,
            title: 'Данные клиента',
            subtitle: 'Кому считаем окна',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              children: [
                AppUi.sectionTitle(context, 'Клиент'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        WizardField(
                          controller: _name,
                          label: 'Имя',
                          hint: 'Иван Петров',
                          icon: Icons.person_rounded,
                          keyboard: TextInputType.name,
                        ),
                        const SizedBox(height: 14),
                        WizardField(
                          controller: _phone,
                          label: 'Телефон',
                          hint: '+7 900 000-00-00',
                          icon: Icons.phone_rounded,
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        WizardField(
                          controller: _address,
                          label: 'Адрес',
                          hint: 'Город, улица, дом, квартира',
                          icon: Icons.location_on_rounded,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: AppColors.bronze),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Имя обязательно. Телефон и адрес можно уточнить позже.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, 14, 18, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? AppColors.line,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _next,
          child: const Text('ДАЛЕЕ'),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ШАГ 2 — ЗАГЛУШКА
// ═══════════════════════════════════════════════════════════════════
class WizardStep2Screen extends StatelessWidget {
  const WizardStep2Screen({super.key, required this.client});
  final ClientData client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WizardHeader(
            step: 2,
            total: 3,
            title: 'Изделия',
            subtitle: client.name.isEmpty ? 'Клиент' : client.name,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.window_rounded,
                          size: 40, color: AppColors.gold),
                    ),
                    const SizedBox(height: 22),
                    Text('ШАГ 2 В РАЗРАБОТКЕ',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Здесь появится выбор изделий, размеры и чертежи.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                18, 0, 18, MediaQuery.of(context).padding.bottom + 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('НАЗАД'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
