import 'package:flutter/material.dart';
import 'theme.dart';
import 'premium_bg.dart';
import 'onboarding.dart';
import 'measure_history.dart';
import 'update_checker.dart';

/// Главное меню приложения.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onToggleTheme});

  /// Переключение светлой/тёмной темы (передаётся из заставки).
  final Future<void> Function()? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PremiumBg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Color(0xFF1A1206),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALMAS',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'ЗАМЕРЩИК ОКОН',
                          style: TextStyle(
                            color: AppColors.dim,
                            fontSize: 11,
                            letterSpacing: 2.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                _tile(
                  context,
                  icon: Icons.add_box_outlined,
                  title: 'НОВЫЙ ЗАМЕР',
                  subtitle: 'Клиент, размеры, балконный блок, смета',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Onboarding()),
                  ),
                ),
                const SizedBox(height: 12),
                _tile(
                  context,
                  icon: Icons.history,
                  title: 'ИСТОРИЯ',
                  subtitle: 'Сохранённые замеры на устройстве',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _HistoryPage()),
                  ),
                ),
                const Spacer(),
                const UpdateTile(),
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
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppUi.card(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, color: AppColors.gold, size: 24),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.dim, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.dim),
          ],
        ),
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  const _HistoryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        foregroundColor: AppColors.text,
        title: const Text(
          'ИСТОРИЯ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: const HistoryView(),
    );
  }
}
