part of 'measure_sizes.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ПОЛЕ РАЗМЕРА: явный выбор ММ/СМ + живой пересчёт + проверка допуска
/// ═══════════════════════════════════════════════════════════════════
class _SizeField extends StatefulWidget {
  const _SizeField({
    required this.spec,
    required this.controller,
    required this.unit,
    required this.onToggleUnit,
    required this.onChanged,
    this.auto = false,
    this.autoHint = '',
  });

  final SizeSpec spec;
  final TextEditingController controller;

  /// Текущая единица поля: ММ или СМ.
  final String unit;

  /// Значение подставлено АВТОМАТИЧЕСКИ (замерщик его не трогал).
  final bool auto;

  /// Формула АВТО — подсказка под полем.
  final String autoHint;

  /// Переключить единицу (ММ ↔ СМ).
  final VoidCallback onToggleUnit;

  final VoidCallback onChanged;

  @override
  State<_SizeField> createState() => _SizeFieldState();
}

class _SizeFieldState extends State<_SizeField> {
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
    final raw = widget.controller.text;
    final mm = mmFrom(raw, widget.unit);
    final err = sizeError(mm, widget.spec);
    final bad = err != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: bad
                      ? const Color(0xFFE06A6A)
                      : _focused
                          ? AppColors.gold
                          : const Color(0xFF7E93AC),
                ),
              ),
            ),
            if (widget.auto) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(7),
                  border:
                      Border.all(color: AppColors.gold.withOpacity(0.45)),
                ),
                child: const Text(
                  'АВТО',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Переключатель единицы: тап меняет ММ ↔ СМ.
            GestureDetector(
              onTap: widget.onToggleUnit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.gold.withOpacity(0.40)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.swap_horiz_rounded,
                        size: 11, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: bad
                  ? const Color(0xFFE06A6A).withOpacity(0.85)
                  : _focused
                      ? AppColors.gold.withOpacity(0.75)
                      : const Color(0xFF1B2C44),
            ),
            boxShadow: bad
                ? [
                    BoxShadow(
                      color: const Color(0xFFE06A6A).withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : _focused
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _fn,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: AppColors.gold,
            cursorWidth: 1.6,
            onChanged: (_) {
              setState(() {});
              widget.onChanged();
            },
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              // Гасим глобальную заливку темы — фон даёт контейнер.
              filled: false,
              fillColor: Colors.transparent,
              hintText: widget.spec.hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E93AC),
              ),
              suffixText: mm == null ? null : '$mm мм',
              suffixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: bad ? const Color(0xFFE06A6A) : AppColors.gold,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
        if (widget.auto && widget.autoHint.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 11, color: AppColors.gold),
              const SizedBox(width: 5),
              Text(
                widget.autoHint,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
        if (bad) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 12, color: Color(0xFFE06A6A)),
              const SizedBox(width: 5),
              Text(
                err!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFFE06A6A),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
///  ЗОЛОТАЯ КНОПКА
/// ═══════════════════════════════════════════════════════════════════
class _SizeGold extends StatefulWidget {
  const _SizeGold(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SizeGold> createState() => _SizeGoldState();
}

class _SizeGoldState extends State<_SizeGold> {
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
///  ПРОЗРАЧНАЯ КНОПКА «НАЗАД»
/// ═══════════════════════════════════════════════════════════════════
class _SizeGhost extends StatefulWidget {
  const _SizeGhost(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_SizeGhost> createState() => _SizeGhostState();
}

class _SizeGhostState extends State<_SizeGhost> {
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
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1220),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.gold.withOpacity(0.42)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
