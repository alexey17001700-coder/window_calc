import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПРЕМИАЛЬНЫЙ СВАЙП-МАСТЕР  ·  v3.0
///  Карточки переключаются свайпом влево/вправо.
///  Каждая карточка занимает не более 50% высоты экрана.
/// ═══════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pc = PageController(viewportFraction: 1.0);
  final TextEditingController _name = TextEditingController();
  final TextEditingController _addr = TextEditingController();
  final TextEditingController _flat = TextEditingController();
  final TextEditingController _floor = TextEditingController();
  late final AnimationController _shine;
  int _page = 0;

  static const _titles = ['ДАННЫЕ КЛИЕНТА', 'ИЗДЕЛИЕ', 'ИТОГ ЗАМЕРА'];
  static const _subs = ['Кому считаем окна', 'Что замеряем', 'Расчёт и отправка'];
  static const _icons = [
    Icons.person_rounded,
    Icons.grid_view_rounded,
    Icons.receipt_long_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4200))
      ..repeat();
  }

  @override
  void dispose() {
    _pc.dispose();
    _shine.dispose();
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
                _progress(),
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
                const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (w, a) => ScaleTransition(
              scale: a,
              child: FadeTransition(opacity: a, child: w),
            ),
            child: Container(
              key: ValueKey(_page),
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
              child: Icon(_icons[_page], color: AppColors.navy900, size: 23),
            ),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    'ШАГ ${_page + 1} ИЗ 3 · ${_titles[_page]}',
                    key: ValueKey('h$_page'),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.gold,
                    ),
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

  // ─────────────────────── ПОЛОСА ПРОГРЕССА ───────────────────────
  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
      child: Row(
        children: List.generate(3, (i) {
          final done = i <= _page;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOut,
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                gradient: done ? AppColors.goldGradient : null,
                color: done ? null : const Color(0xFF16253A),
                borderRadius: BorderRadius.circular(2),
                boxShadow: done
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
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
                colors: [Color(0xFF152740), Color(0xFF0B1524)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.gold.withOpacity(0.30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.50),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.08),
                  blurRadius: 44,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Золотая линия сверху
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.gold,
                          AppColors.bronze,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Пробегающий блик
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (_, __) => CustomPaint(
                        painter: _ShinePainter(_shine.value),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: child,
                ),
              ],
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
        _PremiumField(
          label: 'ИМЯ КЛИЕНТА',
          hint: 'Например: Иванов Иван',
          icon: Icons.person_rounded,
          controller: _name,
        ),
        const SizedBox(height: 13),
        _PremiumField(
          label: 'АДРЕС ОБЪЕКТА',
          hint: 'Улица, дом',
          icon: Icons.location_on_rounded,
          controller: _addr,
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _PremiumField(
                label: 'КВАРТИРА',
                hint: '№',
                icon: Icons.door_front_door_rounded,
                controller: _flat,
                kb: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PremiumField(
                label: 'ЭТАЖ',
                hint: '№',
                icon: Icons.stairs_rounded,
                controller: _floor,
                kb: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _GoldButton('ДАЛЕЕ', Icons.arrow_forward_rounded, _next),
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
        _GoldButton('ДАЛЕЕ', Icons.arrow_forward_rounded, _next),
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
        _GoldButton('ПЕРЕЙТИ В МЕНЮ', Icons.check_rounded, _next),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold.withOpacity(0.22),
                  AppColors.bronze.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.30)),
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
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: Color(0xFF3D5169)),
        ],
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (i) {
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
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.40),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          );
        }),
        const SizedBox(width: 12),
        Text(
          '${_page + 1} / 3',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF5A6E86),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПОЛЕ ВВОДА С ЗОЛОТЫМ СВЕЧЕНИЕМ ПРИ ФОКУСЕ
/// ═══════════════════════════════════════════════════════════════════
class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.kb,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? kb;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final FocusNode _fn = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _fn.addListener(() {
      if (_focused != _fn.hasFocus) setState(() => _focused = _fn.hasFocus);
    });
  }

  @override
  void dispose() {
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(widget.label,
            color: _focused ? AppColors.gold : const Color(0xFF7E93AC),
            size: 9),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused
                  ? AppColors.gold.withOpacity(0.75)
                  : const Color(0xFF1B2C44),
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _fn,
            keyboardType: widget.kb,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF44586F),
              ),
              prefixIcon: Icon(widget.icon, size: 17, color: AppColors.gold),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЗОЛОТАЯ КНОПКА С АНИМАЦИЕЙ НАЖАТИЯ
/// ═══════════════════════════════════════════════════════════════════
class _GoldButton extends StatefulWidget {
  const _GoldButton(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(_down ? 0.20 : 0.38),
                blurRadius: _down ? 12 : 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18, color: AppColors.navy900),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ПРОБЕГАЮЩИЙ БЛИК ПО КАРТОЧКЕ
/// ═══════════════════════════════════════════════════════════════════
class _ShinePainter extends CustomPainter {
  _ShinePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final x = (t * 1.6 - 0.3) * size.width;
    final w = size.width * 0.22;
    final rect = Rect.fromLTWH(x, 0, w, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, 0),
          Offset(x + w, size.height),
          [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.045),
            Colors.white.withOpacity(0.0),
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ShinePainter old) => old.t != t;
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(painter: _BgPainter(_c.value)),
      ),
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
