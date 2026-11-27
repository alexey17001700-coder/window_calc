import 'package:flutter/material.dart';

import 'theme.dart';
import 'screen_flash.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ШАГ «СМЕТА»  ·  v3.4.27
///  Прайс + автоматический расчёт стоимости замера.
///  Считаем по площади изделия (м²), погонным метрам (м.п.)
///  и площади обработки. Все цены — в одном месте, в классе PriceBook.
///  Поменять прайс можно здесь, больше нигде править не нужно.
/// ═══════════════════════════════════════════════════════════════════

/// Валюта сметы. Для тенге поставь '₸'.
const String kCurrency = '₽';

/// ПРАЙС. Единственное место, где живут цены.
class PriceBook {
  /// Базовая цена изделия за м² по типу окна.
  static const Map<String, double> windowPerM2 = {
    'ОДНОСТВОРЧАТОЕ': 13000,
    'ДВУХСТВОРЧАТОЕ': 14500,
    'ТРЁХСТВОРЧАТОЕ': 15500,
    'ФИГУРНОЕ': 13000,
    'БАЛКОННЫЙ БЛОК': 15000,
  };

  /// Если тип окна неизвестен — считаем по этой цене.
  static const double windowDefaultPerM2 = 13000;

  /// Надбавка за фигурное изделие (арка, абрис, радиус), доля от изделия.
  static const double figuredMarkup = 0.35;

  /// Надбавка за стеклопакет, ₽/м² (двухкамерный — база, надбавка 0).
  static const double glassDouble = 0;
  static const double glassEnergy = 1800;
  static const double glassMulti = 2400;
  static const double glassSun = 2200;

  /// Надбавка за ТОЛЩИНУ ПРОФИЛЯ (рамы), ₽/м².
  /// 60 мм — стандарт (надбавки нет), 70 мм — тёплый профиль.
  static const double profile60PerM2 = 0;
  static const double profile70PerM2 = 1200;

  /// Надбавка за НАЗВАНИЕ ПРОФИЛЯ (марку), ₽/м².
  /// Пока ЗАГЛУШКА — пусто, надбавок нет. Цены задаст Босс позже.
  static const Map<String, double> brandPerM2 = {};

  /// Комплектация.
  static const double sillPerM = 1400; // подоконник, ₽/м.п.
  static const double ebbPerM = 1200; // отлив, ₽/м.п.
  static const double slopePerM = 900; // откосы, ₽/м.п.
  static const double psuPerM = 250; // ПСУЛ, ₽/м.п.
  static const double strippingPerM2 = 400; // отмазка, ₽/м² (одна сторона)

  /// Монтаж и доставка.
  static const double installPerM2 = 2500;
  static const double installMin = 3500;
  static const double delivery = 1500;
}

/// Одна позиция сметы.
class EstimateLine {
  const EstimateLine(this.title, this.qty, this.unit, this.price);

  /// Название позиции.
  final String title;

  /// Количество (м², м.п., шт).
  final double qty;

  /// Единица: м², м.п., шт.
  final String unit;

  /// Цена за единицу.
  final double price;

  /// Сумма по позиции.
  double get sum => _round2(qty * price);
}

/// Готовая смета.
class Estimate {
  const Estimate({
    required this.widthMm,
    required this.heightMm,
    required this.lines,
  });

  final int widthMm;
  final int heightMm;
  final List<EstimateLine> lines;

  /// Площадь изделия в м².
  double get areaM2 => _round2(widthMm * heightMm / 1000000);

  /// Итог сметы.
  double get total => _round2(lines.fold(0.0, (a, l) => a + l.sum));

  /// Есть ли что считать.
  bool get isEmpty => widthMm <= 0 || heightMm <= 0 || lines.isEmpty;
}

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// Надбавка за стеклопакет по его названию, ₽/м².
double glassPerM2(String glass) {
  final g = glass.toLowerCase();
  if (g.contains('мульти')) return PriceBook.glassMulti;
  if (g.contains('солнц') || g.contains('тонир') || g.contains('sun')) {
    return PriceBook.glassSun;
  }
  if (g.contains('энерг') || g.contains('тепл') || g.contains('i-стек')) {
    return PriceBook.glassEnergy;
  }
  return PriceBook.glassDouble;
}

/// Цена изделия за м² по названию типа из дерева.
/// Устойчиво к формулировкам: «ДВУХСТВОРЧАТОЕ», «ДВУХСТВОРЧАТЫЙ» и т.п.
double windowPerM2For(String type) {
  final t = type.toUpperCase();
  if (t.contains('ТРЁХСТВ') || t.contains('ТРЕХСТВ')) return 15500;
  if (t.contains('ДВУХСТВ') || t.contains('ДВУСТВ')) return 14500;
  if (t.contains('ОДНОСТВ')) return 13000;
  if (t.contains('ФИГУРН')) return 13000;
  if (t.contains('БАЛКОННЫЙ БЛОК')) return 15000;
  if (t.contains('ДВЕРЬ')) return 16000;
  if (t.contains('ФАСАД') || t.contains('ВИТРАЖ') || t.contains('ПАНОРАМ')) {
    return 17000;
  }
  if (t.contains('ЛОДЖИЯ') || t.contains('БАЛКОН')) return 14000;
  return PriceBook.windowDefaultPerM2;
}

/// Собрать смету из данных замера.
/// Размеры — в МИЛЛИМЕТРАХ, как их отдаёт шаг «РАЗМЕРЫ».
Estimate buildEstimate({
  required int widthMm,
  required int heightMm,
  required String windowType,
  required List<String> parts,
  required String glass,
  String profile = '',
}) {
  final lines = <EstimateLine>[];

  final w = widthMm / 1000.0; // м
  final h = heightMm / 1000.0; // м
  final area = _round2(w * h);
  final perim = _round2(2 * (w + h));

  if (area > 0) {
    // ── Изделие ───────────────────────────────────────────────
    final base = windowPerM2For(windowType);
    var perM2 = base + glassPerM2(glass);
    final figured =
        windowType.toUpperCase().contains('ФИГУРН') || parts.contains('АБРИС');
    if (figured) perM2 *= 1 + PriceBook.figuredMarkup;

    lines.add(EstimateLine(
      figured ? 'Изделие · $windowType · фигурное' : 'Изделие · $windowType',
      area,
      'м²',
      _round2(perM2),
    ));

    // ── Толщина профиля (рамы): 70 мм — тёплый, надбавка ──
    if (profile.contains('70')) {
      lines.add(EstimateLine(
        'Профиль 70 мм · тёплый',
        area,
        'м²',
        PriceBook.profile70PerM2,
      ));
    }

    // ── Комплектация ──────────────────────────────────────────
    for (final p in parts) {
      switch (p) {
        case 'С ОТЛИВОМ':
          lines.add(EstimateLine('Отлив', w, 'м.п.', PriceBook.ebbPerM));
          break;
        case 'С ПОДОКОННИКОМ':
          lines.add(EstimateLine('Подоконник', w, 'м.п.', PriceBook.sillPerM));
          break;
        case 'С ОТКОСАМИ':
          lines.add(EstimateLine('Откосы (периметр)', perim, 'м.п.',
              PriceBook.slopePerM));
          break;
        case 'ПСУЛ':
          lines.add(EstimateLine('ПСУЛ', perim, 'м.п.', PriceBook.psuPerM));
          break;
        case 'ОТМАЗКА':
          lines.add(
              EstimateLine('Отмазка, 1 сторона', area, 'м²', PriceBook.strippingPerM2));
          break;
        case 'ОТМАЗКА С ДВУХ СТОРОН':
          lines.add(EstimateLine('Отмазка, 2 стороны', area, 'м²',
              PriceBook.strippingPerM2 * 2));
          break;
        default:
          break;
      }
    }

    // ── Монтаж и доставка ────────────────────────────────────
    final install = _round2(area * PriceBook.installPerM2);
    lines.add(EstimateLine(
      'Монтаж',
      1,
      'шт',
      install < PriceBook.installMin ? PriceBook.installMin : install,
    ));
    lines.add(EstimateLine('Доставка', 1, 'шт', PriceBook.delivery));
  }

  return Estimate(widthMm: widthMm, heightMm: heightMm, lines: lines);
}

/// Деньги: 12 500 ₽ (без копеек, с пробелами по тысячам).
String money(num v) {
  final neg = v < 0;
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}$b $kCurrency';
}

/// Количество: целое без дробей, иначе два знака через запятую.
String _qty(double v) {
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(2).replaceAll('.', ',');
}

/// ═══════════════════════════════════════════════════════════════════
///  ЭКРАН СМЕТЫ: площадь, позиции, итог
/// ═══════════════════════════════════════════════════════════════════
class EstimateView extends StatelessWidget {
  const EstimateView({
    super.key,
    required this.estimate,
    required this.onBack,
    required this.onNext,
  });

  final Estimate estimate;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final empty = estimate.isEmpty;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _head(),
                const SizedBox(height: 12),
                _card(empty),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _EsGhost('НАЗАД', Icons.arrow_back_rounded, onBack),
              const SizedBox(width: 12),
              Expanded(
                child: _EsGold(
                  'ЗАМЕРНЫЙ ЛИСТ',
                  Icons.receipt_long_rounded,
                  empty ? null : onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _head() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              estimate.isEmpty
                  ? 'НЕТ РАЗМЕРОВ'
                  : '${estimate.widthMm} × ${estimate.heightMm} ММ  ·  '
                      '${estimate.areaM2.toStringAsFixed(2).replaceAll('.', ',')} М²',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(bool empty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152740), Color(0xFF0B1524)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.request_quote_rounded,
                    size: 19, color: AppColors.navy900),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'СМЕТА',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      empty ? 'ВВЕДИ РАЗМЕРЫ НА ШАГЕ «РАЗМЕРЫ»' : 'ЦЕНЫ СПРАВОЧНЫЕ',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: empty
                            ? const Color(0xFFE06A6A)
                            : AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!empty) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: const Color(0xFF1B2C44)),
            const SizedBox(height: 6),
            for (final l in estimate.lines) _line(l),
            Container(height: 1, color: const Color(0xFF1B2C44)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ИТОГО',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  money(estimate.total),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(EstimateLine l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_qty(l.qty)} ${l.unit} × ${money(l.price)}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Color(0xFF7E93AC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            money(l.sum),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Золотая кнопка шага сметы.
class _EsGold extends StatefulWidget {
  const _EsGold(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_EsGold> createState() => _EsGoldState();
}

class _EsGoldState extends State<_EsGold> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final off = widget.onTap == null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: off ? 0.45 : 1.0,
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
      ),
    );
  }
}

/// Прозрачная кнопка «НАЗАД» шага сметы.
class _EsGhost extends StatefulWidget {
  const _EsGhost(this.text, this.icon, this.onTap);
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_EsGhost> createState() => _EsGhostState();
}

class _EsGhostState extends State<_EsGhost> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        flashScreen();
        widget.onTap();
      },
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