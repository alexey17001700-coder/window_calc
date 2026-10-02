import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateChecker {
  static Future<void> checkOnStart(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UpdateChecker работает!'),
          duration: Duration(seconds: 5),
        ),
      );
    }
    try {
      final info = await PackageInfo.fromPlatform();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Версия: ${info.version}+${info.buildNumber}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), duration: const Duration(seconds: 5)),
        );
      }
    }
  }
}
