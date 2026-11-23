import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'theme.dart';

/// Итог проверки обновлений.
class UpdateResult {
  final String currentVersion;
  final String? latestVersion;
  final String? apkUrl;
  final String? error;

  const UpdateResult({
    required this.currentVersion,
    this.latestVersion,
    this.apkUrl,
    this.error,
  });

  bool get hasUpdate {
    final l = latestVersion;
    if (l == null) return false;
    return _cmp(l, currentVersion) > 0;
  }

  static int _cmp(String a, String b) {
    List<int> parts(String v) => v
        .split(RegExp(r'[^0-9]'))
        .where((e) => e.isNotEmpty)
        .map(int.parse)
        .toList();
    final x = parts(a);
    final y = parts(b);
    final n = x.length > y.length ? x.length : y.length;
    for (var i = 0; i < n; i++) {
      final xi = i < x.length ? x[i] : 0;
      final yi = i < y.length ? y[i] : 0;
      if (xi != yi) return xi > yi ? 1 : -1;
    }
    return 0;
  }
}

/// Проверка и установка обновлений с GitHub Releases.
class UpdateChecker {
  UpdateChecker._();

  static const String repo = 'alexey17001700-coder/window_calc';

  static Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  /// Тихая проверка: ничего не показывает, отдаёт результат.
  static Future<UpdateResult> check() async {
    final cur = await currentVersion();
    try {
      final res = await http
          .get(
            Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        return UpdateResult(currentVersion: cur, error: 'HTTP ${res.statusCode}');
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = (map['tag_name'] as String? ?? '').replaceAll('v', '');
      String? apk;
      final assets = map['assets'];
      if (assets is List) {
        for (final a in assets) {
          final name = (a['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            apk = a['browser_download_url'] as String?;
            break;
          }
        }
      }
      return UpdateResult(currentVersion: cur, latestVersion: tag, apkUrl: apk);
    } catch (e) {
      return UpdateResult(currentVersion: cur, error: e.toString());
    }
  }

  /// Проверка при старте: нашёл обновление — сразу показывает диалог.
  static Future<void> checkOnStart(BuildContext context) async {
    final res = await check();
    if (!context.mounted) return;
    if (res.hasUpdate && res.latestVersion != null) {
      await showUpdate(context, res.latestVersion!, apkUrl: res.apkUrl);
    }
  }

  /// Показ диалога обновления.
  static Future<void> showUpdate(
    BuildContext context,
    String version, {
    String? apkUrl,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUi.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'ДОСТУПНО ОБНОВЛЕНИЕ',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 14,
            letterSpacing: 1.4,
          ),
        ),
        content: Text(
          'Версия $version уже вышла.\nУстановить сейчас?',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ПОЗЖЕ', style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (apkUrl != null) install(apkUrl);
            },
            child: const Text('УСТАНОВИТЬ', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  /// Скачивает APK и открывает системный установщик.
  static Future<void> install(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/almas_update.apk';
      await Dio().download(url, path);
      await OpenFilex.open(path);
    } catch (_) {
      // тихо: не удалось скачать — пользователь попробует позже
    }
  }
}
