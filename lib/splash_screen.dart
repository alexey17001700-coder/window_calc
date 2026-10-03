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
      appBar: AppBar(
        title: const Text('Запуск'),
        actions: [
          if (_done)
            IconButton(
              icon: const Icon(Icons.description),
              tooltip: 'Отчёт',
              onPressed: _showReport,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_done)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _log[i],
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
              ),
            ),
            if (showUpdateCard)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.system_update, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Доступно обновление: $_latestVersion',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (_changelogText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Что нового:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _changelogText,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _updateDismissed = true;
                              });
                            },
                            child: const Text('Позже'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              final msg =
                                  await UpdateChecker.downloadAndInstall();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                              }
                            },
                            child: const Text('Обновить'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _done ? _continue : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Начать замеры'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
