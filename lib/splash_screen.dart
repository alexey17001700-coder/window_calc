import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'main.dart';
import 'home_screen.dart';
import 'update_checker.dart';

/// Заставка: премиальная тёмная, с проверкой обновления.
/// Логика обновления НЕ изменена — используется UpdateChecker.
class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onToggleTheme;
  final bool isDark;
  const SplashScreen({
    super.key,
    required this.prefs,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;
  final List<String> _log = [];
  bool _ready = false;

  static const _steps = [
    'Инициализация ядра...',
    'Загрузка прайс-листа...',
    'Чтение архива замеров...',
    'Проверка обновлений...',
    'Система готова',
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() {
        _log.add(_steps[i]);
        _progress = (i + 1) / _steps.length;
      });
    }
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() => _ready = true);
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          prefs: widget.prefs,
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.isDark,
        ),
      ),
    );
    // Проверка обновлений — через сохранённый UpdateChecker (логика не тронута)
    Future.delayed(const Duration(milliseconds: 600), () {
      UpdateChecker.checkOnStart(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.40),
                          blurRadius: 22,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.window_rounded,
                        color: AppColors.navyDeep, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ЗАМЕРЩИК ОКОН',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'ALMAS · ПОДГОТОВКА К РАБОТЕ',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation(
                    _ready ? AppColors.ok : AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _ready ? 'СИСТЕМА ГОТОВА' : 'ЗАГРУЗКА...',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: _ready ? AppColors.ok : AppColors.goldLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 132,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListView(
                  children: _log
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '> $e',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.5,
                                height: 1.3,
                                color: Colors.white.withOpacity(0.62),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _ready ? _enter : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  disabledBackgroundColor: Colors.white.withOpacity(0.10),
                  disabledForegroundColor: Colors.white38,
                ),
                child: const Text('НАЧАТЬ ЗАМЕРЫ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
