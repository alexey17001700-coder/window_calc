import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme.dart';

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
