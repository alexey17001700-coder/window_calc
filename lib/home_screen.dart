part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════
//  ГЛАВНОЕ МЕНЮ
// ═══════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});
  final Future<void> Function() onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _measureCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('measurements_v4');
    if (!mounted) return;
    setState(() => _measureCount = raw == null ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          _header(dark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              children: [
                AppUi.sectionTitle(context, 'Работа'),
                _card(
                  index: 0,
                  icon: Icons.add_rounded,
                  title: 'Создать замер',
                  subtitle: 'Новый расчёт по шагам',
                  accent: AppColors.gold,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WizardStep1Screen()),
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  index: 1,
                  icon: Icons.folder_rounded,
                  title: 'Сохранённые замеры',
                  subtitle: '$_measureCount в архиве',
                  accent: AppColors.info,
                  onTap: () => _soon('Сохранённые замеры'),
                ),
                const SizedBox(height: 12),
                _card(
                  index: 2,
                  icon: Icons.tune_rounded,
                  title: 'Настройки прайса',
                  subtitle: 'Цены и коэффициенты',
                  accent: AppColors.bronze,
                  onTap: () => _soon('Настройки прайса'),
                ),
                const SizedBox(height: 24),
                AppUi.sectionTitle(context, 'Сервис'),
                _card(
                  index: 3,
                  icon: Icons.build_rounded,
                  title: 'Сервис и ремонт',
                  subtitle: 'Заявки и работы',
                  accent: AppColors.success,
                  onTap: () => _soon('Сервис и ремонт'),
                ),
                const SizedBox(height: 12),
                _card(
                  index: 4,
                  icon: Icons.system_update_rounded,
                  title: 'Проверить обновление',
                  subtitle: 'Версия и обновления',
                  accent: AppColors.gold,
                  onTap: _checkUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _soon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — в разработке')),
    );
  }

  Future<void> _checkUpdate() async {
    final report = await UpdateChecker.getReport();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Обновление'),
        content: SingleChildScrollView(
          child: Text(report, style: const TextStyle(fontSize: 12.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final msg = await UpdateChecker.downloadAndInstall();
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg)));
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  Widget _header(bool dark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                      color: AppColors.gold.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.window_rounded,
                    color: AppColors.navy900, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ЗАМЕРЩИК ОКОН',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ALMAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Панель замерщика',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Расчёт, архив и сервис в одном месте',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9FB0C6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return _Reveal(
      delay: Duration(milliseconds: 55 * index),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
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
                      color: accent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: accent, size: 27),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 16, color: accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Каскадное появление элемента.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
