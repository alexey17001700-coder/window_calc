import 'package:flutter/material.dart';

import 'measure_history.dart';
import 'onboarding.dart';
import 'premium_bg.dart';
import 'theme.dart';

/// Главное меню приложения.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: PremiumBg()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      _tile(
                        context,
                        'НОВЫЙ ЗАМЕР',
                        'Обмер объекта и замерный лист',
                        Icons.add_box_outlined,
                      ),
                      _tile(
                        context,
                        'ИСТОРИЯ',
                        'Прошлые замеры и база клиентов',
                        Icons.history_rounded,
                      ),
                      _tile(
                        context,
                        'ПРАЙС',
                        'Стоимость изделий и работ',
                        Icons.calculate_rounded,
                      ),
                      _tile(
                        context,
                        'НАСТРОЙКИ',
                        'Сервер, обновления приложения',
                        Icons.settings_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldLight, AppColors.goldDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.28),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(Icons.window_rounded,
                color: AppColors.navy900, size: 21),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ЗАМЕРЩИК ОКОН',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'ALMAS · ГЛАВНОЕ МЕНЮ',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppUi.radiusLg),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title · РАЗДЕЛ ГОТОВИТСЯ')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppUi.radiusLg),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.card, AppColors.navy700],
              ),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 10)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: AppColors.gold.withOpacity(0.12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 21),
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
                          fontSize: 13,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.gold, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
