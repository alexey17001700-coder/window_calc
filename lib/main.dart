import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'premium_bg.dart';
import 'theme.dart';
import 'update_checker.dart';
import 'viewer3d.dart';

/// Глобальный навигатор — нужен для переходов из уже уничтоженных экранов.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const AlmasApp());

class AlmasApp extends StatelessWidget {
  const AlmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}

/// Заставка: 3D-окно, живой лог загрузки, проверка обновлений.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _log = [];
  final ScrollController _scroll = ScrollController();

  double _progress = 0;
  bool _ready = false;
  bool _checking = false;
  String _stage = 'ЗАГРУЗКА СИСТЕМЫ';

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
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _boot() async {
    _line('ЗАПУСК ЯДРА...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _progress = 0.25);

    _line('ПРОВЕРКА КОМПОНЕНТОВ...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _progress = 0.45);

    _line('ЗАГРУЗКА ДЕРЕВА РАБОТ...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _progress = 0.62);

    _line('ПОДГОТОВКА ЧЕРТЕЖА...');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _progress = 0.78;
      _stage = 'ПРОВЕРКА ОБНОВЛЕНИЙ';
    });

    _line('ПРОВЕРКА ОБНОВЛЕНИЙ...');
    final res = await UpdateChecker.check();
    if (!mounted) return;

    if (res.error != null) {
      _line('ОБНОВЛЕНИЯ: НЕ ПРОВЕРЕНО (сеть недоступна)');
    } else if (res.hasUpdate) {
      _line('ДОСТУПНО ОБНОВЛЕНИЕ v${res.latestVersion}');
    } else {
      _line('ОБНОВЛЕНИЙ НЕТ · ВЕРСИЯ ${res.currentVersion}');
    }

    setState(() {
      _progress = 1;
      _stage = 'СИСТЕМА ГОТОВА';
      _ready = true;
    });

    if (res.hasUpdate && res.latestVersion != null) {
      await UpdateChecker.showUpdate(
        context,
        res.latestVersion!,
        apkUrl: res.apkUrl,
      );
    }
  }

  Future<void> _manualCheck() async {
    if (_checking) return;
    setState(() => _checking = true);
    _line('РУЧНАЯ ПРОВЕРКА ОБНОВЛЕНИЙ...');

    final res = await UpdateChecker.check();
    if (!mounted) return;
    setState(() => _checking = false);

    if (res.error != null) {
      _line('ОБНОВЛЕНИЯ: НЕ ПРОВЕРЕНО');
      return;
    }
    if (res.hasUpdate && res.latestVersion != null) {
      _line('ДОСТУПНО ОБНОВЛЕНИЕ v${res.latestVersion}');
      await UpdateChecker.showUpdate(
        context,
        res.latestVersion!,
        apkUrl: res.apkUrl,
      );
      return;
    }
    _line('ОБНОВЛЕНИЙ НЕТ · ВЕРСИЯ ${res.currentVersion}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ОБНОВЛЕНИЙ НЕТ · УСТАНОВЛЕНА ПОСЛЕДНЯЯ ВЕРСИЯ')),
    );
  }

  void _openHome() {
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: PremiumBg()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _logo(),
                  Expanded(child: const Viewer3D()),
                  _logPanel(),
                  const SizedBox(height: 12),
                  _progressBar(),
                  const SizedBox(height: 8),
                  Text(
                    _stage,
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 10.5,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _goldButton(
                    'НАЧАТЬ РАБОТУ',
                    Icons.arrow_forward_rounded,
                    _ready ? _openHome : null,
                  ),
                  const SizedBox(height: 10),
                  _checkButton(),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.goldLight, AppColors.goldDark],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.gold.withOpacity(0.30), blurRadius: 18),
            ],
          ),
          child: const Icon(Icons.window_rounded,
              color: AppColors.navy900, size: 18),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ЗАМЕРЩИК ОКОН',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 13,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'ALMAS · ПРОФЕССИОНАЛЬНЫЙ ЗАМЕР',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 9,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logPanel() {
    return Container(
      height: 96,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.navy800.withOpacity(0.72),
        borderRadius: BorderRadius.circular(AppUi.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        controller: _scroll,
        itemCount: _log.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '› ${_log[i]}',
            style: TextStyle(
              color: i == _log.length - 1 ? AppColors.goldLight : AppColors.textDim,
              fontSize: 10.5,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(height: 5, color: AppColors.navy700),
          FractionallySizedBox(
            widthFactor: _progress.clamp(0.0, 1.0),
            child: Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.goldDark, AppColors.goldLight],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldButton(String label, IconData icon, VoidCallback? onTap) {
    final on = onTap != null;
    return Opacity(
      opacity: on ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppUi.radius),
          onTap: onTap,
          child: Container(
            height: AppUi.buttonH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppUi.radius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDark],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.gold.withOpacity(0.30), blurRadius: 22),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.navy900,
                    fontSize: 13,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: AppColors.navy900, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppUi.radius),
        onTap: _checking ? null : _manualCheck,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUi.radius),
            color: AppColors.navy800.withOpacity(0.72),
            border: Border.all(color: AppColors.gold.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_checking)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                )
              else
                const Icon(Icons.refresh_rounded, color: AppColors.gold, size: 17),
              const SizedBox(width: 8),
              Text(
                _checking ? 'ПРОВЕРКА...' : 'ПРОВЕРИТЬ ОБНОВЛЕНИЕ',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11.5,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
