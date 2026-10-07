import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateChecker {
  static const String owner = 'alexey17001700-coder';
  static const String repo = 'window_calc';

  /// Возвращает текст отчёта (для отладочного окна)
  static Future<String> getReport() async {
    final sb = StringBuffer();

    String currentVersion = '?';
    String buildNumber = '?';
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
      buildNumber = info.buildNumber;
      sb.writeln('Текущая версия: $currentVersion+$buildNumber');
    } catch (e) {
      sb.writeln('Ошибка PackageInfo: $e');
    }

    String? latestVersion;
    try {
      final url = Uri.parse(
          'https://api.github.com/repos/$owner/$repo/releases/latest');
      sb.writeln('Запрос: $url');
      final resp = await http.get(url, headers: {
        'Accept': 'application/vnd.github+json',
      });
      sb.writeln('HTTP статус: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = resp.body;
        final match = RegExp(r'"tag_name"\s*:\s*"v?([^"]+)"').firstMatch(data);
        if (match != null) {
          final tag = match.group(1) ?? '';
          latestVersion = tag.split('+').first;
          sb.writeln('Последняя на GitHub: $latestVersion');
        } else {
          sb.writeln('Не найден tag_name в ответе');
        }
      }
    } catch (e) {
      sb.writeln('Ошибка сети: $e');
    }

    if (latestVersion != null) {
      final isNewer = _isNewer(latestVersion, currentVersion);
      sb.writeln('');
      sb.writeln(isNewer
          ? '✅ ДОСТУПНО ОБНОВЛЕНИЕ до $latestVersion'
          : '✅ Обновление не требуется');
    }

    return sb.toString();
  }

  static bool _isNewer(String latest, String current) {
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

  /// Скачивает и открывает APK последнего релиза
  static Future<String> downloadAndInstall() async {
  try {
    // 1. Получаем точный URL из GitHub API
    final apiUrl = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/releases/latest');
    final resp = await http.get(apiUrl, headers: {
      'Accept': 'application/vnd.github+json',
    });
    if (resp.statusCode != 200) {
      return 'GitHub API: ${resp.statusCode}';
    }

    final body = resp.body;
    final match = RegExp(
            r'"browser_download_url"\s*:\s*"([^"]+app-release\.apk)"')
        .firstMatch(body);
    if (match == null) {
      return 'APK не найден в Release';
    }
    final apkUrl = match.group(1)!;

    // 2. Сохраняем в постоянную папку приложения
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/update.apk';

    // 3. Скачиваем через http stream
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(apkUrl));
    final streamed = await client.send(request);
    if (streamed.statusCode != 200) {
      return 'Ошибка скачивания: ${streamed.statusCode}';
    }
    final file = File(savePath);
    final sink = file.openWrite();
    await streamed.stream.pipe(sink);
    await sink.close();
    client.close();

    // 4. Проверка размера
    final size = await file.length();
    if (size < 1000000) {
      return 'Файл недокачался: ${size} байт';
    }

    // 5. Открываем установщик
    final result = await OpenFilex.open(savePath);
    if (result.type != ResultType.done) {
      return 'Открыть установщик не удалось: ${result.message}';
    }
    return 'Установщик открыт (${(size / 1024 / 1024).toStringAsFixed(1)} МБ)';
  } catch (e) {
    return 'Ошибка: $e';
  }
  }

  /// Проверка при запуске с задержкой и логированием ошибок
  static Future<void> checkOnStart(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;

    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final url = Uri.parse(
          'https://api.github.com/repos/$owner/$repo/releases/latest');
      final resp = await http.get(url, headers: {
        'Accept': 'application/vnd.github+json',
      });
      if (resp.statusCode != 200) return;

      final match =
          RegExp(r'"tag_name"\s*:\s*"v?([^"]+)"').firstMatch(resp.body);
      if (match == null) return;

      final tag = match.group(1) ?? '';
      final latestVersion = tag.split('+').first;

      if (_isNewer(latestVersion, currentVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка проверки: $e')),
        );
      }
    }
  }

  static void _showUpdateDialog(BuildContext context, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Доступно обновление'),
        content: Text('Версия $newVersion доступна.\nСкачать и установить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final msg = await downloadAndInstall();
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
    );
  }
}
