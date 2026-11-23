import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'onboarding.dart';
import 'theme.dart';
import 'update_checker.dart';
import 'viewer3d.dart';

/// Глобальный навигатор — нужен, чтобы кнопки заставки работали
/// после того, как сама заставка снята со стека.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const WindowCalcApp());
}

class WindowCalcApp extends StatelessWidget {
  const WindowCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.navy900,
        primaryColor: AppColors.gold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.gold,
          surface: AppColors.navy800,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Заставка: 3D-сцена, живой лог загрузки, проверка обновлений.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _log = [];
  final ScrollController _scroll = ScrollController();

  double _prog = 0;
  String _stage = 'ЗАГРУЗКА СИСТЕМЫ';
  bool _checking = false;
  bool _ready = false;
  bool _autoShown = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _line(String s) {
    if (!mounted) return;
    setState(() => _log.add(s));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _boot() async {
    _line('ЗАПУСК СИСТЕМЫ...');
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() => _prog = 0.10);

    _line('ЗАГРУЗКА МОДУЛЕЙ...');
    await Future.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    setState(() => _prog = 0.25);

    _line('ИНИЦИАЛИЗАЦИЯ 3D-СЦЕНЫ...');
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _prog = 0.45);

    _line('ПОДГОТОВКА ЧЕРТЕЖА ПО ГОСТ...');
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() => _prog = 0.62);

    _line('ЗАГРУЗКА ПРАЙСА...');
    await Future.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    setState(() => _prog = 0.75);

    await _doCheck(auto: true);
    if (!mounted) return;

    setState(() {
      _prog = 1.0;
      _stage = 'СИСТЕМА ГОТОВА';
      _ready = true;
    });
    _line('СИСТЕМА ГОТОВА');
  }

  Future<void> _doCheck({required bool auto}) async {
    if (mounted) {
      setState(() {
        _checking = true;
        _stage = 'ПРОВЕРКА ОБНОВЛЕНИЙ';
      });
    }
    _line('ПРОВЕРКА ОБНОВЛЕНИЙ...');

    final res = await UpdateChecker.check();
    if (!mounted) return;

    setState(() {
      _checking = false;
      if (_log.isNotEmpty && _log.last.startsWith('ПРОВЕРКА')) _log.removeLast();
    });

    if (res.hasUpdate && res.latestVersion != null) {
      _line('ДОСТУПНО ОБНОВЛЕНИЕ v${res.latestVersion}');
    } else if (res.error != null) {
      _line('ОБНОВЛЕНИЯ: НЕ ПРОВЕРЕНО (${res.error})');
    } else {
      _line('ОБНОВЛЕНИЙ НЕТ · ВЕРСИЯ ${res.currentVersion}');
    }

    if (auto && res.hasUpdate && res.latestVersion != null && !_autoShown) {
      _autoShown = true;
      await Future.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      await UpdateChecker.showUpdate(context, res.latestVersion!);
    }
  }

  Future<void> _manualCheck() async {
    if (_checking) return;
    _line('РУЧНАЯ ПРОВЕРКА ОБНОВЛЕНИЙ...');
    await _doCheck(auto: false);
    if (!mounted) return;
    final last = _log.isNotEmpty ? _log.last : '';
    if (!last.startsWith('ДОСТУПНО')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.navy800,
          content: Text(last, style: const TextStyle(color: AppColors.text, fontSize: 12)),
        ),
      );
    }
  }

  void _openOnboarding() {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          onBack: _backToSplash,
          onFinish: _openHome,
        ),
      ),
    );
  }

  void _backToSplash() {
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (r) => false,
    );
  }

  void _openHome() {
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBg()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(child: Viewer3D()),
                      Positioned(
                        right: 16,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.navy800.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Text(
                            'ОКНО 1300 × 1400 ММ',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 9.5,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'ЗАМЕРЩИК ОКОН',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ALMAS · ПРЕМИУМ',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 3),
                      ),
                      const SizedBox(height: 12),
                      _logPanel(),
                      const SizedBox(height: 10),
                      _progress(),
                      const SizedBox(height: 12),
                      _goldButton(),
                      const SizedBox(height: 8),
                      _ghostButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logPanel() {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy900.withOpacity(0.80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: ListView.builder(
        controller: _scroll,
        itemCount: _log.length + (_checking ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _log.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.4, color: AppColors.gold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ПРОВЕРКА ОБНОВЛЕНИЙ...',
                    style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 1),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Text(
              _log[i],
              style: TextStyle(
                color: i == _log.length - 1 ? AppColors.gold : AppColors.textDim,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _progress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _stage,
          style: const TextStyle(color: AppColors.textDim, fontSize: 9, letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _prog,
            minHeight: 4,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        ),
      ],
    );
  }

  Widget _goldButton() {
    final on = _ready;
    return GestureDetector(
      onTap: on ? _openOnboarding : null,
      child: AnimatedOpacity(
        opacity: on ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 220),
        child: Container(
          height: AppUi.buttonH,
          decoration: BoxDecoration(
            gradient: AppUi.goldGrad,
            borderRadius: BorderRadius.circular(AppUi.radiusSm),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'НАЧАТЬ РАБОТУ',
                style: TextStyle(
                  color: Color(0xFF1A1206),
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.play_arrow_rounded, size: 20, color: Color(0xFF1A1206)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ghostButton() {
    return GestureDetector(
      onTap: _checking ? null : _manualCheck,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.navy800.withOpacity(0.70),
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          border: Border.all(color: AppColors.gold.withOpacity(0.40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_checking)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.gold),
              )
            else
              const Icon(Icons.refresh_rounded, size: 16, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              _checking ? 'ПРОВЕРКА...' : 'ПРОВЕРИТЬ ОБНОВЛЕНИЕ',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 10.5,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBg extends StatelessWidget {
  const _SplashBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.1,
          colors: [Color(0xFF0E1A2C), AppColors.navy900],
        ),
      ),
    );
  }
}
