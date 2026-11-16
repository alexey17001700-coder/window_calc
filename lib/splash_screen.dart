import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'update_checker.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() loadData;
  final Widget Function() buildMainMenu;

  const SplashScreen({
    super.key,
    required this.loadData,
    required this.buildMainMenu,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _log = [];
  bool _done = false;
  bool _hasUpdate = false;
  bool _updateDismissed = false;
  String _latestVersion = '';
  String _currentVersion = '';
  String _changelogText = '';

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _addLog(String line) {
    if (!mounted) return;
    setState(() => _log.add(line));
  }

  Future<String> _fetchChangelog() async {
    try {
      final url = Uri.parse(
          'https://raw.githubusercontent.com/${UpdateChecker.owner}/${UpdateChecker.repo}/main/CHANGELOG.md');
      final resp = await http.get(url);
      if (resp.statusCode != 200) return '';
      final lines = resp.body.split('\n');
      final sb = StringBuffer();
      bool started = false;
      for (final line in lines) {
        if (line.startsWith('## ')) {
          if (started) break;
          started = true;
          continue;
        }
        if (started) {
          final t = line.trim();
          if (t.isNotEmpty) sb.writeln(t);
        }
      }
      return sb.toString().trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> _run() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
      _addLog('✅ Версия: ${info.version}+${info.buildNumber}');
    } catch (e) {
      _addLog('❌ Ошибка версии: $e');
    }

    _addLog('⏳ Загрузка данных...');
    try {
      await widget.loadData();
      _addLog('✅ Данные загружены');
    } catch (e) {
      _addLog('❌ Ошибка данных: $e');
    }

    _addLog('⏳ Проверка обновлений...');
    try {
      final latest = await _checkUpdate();
      if (latest == null) {
        _addLog('⚠️ Не удалось проверить');
      } else if (_isNewer(latest, _currentVersion)) {
        _hasUpdate = true;
        _latestVersion = latest;
        _addLog('✅ Доступно обновление: $latest');
        _addLog('⏳ Загрузка списка изменений...');
        final cl = await _fetchChangelog();
        if (cl.isNotEmpty) {
          _changelogText = cl;
          _addLog('✅ Список изменений загружен');
        } else {
          _addLog('⚠️ Список изменений не получен');
        }
      } else {
        _addLog('✅ Обновление не требуется ($latest)');
      }
    } catch (e) {
      _addLog('❌ Ошибка проверки: $e');
    }

    _addLog('✅ Готово');
    setState(() => _done = true);
  }

  Future<String?> _checkUpdate() async {
    try {
      final url = Uri.parse(
          'https://api.github.com/repos/${UpdateChecker.owner}/${UpdateChecker.repo}/releases/latest');
      final resp = await http.get(url, headers: {
        'Accept': 'application/vnd.github+json',
      });
      _addLog('   HTTP: ${resp.statusCode}');
      if (resp.statusCode != 200) return null;
      final match =
          RegExp(r'"tag_name"\s*:\s*"v?([^"]+)"').firstMatch(resp.body);
      if (match == null) return null;
      return (match.group(1) ?? '').split('+').first;
    } catch (e) {
      _addLog('   Сеть: $e');
      return null;
    }
  }

  bool _isNewer(String latest, String current) {
    final l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  void _showReport() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Отчёт запуска'),
        content: SingleChildScrollView(
          child: SelectableText(_log.join('\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.buildMainMenu()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showUpdateCard = _hasUpdate && !_updateDismissed;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC9A227), Color(0xFFE0C25A)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFC9A227).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.window_rounded,
                        color: Color(0xFF0F1B2D), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ЗАМЕРЩИК ОКОН',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white)),
                        SizedBox(height: 3),
                        Text('ALMAS · ПОДГОТОВКА К РАБОТЕ',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                                color: Color(0xFFC9A227))),
                      ],
                    ),
                  ),
                  if (_done)
                    IconButton(
                      icon: const Icon(Icons.description_outlined,
                          color: Colors.white54, size: 20),
                      tooltip: 'Отчёт',
                      onPressed: _showReport,
                    ),
                ],
              ),
              const SizedBox(height: 22),
              if (!_done)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFFC9A227))),
                )
              else
                Row(children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF4ADE80), size: 16),
                  const SizedBox(width: 6),
                  const Text('СИСТЕМА ГОТОВА',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Color(0xFF4ADE80))),
                ]),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView.builder(
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        _log[i],
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.white60),
                      ),
                    ),
                  ),
                ),
              ),
              if (showUpdateCard)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFF4ADE80).withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.system_update,
                              color: Color(0xFF4ADE80), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ДОСТУПНО ОБНОВЛЕНИЕ · $_latestVersion',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF4ADE80)),
                            ),
                          ),
                        ],
                      ),
                      if (_changelogText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text('Что нового:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _changelogText,
                            style: const TextStyle(
                                fontSize: 12.5, color: Colors.white70),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _updateDismissed = true;
                              });
                            },
                            child: const Text('Позже',
                                style: TextStyle(color: Colors.white54)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF4ADE80),
                                foregroundColor: const Color(0xFF0F1B2D)),
                            onPressed: () async {
                              final msg =
                                  await UpdateChecker.downloadAndInstall();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                              }
                            },
                            child: const Text('ОБНОВИТЬ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A227),
                    foregroundColor: const Color(0xFF0F1B2D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _done ? _continue : null,
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text('НАЧАТЬ ЗАМЕРЫ',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
