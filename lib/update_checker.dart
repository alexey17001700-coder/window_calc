import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'theme.dart';

/// Результат тихой проверки обновлений.
class UpdateResult {
  UpdateResult({
    required this.currentVersion,
    this.latestVersion,
    this.apkUrl,
    this.error,
  });

  final String currentVersion;
  final String? latestVersion;
  final String? apkUrl;
  final String? error;

  bool get hasUpdate {
    final l = latestVersion;
    if (l == null || l.isEmpty) return false;
    return _cmp(l, currentVersion) > 0;
  }

  static int _cmp(String a, String b) {
    List<int> nums(String s) {
      final clean = s.split('+').first.split('-').first;
      return clean
          .split('.')
          .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
          .toList();
    }

    final x = nums(a);
    final y = nums(b);
    final n = x.length > y.length ? x.length : y.length;
    for (var i = 0; i < n; i++) {
      final p = i < x.length ? x[i] : 0;
      final q = i < y.length ? y[i] : 0;
      if (p != q) return p > q ? 1 : -1;
    }
    return 0;
  }
}

/// Проверка версии на GitHub и установка APK.
class UpdateChecker {
  static const String owner = 'alexey17001700-coder';
  static const String repo = 'window_calc';

  static String get _latestUrl =>
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  static Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  /// Тихая проверка — ничего не показывает.
  static Future<UpdateResult> check() async {
    final cur = await currentVersion();
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      final res = await dio.get<dynamic>(
        _latestUrl,
        options: Options(headers: {'Accept': 'application/vnd.github+json'}),
      );
      final data = res.data;
      if (data is! Map) {
        return UpdateResult(currentVersion: cur, error: 'НЕВЕРНЫЙ ОТВЕТ');
      }
      final tag = (data['tag_name'] ?? '').toString();
      final ver = tag.replaceAll('v', '').split('+').first.trim();
      String? apk;
      final assets = data['assets'];
      if (assets is List) {
        for (final a in assets) {
          if (a is Map) {
            final name = (a['name'] ?? '').toString();
            if (name.toLowerCase().endsWith('.apk')) {
              apk = (a['browser_download_url'] ?? '').toString();
              break;
            }
          }
        }
      }
      return UpdateResult(
        currentVersion: cur,
        latestVersion: ver.isEmpty ? null : ver,
        apkUrl: apk,
      );
    } catch (e) {
      return UpdateResult(currentVersion: cur, error: e.toString());
    }
  }

  /// Тихая проверка при старте: нашлось — сразу диалог.
  static Future<UpdateResult> checkOnStart(BuildContext context) async {
    final res = await check();
    if (res.hasUpdate && context.mounted) {
      final l = res.latestVersion;
      if (l != null) showUpdate(context, l);
    }
    return res;
  }

  /// Диалог «Доступно обновление».
  static Future<void> showUpdate(BuildContext context, String version) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        var busy = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppUi.radius),
                side: const BorderSide(color: Color(0x4DC9A227)),
              ),
              title: const Text(
                'ДОСТУПНО ОБНОВЛЕНИЕ',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Новая версия v$version.\nУстановить поверх текущей?',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'ПОЗЖЕ',
                    style: TextStyle(color: AppColors.dim, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setState(() => busy = true);
                          final res = await check();
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          final url = res.apkUrl;
                          if (url == null || url.isEmpty) {
                            _toast(context, 'APK НЕ НАЙДЕН В РЕЛИЗЕ');
                            return;
                          }
                          await install(context, url);
                        },
                  child: Text(
                    busy ? 'ЗАГРУЗКА...' : 'УСТАНОВИТЬ',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Скачать APK и открыть системный установщик.
  static Future<void> install(BuildContext context, String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/almas_update.apk';
      final dio = Dio(
        BaseOptions(
          receiveTimeout: const Duration(minutes: 3),
          followRedirects: true,
        ),
      );
      final file = File(path);
      if (await file.exists()) await file.delete();
      await dio.download(url, path);
      final res = await OpenFilex.open(path);
      if (res.type != ResultType.done && context.mounted) {
        _toast(context, 'НЕ УДАЛОСЬ ОТКРЫТЬ УСТАНОВЩИК');
      }
    } catch (e) {
      if (context.mounted) _toast(context, 'ЗАГРУЗКА НЕ УДАЛАСЬ');
    }
  }

  static void _toast(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}