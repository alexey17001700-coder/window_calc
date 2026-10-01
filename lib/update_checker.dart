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

  /// Вызвать при старте приложения
  static Future<void> checkOnStart(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version; // например 1.0.0
      final latest = await _getLatestVersion();
      if (latest == null) return;
      if (_isNewer(latest, currentVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latest);
        }
      }
    } catch (_) {}
  }

  static Future<String?> _getLatestVersion() async {
    try {
      final url = Uri.parse(
          'https://api.github.com/repos/$owner/$repo/releases/latest');
      final resp = await http.get(url, headers: {
        'Accept': 'application/vnd.github+json',
      });
      if (resp.statusCode != 200) return null;
      final data = resp.body;
      // Простой парсинг tag_name без json_decode — но используем jsonDecode
      final match = RegExp(r'"tag_name"\s*:\s*"v?([^"]+)"').firstMatch(data);
      if (match == null) return null;
      // Убираем +build из тега если есть
      final tag = match.group(1) ?? '';
      return tag.split('+').first;
    } catch (_) {
      return null;
    }
  }

  /// Возвращает true, если latest > current
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

  static void _showUpdateDialog(BuildContext context, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Доступно обновление'),
        content: Text('Версия $newVersion уже доступна.\nСкачать и установить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(context);
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstall(BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Скачивание обновления...')),
        );
      }
      final url =
          'https://github.com/$owner/$repo/releases/latest/download/app-release.apk';
      final dir = await getExternalStorageDirectory();
      final savePath = '${dir!.path}/update.apk';

      await Dio().download(url, savePath);

      if (!context.mounted) return;
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть установщик: ${result.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка скачивания: $e')),
        );
      }
    }
  }
}
