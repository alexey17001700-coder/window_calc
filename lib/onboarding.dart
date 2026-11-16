import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ СВАЙП-МАСТЕР
///  Карточки переключаются свайпом влево/вправо.
///  Каждая карточка занимает не более 50% высоты экрана.
/// ═══════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController(viewportFraction: 0.90);
  final TextEditingController _name = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _flat = TextEditingController();
  final TextEditingController _floor = TextEditingController();
  int _page = 0;

  static const _titles = ['ДАННЫЕ КЛИЕНТА', 'ИЗДЕЛИЕ', 'ИТОГ ЗАМЕРА'];

  @override
  void dispose() {
    _pc.dispose();
    _name.dispose();
    _addr.dispose();
    _flat.dispose();
    _floor.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= 2) {
      widget.onFinish();
      return;
    }
    _pc.nextPage(
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  void _prev() {
    if (_page <= 0) return;
    _pc.previousPage(
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBg()),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: PageView(
                    controller: _pc,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _cardWrap(h, _cardClient()),
                      _cardWrap(h, _cardProduct()),
                      _cardWrap(h, _cardSummary()),
                    ],
                  ),
                ),
                _dots(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── ШАПКА ───────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.38),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(Icons.window_rounded,
                color: AppColors.navy900, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'НОВЫЙ ЗАМЕР',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ШАГ ${_page + 1} ИЗ 3 · ${_titles[_page]}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          if (_page > 0)
            IconButton(
              onPressed: _prev,
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF7E93AC), size: 20),
            ),
        ],
      ),
    );
  }

  // ───────────────────── ОБЁРТКА КАРТОЧКИ (≤50%) ─────────────────────
  Widget _cardWrap(double screenH, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenH * 0.50),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF13233A), Color(0xFF0C1728)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.gold.withOpacity(0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.07),
                  blurRadius: 40,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── КАРТОЧКА 1: КЛИЕНТ ───────────────────────
  Widget _cardClient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle('ДАННЫЕ КЛИЕНТА', 'Кому считаем окна'),
        const SizedBox(height: 18),
        _field('ИМЯ КЛИЕНТА', 'Например: Иванов Иван', Icons.person_rounded,
            _name),
        const SizedBox(height: 13),
        _field('АДРЕС ОБЪЕКТА', 'Улица, дом', Icons.location_on_rounded, _addr),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _field('КВАРТИРА', '№', Icons.door_front_door_rounded,
                  _flat, kb: TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field('ЭТАЖ', '№', Icons.stairs_rounded, _floor,
                  kb: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _primaryButton('ДАЛЕЕ', Icons.arrow_forward_rounded, _next),
      ],
    );
  }

  // ─────────────────────── КАРТОЧКА 2: ИЗДЕЛИЕ ───────────────────────
  Widget _cardProduct() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle('ИЗДЕЛИЕ', 'Что замеряем'),
        const SizedBox(height: 18),
        _placeholder(
          Icons.grid_view_rounded,
          'ВЫБОР ИЗДЕЛИЯ',
          'Окно, балконный блок, дверь — с размерами и чертежом',
        ),
        const SizedBox(height: 14),
        _placeholder(
          Icons.straighten_rounded,
          'РАЗМЕРЫ',
          'Ширина и высота в мм, деление на створки',
        ),
        const SizedBox(height: 20),
        _primaryButton('ДАЛЕЕ', Icons.arrow_forward_rounded, _next),
      ],
    );
  }

  // ─────────────────────── КАРТОЧКА 3: ИТОГ ───────────────────────
  Widget _cardSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle('ИТОГ ЗАМЕРА', 'Расчёт и отправка'),
        const SizedBox(height: 18),
        _placeholder(
          Icons.receipt_long_rounded,
          'РАСЧЁТ ЦЕНЫ',
          'Стоимость изделий, монтажа, отделки и услуг',
        ),
        const SizedBox(height: 14),
        _placeholder(
          Icons.send_rounded,
          'ОТПРАВКА',
          'На завод, клиенту и дилеру — одним нажатием',
        ),
        const SizedBox(height: 20),
        _primaryButton('ПЕРЕЙТИ В МЕНЮ', Icons.check_rounded, _next),
      ],
    );
  }

  // ─────────────────────────── ЭЛЕМЕНТЫ ───────────────────────────
  Widget _cardTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7E93AC),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController c, {
    TextInputType? kb,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(label, color: const Color(0xFF7E93AC), size: 9),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1B2C44)),
          ),
          child: TextField(
            controller: c,
            keyboardType: kb,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF44586F),
              ),
              prefixIcon: Icon(icon, size: 17, color: AppColors.gold),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2C44)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: Color(0xFF6E819A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy900,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active ? AppColors.goldGradient : null,
            color: active ? null : const Color(0xFF1B2C44),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ ФОН — тёмный градиент, золотые орбы, парящие частицы
/// ═══════════════════════════════════════════════════════════════════
class _PremiumBg extends StatefulWidget {
  const _PremiumBg();

  @override
  State<_PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<_PremiumBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(painter: _BgPainter(_c.value)),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // База — глубокий графитово-синий
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1522), Color(0xFF060C16)],
        ).createShader(rect),
    );

    // Три медленно плывущих орба
    _orb(canvas, size, 0.22, 0.18, 0.55, AppColors.gold, 0.16, 0.0);
    _orb(canvas, size, 0.82, 0.72, 0.62, const Color(0xFF2E6FB8), 0.18, 0.33);
    _orb(canvas, size, 0.50, 0.95, 0.48, AppColors.bronze, 0.12, 0.66);

    // Парящие частицы
    final p = Paint();
    for (var i = 0; i < 46; i++) {
      final seed = i * 7.13;
      final bx = (math.sin(seed) * 0.5 + 0.5);
      final by = (math.cos(seed * 1.7) * 0.5 + 0.5);
      final drift = math.sin(t * math.pi * 2 + seed) * 0.035;
      final x = (bx + drift) * size.width;
      final y = ((by - t * 0.06) % 1.0) * size.height;
      final r = 0.7 + (i % 4) * 0.55;
      final a = 0.10 + (i % 5) * 0.055;
      p.color = (i % 3 == 0 ? AppColors.gold : const Color(0xFF9FB0C6))
          .withOpacity(a);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _orb(Canvas canvas, Size size, double cx, double cy, double r,
      Color color, double alpha, double phase) {
    final ang = t * math.pi * 2 + phase * math.pi * 2;
    final ox = cx + math.sin(ang) * 0.06;
    final oy = cy + math.cos(ang * 0.8) * 0.05;
    final center = Offset(ox * size.width, oy * size.height);
    final radius = r * size.width;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          color.withOpacity(alpha),
          color.withOpacity(0.0),
        ]),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
