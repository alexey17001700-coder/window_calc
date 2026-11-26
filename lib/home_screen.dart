import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'main.dart';
import 'wizard_screen.dart';
import 'update_checker.dart';

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onToggleTheme;
  final bool isDark;
  const HomeScreen({
    super.key,
    required this.prefs,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = (widget.prefs.getStringList('measurements_v4') ?? []).length;
  }

  void _open(Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page))
        .then((_) => setState(() {
              _count =
                  (widget.prefs.getStringList('measurements_v4') ?? []).length;
            }));
  }

  Future<void> _checkUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final report = await UpdateChecker.getReport();
    if (!mounted) return;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Проверка обновления'),
        content: SingleChildScrollView(
          child: Text(report,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final msg = await UpdateChecker.downloadAndInstall();
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(msg)));
              }
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            _header(dark),
            const SectionTitle('Работа'),
            Reveal(
              index: 0,
              child: _MenuCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Создать замер',
                subtitle: 'Новый расчёт по шагам',
                accent: AppColors.gold,
                onTap: () => _open(const WizardStep1Screen()),
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              index: 1,
              child: _MenuCard(
                icon: Icons.folder_copy_outlined,
                title: 'Сохранённые замеры',
                subtitle: 'Архив расчётов и отправка',
                accent: const Color(0xFF3B82F6),
                onTap: () => _open(const PlaceholderScreen(
                  title: 'Сохранённые замеры',
                  subtitle: 'Здесь появится архив замеров с отправкой на завод, клиенту и дилеру.',
                  icon: Icons.folder_copy_outlined,
                )),
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              index: 2,
              child: _MenuCard(
                icon: Icons.tune_rounded,
                title: 'Настройки прайса',
                subtitle: 'Цены и коэффициенты расчёта',
                accent: const Color(0xFF8B5CF6),
                onTap: () => _open(const PlaceholderScreen(
                  title: 'Настройки прайса',
                  subtitle: 'Здесь появятся категории цен и коэффициентов расчёта.',
                  icon: Icons.tune_rounded,
                )),
              ),
            ),
            const SectionTitle('Сервис'),
            Reveal(
              index: 3,
              child: _MenuCard(
                icon: Icons.build_circle_outlined,
                title: 'Сервис и ремонт',
                subtitle: 'Заказы на регулировку и замену',
                accent: const Color(0xFFF97316),
                onTap: () => _open(const PlaceholderScreen(
                  title: 'Сервис и ремонт',
                  subtitle: 'Здесь появятся сервисные заказы: регулировка, замена ручек, резинок, стеклопакетов.',
                  icon: Icons.build_circle_outlined,
                )),
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              index: 4,
              child: _MenuCard(
                icon: Icons.system_update_alt_rounded,
                title: 'Проверить обновление',
                subtitle: 'Версия, статус и установка APK',
                accent: AppColors.ok,
                onTap: _checkUpdate,
              ),
            ),
            const SizedBox(height: 26),
            Center(
              child: Text(
                'ALMAS · ЗАМЕРЩИК ОКОН v1.9.2',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: dark
                      ? Colors.white.withOpacity(0.35)
                      : AppColors.inkSoft.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(bool dark) {
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
                width: 46,
                height: 46,
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
                child: const Icon(Icons.window_rounded,
                    color: AppColors.navyDeep, size: 24),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ЗАМЕРЩИК ОКОН',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'ALMAS · ПРЕМИУМ РАСЧЁТ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 46,
            height: 2,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _pill('v1.9.2', Icons.verified_outlined),
              const SizedBox(width: 8),
              _pill('$_count замеров', Icons.description_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.goldLight),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
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
                color: AppColors.navyDeep
                    .withOpacity(dark ? 0.30 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: accent.withOpacity(0.30)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.22),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: dark ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: dark
                              ? Colors.white.withOpacity(0.55)
                              : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withOpacity(0.06)
                        : AppColors.paper,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: dark ? AppColors.goldLight : AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
