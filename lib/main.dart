import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'viewer3d.dart';
import 'update_checker.dart';
import 'wizard_screen.dart';
import 'onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlmasApp());
}

class AlmasApp extends StatefulWidget {
  const AlmasApp({super.key});

  @override
  State<AlmasApp> createState() => _AlmasAppState();
}

class _AlmasAppState extends State<AlmasApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString('theme_mode') ?? 'light';
    if (!mounted) return;
    setState(() {
      _mode = v == 'dark'
          ? ThemeMode.dark
          : v == 'system'
              ? ThemeMode.system
              : ThemeMode.light;
    });
  }

  Future<void> toggleTheme() async {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode', next == ThemeMode.dark ? 'dark' : 'light');
    if (!mounted) return;
    setState(() => _mode = next);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: SplashScreen(onToggleTheme: toggleTheme),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ЗАСТАВКА
// ═══════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onToggleTheme});
  final Future<void> Function() onToggleTheme;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final List<String> _log = [];
  double _progress = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _boot();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final steps = <List<String>>[
      ['ИНИЦИАЛИЗАЦИЯ ЯДРА', '0.12'],
      ['ЗАГРУЗКА ПРАЙС-ЛИСТА', '0.30'],
      ['ПОДГОТОВКА ШАБЛОНОВ ОКОН', '0.52'],
      ['ПРОВЕРКА ЦЕЛОСТНОСТИ ДАННЫХ', '0.72'],
      ['СИНХРОНИЗАЦИЯ С СЕРВЕРОМ', '0.90'],
      ['СИСТЕМА ГОТОВА', '1.00'],
    ];
    for (final s in steps) {
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      setState(() {
        _log.add(s[0]);
        _progress = double.parse(s[1]);
      });
    }
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    setState(() => _ready = true);
    if (mounted) UpdateChecker.checkOnStart(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _c,
                  child: _model3d(),
                ),
              ),
              const SizedBox(height: 22),
              FadeTransition(
                opacity: _c,
                child: Row(
                  children: [
                    _logo(),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ЗАМЕРЩИК ОКОН',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'ALMAS · ПРОФЕССИОНАЛЬНЫЙ РАСЧЁТ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _progressBar(),
              const SizedBox(height: 20),
              _logPanel(),
              const SizedBox(height: 16),
              if (_ready) _startButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _model3d() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1B2C44)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: Viewer3D()),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF000000).withOpacity(0.72),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1B2C44)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swipe_rounded,
                      size: 12, color: Color(0xFF7E93AC)),
                  const SizedBox(width: 6),
                  AppUi.label('ОКНО 1300 × 1400 ММ',
                      color: const Color(0xFF7E93AC), size: 9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.4),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.window_rounded,
          color: AppColors.navy900, size: 30),
    );
  }

  Widget _progressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppUi.label('ЗАГРУЗКА СИСТЕМЫ',
                color: const Color(0xFF7E93AC), size: 10.5),
            const Spacer(),
            Text(
              '${(_progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 4, color: const Color(0xFF1B2C44)),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                widthFactor: _progress,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logPanel() {
    return Container(
      width: double.infinity,
      height: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2C44)),
      ),
      child: ListView.builder(
        itemCount: _log.length,
        itemBuilder: (_, i) {
          final last = i == _log.length - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  last ? Icons.check_circle_rounded : Icons.check_rounded,
                  size: 13,
                  color: last ? AppColors.gold : const Color(0xFF3E5A7C),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _log[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: last
                          ? AppColors.goldLight
                          : const Color(0xFF6E819A),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _startButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy900,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 420),
              pageBuilder: (_, a, __) => FadeTransition(
                opacity: a,
                child: OnboardingScreen(
                  onFinish: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 380),
                        pageBuilder: (_, a2, __) => FadeTransition(
                          opacity: a2,
                          child:
                              HomeScreen(onToggleTheme: widget.onToggleTheme),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        child: const Text('НАЧАТЬ РАБОТУ'),
      ),
    );
  }
}

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
