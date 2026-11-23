import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Мастер замера. ЭТАП 1 — шаг «ДАННЫЕ КЛИЕНТА».
/// Дерево работ, размеры, чертёж, смета и замерный лист добавляются
/// на следующих этапах восстановления.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onBack, this.onFinish});

  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _addr = TextEditingController();
  final _flat = TextEditingController();
  final _floor = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _addr.dispose();
    _flat.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    child: _clientCard(),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 6),
      child: Row(
        children: [
          _RoundButton(icon: Icons.arrow_back_rounded, onTap: widget.onBack),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'НОВЫЙ ЗАМЕР',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'ДАННЫЕ КЛИЕНТА',
                style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppUi.cardGrad,
        borderRadius: BorderRadius.circular(AppUi.radius),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
        boxShadow: AppUi.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppUi.radius),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.gold, Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PremiumField(
                    label: 'ИМЯ КЛИЕНТА',
                    hint: 'Иван Петров',
                    icon: Icons.person_rounded,
                    controller: _name,
                  ),
                  const SizedBox(height: 14),
                  _PremiumField(
                    label: 'НОМЕР ТЕЛЕФОНА',
                    hint: '+7 900 000-00-00',
                    icon: Icons.phone_rounded,
                    controller: _phone,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _PremiumField(
                    label: 'АДРЕС ОБЪЕКТА',
                    hint: 'ул. Ленина, 15',
                    icon: Icons.location_on_rounded,
                    controller: _addr,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PremiumField(
                          label: 'КВАРТИРА',
                          hint: '24',
                          icon: Icons.meeting_room_rounded,
                          controller: _flat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PremiumField(
                          label: 'ЭТАЖ',
                          hint: '5',
                          icon: Icons.stairs_rounded,
                          controller: _floor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _GoldButton(
                    label: 'ДАЛЕЕ',
                    icon: Icons.arrow_forward_rounded,
                    onTap: widget.onFinish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Премиальный фон ──────────────────────────────────────────────────────────

class _PremiumBg extends StatefulWidget {
  const _PremiumBg();

  @override
  State<_PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<_PremiumBg> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
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
        builder: (_, __) => CustomPaint(
          painter: _BgPainter(_c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;

  const _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = AppUi.bgGrad.createShader(rect),
    );

    // три медленно плывущих орба
    final orbs = <List<dynamic>>[
      [AppColors.gold, 0.30, 0.22, 0.34, 0.16],
      [const Color(0xFF3E7BB8), 0.72, 0.30, 0.40, 0.13],
      [const Color(0xFF8A6A2A), 0.45, 0.78, 0.36, 0.11],
    ];
    for (var i = 0; i < orbs.length; i++) {
      final o = orbs[i];
      final col = o[0] as Color;
      final bx = o[1] as double;
      final by = o[2] as double;
      final br = o[3] as double;
      final ba = o[4] as double;
      final a = t * math.pi * 2 + i * 2.1;
      final cx = size.width * (bx + 0.05 * math.cos(a));
      final cy = size.height * (by + 0.04 * math.sin(a));
      final r = size.shortestSide * br;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(ba), col.withOpacity(0.0)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // парящие частицы
    final rnd = math.Random(7);
    for (var i = 0; i < 46; i++) {
      final px = rnd.nextDouble() * size.width;
      final base = rnd.nextDouble() * size.height;
      final spd = 0.4 + rnd.nextDouble() * 1.2;
      final py = (base - t * size.height * spd) % size.height;
      final rr = 0.6 + rnd.nextDouble() * 1.5;
      canvas.drawCircle(
        Offset(px, py),
        rr,
        Paint()..color = AppColors.goldLight.withOpacity(0.10 + rnd.nextDouble() * 0.14),
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ── Поля и кнопки ────────────────────────────────────────────────────────────

class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboard,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focus = FocusNode();
  bool _on = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _on = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navy900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppUi.radiusSm),
        border: Border.all(
          color: _on ? AppColors.gold.withOpacity(0.75) : AppColors.line,
        ),
        boxShadow: _on
            ? [BoxShadow(color: AppColors.gold.withOpacity(0.20), blurRadius: 18)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 13, color: _on ? AppColors.gold : AppColors.textDim),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _on ? AppColors.gold : AppColors.textDim,
                  fontSize: 9,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboard,
            cursorColor: AppColors.gold,
            cursorWidth: 1.6,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 2),
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF7E93AC), fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatefulWidget {
  const _GoldButton({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapCancel: on ? () => setState(() => _down = false) : null,
      onTapUp: on
          ? (_) {
              setState(() => _down = false);
              widget.onTap!.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: on ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: AppUi.buttonH,
            decoration: BoxDecoration(
              gradient: AppUi.goldGrad,
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              boxShadow: _down
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF1A1206),
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(widget.icon, size: 18, color: const Color(0xFF1A1206)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy800.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold.withOpacity(0.45)),
        ),
        child: Icon(icon, size: 19, color: AppColors.gold),
      ),
    );
  }
}
