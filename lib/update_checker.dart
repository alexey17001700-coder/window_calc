import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'theme.dart';

/// Результат тихой проверки обновлений.
class UpdateResult {
  final String currentVersion;
  final String? latestVersion;
  final bool hasUpdate;
  final String? error;

  const UpdateResult({
    required this.currentVersion,
    this.latestVersion,
    this.hasUpdate = false,
    this.error,
  });
}

/// Проверка обновлений через GitHub Releases.
class UpdateChecker {
  static const repo = 'alexey17001700-coder/window_calc';
  static const _api = 'https://api.github.com/repos/$repo/releases/latest';
  static const apkUrl =
      'https://github.com/$repo/releases/latest/download/app-release.apk';

  /// Текущая версия приложения (из pubspec через PackageInfo).
  static Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version.isEmpty ? '0.0.0' : info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  /// Сравнение версий «3.4.64» и «3.4.63» → 1.
  static int _cmp(String a, String b) {
    final pa = a.split('.');
    final pb = b.split('.');
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final x = i < pa.length ? int.tryParse(pa[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : 0;
      final y = i < pb.length ? int.tryParse(pb[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : 0;
      if (x != y) return x > y ? 1 : -1;
    }
    return 0;
  }

  /// Тихая проверка: ничего не показывает, отдаёт результат наружу.
  static Future<UpdateResult> check() async {
    final cur = await currentVersion();
    try {
      final res = await http
          .get(Uri.parse(_api), headers: const {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        return UpdateResult(currentVersion: cur, error: 'HTTP ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = (data['tag_name'] as String? ?? '').trim();
      final tag = raw.startsWith('v') ? raw.substring(1) : raw;
      if (tag.isEmpty) {
        return UpdateResult(currentVersion: cur, error: 'нет тега релиза');
      }
      return UpdateResult(
        currentVersion: cur,
        latestVersion: tag,
        hasUpdate: _cmp(tag, cur) > 0,
      );
    } catch (_) {
      return UpdateResult(currentVersion: cur, error: 'сеть недоступна');
    }
  }

  /// Проверка при старте: тихо проверяет и показывает диалог, если есть новее.
  static Future<void> checkOnStart(BuildContext context) async {
    final res = await check();
    if (!context.mounted) return;
    if (res.hasUpdate && res.latestVersion != null) {
      await showUpdate(context, res.latestVersion!);
    }
  }

  /// Диалог «Доступно обновление» со ссылкой на APK.
  static Future<void> showUpdate(BuildContext context, String version) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          side: const BorderSide(color: AppColors.line),
        ),
        title: const Text(
          'ДОСТУПНО ОБНОВЛЕНИЕ',
          style: TextStyle(color: AppColors.gold, fontSize: 13, letterSpacing: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия v$version',
              style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Скачай новый APK и установи поверх — данные замеров сохранятся.',
              style: TextStyle(color: AppColors.textDim, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.navy900,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: const SelectableText(
                apkUrl,
                style: TextStyle(color: AppColors.glass, fontSize: 10.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ПОЗЖЕ', style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: apkUrl));
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('СКОПИРОВАТЬ ССЫЛКУ', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}
