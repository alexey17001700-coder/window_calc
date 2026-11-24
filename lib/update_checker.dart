import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme.dart';

/// Владелец и репозиторий на GitHub — источник обновлений.
/// Если репозиторий переехал, поменяй только эти две строки.
const String kGithubOwner = 'almas';
const String kGithubRepo = 'window_calc';

/// Результат проверки обновлений.
class UpdateResult {
  const UpdateResult({
    required this.currentVersion,
    this.latestVersion,
    this.error,
  });

  /// Версия, установленная на устройстве.
  final String currentVersion;

  /// Версия с GitHub — только если она новее установленной.
  final String? latestVersion;

  /// Текст ошибки, если проверить не удалось.
  final String? error;

  bool get hasUpdate => latestVersion != null;
}

/// Проверка версии приложения.
class UpdateChecker {
  static Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return '—';
    }
  }

  /// Спросить у GitHub последний релиз и сравнить с установленной версией.
  static Future<UpdateResult> check() async {
    final current = await currentVersion();
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req = await client.getUrl(Uri.parse(
          'https://api.github.com/repos/$kGithubOwner/$kGithubRepo/releases/latest'));
      req.headers.set('Accept', 'application/vnd.github+json');
      req.headers.set('User-Agent', 'window_calc-app');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode != 200) {
        return UpdateResult(
          currentVersion: current,
          error: 'HTTP ${res.statusCode}',
        );
      }

      final map = jsonDecode(body) as Map<String, dynamic>;
      final tag = (map['tag_name'] as String? ?? '').trim();
      if (tag.isEmpty) {
        return UpdateResult(currentVersion: current, error: 'нет тега релиза');
      }

      final latest = tag.replaceFirst(RegExp(r'^[vV]'), '');
      final cur = current.split('+').first;
      return UpdateResult(
        currentVersion: current,
        latestVersion: _isNewer(latest, cur) ? latest : null,
      );
    } catch (_) {
      return UpdateResult(currentVersion: current, error: 'нет сети');
    }
  }

  /// true, если [latest] новее [current] (сравнение по 3 числам).
  static bool _isNewer(String latest, String current) {
    List<int> parts(String s) =>
        s.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final a = parts(latest);
    final b = parts(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  /// Диалог «доступно обновление» с адресом релиза.
  static void showUpdate(BuildContext context, String version) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'ДОСТУПНО ОБНОВЛЕНИЕ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.gold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия v$version уже опубликована.',
              style: const TextStyle(color: AppColors.text, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'github.com/$kGithubOwner/$kGithubRepo/releases/latest',
              style: const TextStyle(color: AppColors.dim, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'ПОЗЖЕ',
              style: TextStyle(color: AppColors.dim),
            ),
          ),
        ],
      ),
    );
  }
}

/// Плитка «О приложении».
class UpdateTile extends StatefulWidget {
  const UpdateTile({super.key});

  @override
  State<UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends State<UpdateTile> {
  String _v = '…';

  @override
  void initState() {
    super.initState();
    UpdateChecker.currentVersion().then((v) {
      if (mounted) setState(() => _v = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppUi.card(),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Замерщик окон Almas',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'v$_v',
            style: const TextStyle(color: AppColors.dim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
