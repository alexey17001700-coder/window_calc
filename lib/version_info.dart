import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ВЕРСИЯ ПРИЛОЖЕНИЯ И СЧЁТЧИК ПРАВОК
///  Версия поднимается КАЖДЫЕ 5 ПРАВОК (правило 11 SERVER_DIAGNOSTICS.md).
///  Плашка показывает, сколько правок накоплено и когда собирать новый APK.
/// ═══════════════════════════════════════════════════════════════════
class AppVersion {
  const AppVersion._();

  /// Версия из pubspec.yaml (без номера сборки).
  static const String version = '3.4.62';

  /// Номер сборки из pubspec.yaml.
  static const int build = 125;

  /// Сколько правок накоплено после последнего поднятия версии.
  static const int edits = 0;

  /// Предел правок до поднятия версии.
  static const int limit = 5;

  /// Пора поднимать версию и собирать новый APK.
  static bool get due => edits >= limit;

  /// Сколько правок осталось до обновления.
  static int get left => (limit - edits) < 0 ? 0 : (limit - edits);

  /// «3.4.55+118 · 2/5»
  static String get label => '$version+$build · $edits/$limit';
}

/// Плашка счётчика правок для экрана визуального замера.
/// Видно, сколько правок накоплено и когда собирать новый APK.
class VersionBadge extends StatelessWidget {
  const VersionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final due = AppVersion.due;
    final color = due ? const Color(0xFFFF4D6D) : AppColors.gold;
    final text = due
        ? 'АЛМАЗ · ПОРА ОБНОВЛЯТЬ · ПРАВОК ${AppVersion.edits}/${AppVersion.limit}'
        : 'АЛМАЗ · ВЕРСИЯ ${AppVersion.version} · ПРАВОК ${AppVersion.edits}/${AppVersion.limit}'
            ' · ДО ОБНОВЛЕНИЯ ${AppVersion.left}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(
            due ? Icons.system_update_alt_rounded : Icons.verified_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
