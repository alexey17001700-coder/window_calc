import 'package:flutter/material.dart';

import 'onboarding.dart';
import 'theme.dart';
import 'update_checker.dart';

/// Главное меню приложения.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Container(
        decoration: const BoxDecoration(gradient: AppUi.bgGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'ЗАМЕРЩИК ОКОН',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ALMAS · ПРЕМИУМ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 3),
                ),
                const SizedBox(height: 26),
                _tile(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  title: 'НОВЫЙ ЗАМЕР',
                  sub: 'Клиент · дерево · размеры · чертёж',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _tile(
                  context,
                  icon: Icons.system_update_alt_rounded,
                  title: 'ПРОВЕРИТЬ ОБНОВЛЕНИЕ',
                  sub: 'Тихо проверить новую версию',
                  onTap: () => UpdateChecker.checkOnStart(context),
                ),
                const SizedBox(height: 12),
                _tile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'О ПРИЛОЖЕНИИ',
                  sub: 'Версия и назначение',
                  onTap: () => _about(context),
                ),
                const Spacer(),
                const Text(
                  'ВСЕ РАЗМЕРЫ В МИЛЛИМЕТРАХ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textFaint, fontSize: 9.5, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppUi.cardGrad,
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          border: Border.all(color: AppColors.line),
          boxShadow: AppUi.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppUi.goldGrad,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF1A1206)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12.5,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sub,
                    style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _about(BuildContext context) async {
    final v = await UpdateChecker.currentVersion();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          side: const BorderSide(color: AppColors.line),
        ),
        title: const Text(
          'О ПРИЛОЖЕНИИ',
          style: TextStyle(color: AppColors.gold, fontSize: 13, letterSpacing: 2),
        ),
        content: Text(
          'Замерщик окон Almas\nВерсия $v\n\nМастер замера, дерево работ, '
          'чертёж по ГОСТ, смета, история и замерный лист.',
          style: const TextStyle(color: AppColors.textDim, fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ЗАКРЫТЬ', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}
