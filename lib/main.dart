import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'viewer3d.dart';
import 'update_checker.dart';
import 'wizard_screen.dart';
import 'onboarding.dart';

/// Глобальный навигатор: позволяет переключать экраны из колбэков,
/// даже когда контекст исходного экрана уже уничтожен (pushReplacement).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: appNavigatorKey,
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
  final ScrollController _logScroll = ScrollController();
  double _progress = 0;
  bool _ready = false;
  bool _busy = false;
  bool _checking = false;
  String? _updateVersion;
  int _capIndex = 0;
  Timer? _capTimer;
  final GlobalKey<ScreenFlashState> _flashKey = GlobalKey<ScreenFlashState>();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _capTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted) return;
      setState(() => _capIndex = (_capIndex + 1) % _caps.length);
    });
    _boot();
  }

  @override
  void dispose() {
    _capTimer?.cancel();
    _c.dispose();
    _logScroll.dispose();
    super.dispose();
  }

  /// Добавить строку в лог и прокрутить панель вниз.
  void _push(String line, double progress, {bool busy = false}) {
    if (!mounted) return;
    setState(() {
      _log.add(line);
      _progress = progress;
      _busy = busy;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.animateTo(
          _logScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Заменить последнюю строку лога (для «выполняется…» → результат).
  void _replaceLast(String line, double progress) {
    if (!mounted) return;
    setState(() {
      if (_log.isNotEmpty) _log.removeLast();
      _log.add(line);
      _progress = progress;
      _busy = false;
    });
  }

  Future<void> _boot() async {
    const tick = Duration(milliseconds: 240);

    _push('ИНИЦИАЛИЗАЦИЯ ЯДРА', 0.10);
    await Future.delayed(tick);
    _push('ЗАГРУЗКА ПРАЙС-ЛИСТА', 0.24);
    await Future.delayed(tick);
    _push('ПОДГОТОВКА ШАБЛОНОВ ОКОН', 0.38);
    await Future.delayed(tick);
    _push('ПРОВЕРКА ЦЕЛОСТНОСТИ ДАННЫХ', 0.52);
    await Future.delayed(tick);

    // ── Реальная проверка обновлений ──
    _push('ПРОВЕРКА ОБНОВЛЕНИЙ...', 0.64, busy: true);
    final res = await UpdateChecker.check();
    if (!mounted) return;
    if (res.error != null) {
      _replaceLast('ОБНОВЛЕНИЯ: НЕ ПРОВЕРЕНО (${res.error})', 0.78);
    } else if (res.hasUpdate) {
      _updateVersion = res.latestVersion;
      _replaceLast('ДОСТУПНО ОБНОВЛЕНИЕ v${res.latestVersion}', 0.78);
    } else {
      _replaceLast('ОБНОВЛЕНИЙ НЕТ · ВЕРСИЯ ${res.currentVersion}', 0.78);
    }

    await Future.delayed(tick);
    _push('СИНХРОНИЗАЦИЯ С СЕРВЕРОМ', 0.90);
    await Future.delayed(tick);
    _push('СИСТЕМА ГОТОВА', 1.00);
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    setState(() => _ready = true);

    if (_updateVersion != null && mounted) {
      UpdateChecker.showUpdate(context, _updateVersion!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: ScreenFlash(
        key: _flashKey,
        child: SafeArea(
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
              if (_ready) const SizedBox(height: 10),
              if (_ready) _checkButton(),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _model3d() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy900,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: Viewer3D()),
          Positioned(
            left: 12,
            top: 12,
            right: 12,
            child: _capabilityCard(),
          ),
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

  /// Карточка «ЧТО УМЕЕТ» — возможности приложения, меняются по кругу.
  Widget _capabilityCard() {
    final c = _caps[_capIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withOpacity(0.74),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(c.icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 9),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey<int>(_capIndex),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF9FB0C6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_capIndex + 1}/${_caps.length}',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
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
            Expanded(
              child: AppUi.label(
                _busy
                    ? 'ПРОВЕРКА ОБНОВЛЕНИЙ'
                    : (_log.isEmpty ? 'ЗАГРУЗКА СИСТЕМЫ' : _log.last),
                color: const Color(0xFF7E93AC),
                size: 10.5,
              ),
            ),
            const SizedBox(width: 10),
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
        controller: _logScroll,
        itemCount: _log.length + (_busy ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _log.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ВЫПОЛНЯЕТСЯ...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final last = i == _log.length - 1 && !_busy;
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
        onPressed: _openOnboarding,
        child: const Text('НАЧАТЬ РАБОТУ'),
      ),
    );
  }

  /// Открыть мастер замера. Колбэки работают через глобальный навигатор —
  /// контекст этого экрана после pushReplacement уже мёртв.
  void _openOnboarding() {
    _flashKey.currentState?.fire();
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: OnboardingScreen(
            onBack: _backToSplash,
            onFinish: _openHome,
          ),
        ),
      ),
    );
  }

  /// Возврат из мастера на главный экран (заставка с проверкой обновлений).
  void _backToSplash() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: SplashScreen(onToggleTheme: widget.onToggleTheme),
        ),
      ),
      (route) => false,
    );
  }

  /// Мастер завершён → главное меню.
  void _openHome() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: HomeScreen(onToggleTheme: widget.onToggleTheme),
        ),
      ),
      (route) => false,
    );
  }

  /// Кнопка ручной проверки обновлений на главном экране.
  Widget _checkButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: AppColors.gold.withOpacity(0.55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        onPressed: _checking ? null : _manualCheck,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_checking)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            else
              const Icon(Icons.system_update_rounded, size: 18),
            const SizedBox(width: 9),
            Text(_checking ? 'ПРОВЕРКА...' : 'ПРОВЕРИТЬ ОБНОВЛЕНИЕ'),
          ],
        ),
      ),
    );
  }

  /// Ручная проверка обновлений: пишет в лог, при находке открывает диалог.
  Future<void> _manualCheck() async {
    _flashKey.currentState?.fire();
    setState(() => _checking = true);
    _push('РУЧНАЯ ПРОВЕРКА ОБНОВЛЕНИЙ...',
        _progress < 0.64 ? 0.64 : _progress,
        busy: true);

    final res = await UpdateChecker.check();
    if (!mounted) return;

    if (res.error != null) {
      _replaceLast('ОБНОВЛЕНИЯ: НЕ ПРОВЕРЕНО (${res.error})', _progress);
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось проверить: ${res.error}')),
      );
      return;
    }

    if (res.hasUpdate) {
      _replaceLast('ДОСТУПНО ОБНОВЛЕНИЕ v${res.latestVersion}', _progress);
      setState(() => _checking = false);
      _updateVersion = res.latestVersion;
      UpdateChecker.showUpdate(context, res.latestVersion!);
    } else {
      _replaceLast('ОБНОВЛЕНИЙ НЕТ · ВЕРСИЯ ${res.currentVersion}', _progress);
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Обновлений нет · версия ${res.currentVersion}')),
      );
    }
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
  final GlobalKey<ScreenFlashState> _flashKey = GlobalKey<ScreenFlashState>();

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
      body: ScreenFlash(
        key: _flashKey,
        child: Column(
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
          onTap: () {
            _flashKey.currentState?.fire();
            onTap();
          },
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

/// Возможность приложения — строка на заставке.
class _Capability {
  const _Capability(this.icon, this.title, this.sub);
  final IconData icon;
  final String title;
  final String sub;
}

/// Что умеет приложение — показывается на заставке по кругу.
const List<_Capability> _caps = [
  _Capability(Icons.view_in_ar_rounded, '3D-ПРОСМОТР ОКНА',
      'Модель вращается пальцем'),
  _Capability(Icons.architecture_rounded, 'ЧЕРТЁЖ ПО ГОСТ',
      'Створки Г · П · ПО · О'),
  _Capability(Icons.account_tree_rounded, 'ДЕРЕВО ИЗДЕЛИЙ',
      'Окно · балкон · дверь · фасад'),
  _Capability(Icons.straighten_rounded, 'РАЗМЕРЫ В ММ И СМ',
      'Проверка допусков'),
  _Capability(Icons.calculate_rounded, 'СМЕТА НА МЕСТЕ',
      'Цена считается сама'),
  _Capability(Icons.history_rounded, 'ИСТОРИЯ И КЛИЕНТЫ',
      'До 300 замеров в памяти'),
  _Capability(Icons.photo_camera_rounded, 'ФОТО И PDF-ЛИСТ',
      'Отправка клиенту'),
  _Capability(Icons.system_update_rounded, 'ОБНОВЛЕНИЕ ПО ВОЗДУХУ',
      'Проверка версии'),
];
