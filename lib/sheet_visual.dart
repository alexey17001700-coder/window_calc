import 'dart:math' as math;

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕРТЁЖ ИЗДЕЛИЯ В SVG — для A4-листа замерщика (PDF)
///  Рисуется тем же ГОСТ-стилем, что и на экране: стена, проём,
///  рама двойной линией, створки с обвязкой и стеклом, обозначения
///  Г / П / ПО / О, подпись стеклопакета, размерные линии с числами
///  в ММ. SVG вставляется прямо в HTML — печать в PDF даёт ВЕКТОР,
///  а не растр, поэтому линии остаются тонкими на любом масштабе.
/// ═══════════════════════════════════════════════════════════════════
class SheetVisual {
  static const _ink = '#16233A';
  static const _paper = '#F7F9FC';
  static const _glass = '#D9EAF8';
  static const _ext = '#8FA3BC';
  static const _axis = '#5B6B80';

  /// Буквы обозначений створок по ГОСТ.
  static const List<String> _letters = ['Г', 'П', 'ПО', 'О'];

  /// Доли ширины секций (пусто или не то число — делим поровну).
  static List<double> _norm(int n, List<double> w) {
    if (w.length == n) {
      final s = w.fold<double>(0, (a, b) => a + b);
      if (s > 0) return [for (final v in w) v / s];
    }
    return List<double>.filled(n, 1.0 / n);
  }

  /// SVG-чертёж изделия. Пустая строка — рисовать нечего.
  static String svg({
    required int sashes,
    required List<int> modes,
    required List<double> sectionWidths,
    int widthMm = 0,
    int heightMm = 0,
    String glassLabel = '',
    int glassThk = 0,
  }) {
    final n = sashes.clamp(1, 4);
    final ws = _norm(n, sectionWidths);
    final b = StringBuffer();

    // ── ГЕОМЕТРИЯ ЛИСТА (единицы SVG) ──
    const wallL = 70.0, wallT = 46.0, wallW = 300.0, wallH = 240.0;
    const openL = wallL + 11, openT = wallT + 11;
    const openW = wallW - 22, openH = wallH - 22;
    const fr1L = openL + 5, fr1T = openT + 5;
    const fr1W = openW - 10, fr1H = openH - 10;
    const fr2L = fr1L + 4.5, fr2T = fr1T + 4.5;
    const fr2W = fr1W - 9, fr2H = fr1H - 9;

    b.writeln('<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 440 340" width="100%" '
        'preserveAspectRatio="xMidYMid meet">');

    // ── ЛИСТ ──
    b.writeln('<rect x="0" y="0" width="440" height="340" fill="$_paper" '
        'stroke="#C9D4E2" stroke-width="1" rx="6"/>');

    // ── СТЕНА ──
    b.writeln('<rect x="$wallL" y="$wallT" width="$wallW" height="$wallH" '
        'fill="none" stroke="$_ink" stroke-width="1.2"/>');

    // ── ПРОЁМ ──
    b.writeln('<rect x="$openL" y="$openT" width="$openW" height="$openH" '
        'fill="none" stroke="$_ink" stroke-width="1.3"/>');

    // ── РАМА (двойная линия) ──
    b.writeln('<rect x="$fr1L" y="$fr1T" width="$fr1W" height="$fr1H" '
        'fill="none" stroke="$_ink" stroke-width="1.2"/>');
    b.writeln('<rect x="$fr2L" y="$fr2T" width="$fr2W" height="$fr2H" '
        'fill="none" stroke="$_ink" stroke-width="1"/>');

    // ── ОСЕВЫЕ ЛИНИИ (штрихпунктир) ──
    final cx = openL + openW / 2;
    final cy = openT + openH / 2;
    b.writeln('<line x1="$cx" y1="${wallT - 18}" x2="$cx" '
        'y2="${wallT + wallH + 18}" stroke="$_axis" stroke-width="0.8" '
        'stroke-dasharray="9 3 1.6 3"/>');
    b.writeln('<line x1="${wallL - 18}" y1="$cy" x2="${wallL + wallW + 18}" '
        'y2="$cy" stroke="$_axis" stroke-width="0.8" '
        'stroke-dasharray="9 3 1.6 3"/>');

    // ── УГЛОВЫЕ ВЫНОСКИ 90° ──
    _corner(b, openL, openT, 1, 1);
    _corner(b, openL + openW, openT, -1, 1);
    _corner(b, openL, openT + openH, 1, -1);
    _corner(b, openL + openW, openT + openH, -1, -1);

    // ── СТВОРКИ ──
    var x = fr2L;
    for (var i = 0; i < n; i++) {
      final w = fr2W * ws[i];
      final oL = x + 2.5, oT = fr2T + 2.5, oW = w - 5, oH = fr2H - 5;
      final gL = oL + 3.5, gT = oT + 3.5, gW = oW - 7, gH = oH - 7;

      // обвязка створки
      b.writeln('<rect x="$oL" y="$oT" width="$oW" height="$oH" '
          'fill="none" stroke="$_ink" stroke-width="1.1"/>');
      // стеклопакет
      b.writeln('<rect x="$gL" y="$gT" width="$gW" height="$gH" '
          'fill="$_glass" stroke="$_ink" stroke-width="0.9"/>');

      // плюсик в центре стекла
      final d = math.min(gW, gH) * 0.22;
      final gcx = gL + gW / 2, gcy = gT + gH / 2;
      if (d >= 3) {
        b.writeln('<line x1="${gcx - d}" y1="$gcy" x2="${gcx + d}" '
            'y2="$gcy" stroke="$_ink" stroke-width="0.9"/>');
        b.writeln('<line x1="$gcx" y1="${gcy - d}" x2="$gcx" '
            'y2="${gcy + d}" stroke="$_ink" stroke-width="0.9"/>');
      }

      // буква створки по ГОСТ — в левом верхнем углу стекла
      final mode = i < modes.length ? modes[i].clamp(0, 3) : 0;
      _chip(b, gL + 4, gT + 4, 21, 15, _letters[mode], 11);

      // подпись стеклопакета — в правом верхнем углу стекла
      if (glassLabel.isNotEmpty) {
        final mark = glassThk > 0 ? '$glassLabel · $glassThk' : glassLabel;
        _chipRight(b, gL + gW - 4, gT + 4, mark);
      }

      x += w;
    }

    // ── РАЗМЕР: ГАБАРИТ ПО ШИРИНЕ (сверху) ──
    final dimTop = wallT - 15;
    _dimH(b, openL, openL + openW, dimTop,
        widthMm > 0 ? '$widthMm' : '?');
    _extV(b, openL, openT, dimTop);
    _extV(b, openL + openW, openT, dimTop);

    // ── РАЗМЕР: ГАБАРИТ ПО ВЫСОТЕ (слева) ──
    final dimLeft = wallL - 17;
    _dimV(b, openT, openT + openH, dimLeft,
        heightMm > 0 ? '$heightMm' : '?');
    _extH(b, openT, openL, dimLeft);
    _extH(b, openT + openH, openL, dimLeft);

    // ── РАЗМЕРЫ ПО СЕКЦИЯМ (снизу) ──
    if (n > 1) {
      final y = wallT + wallH + 17;
      var sx = fr2L;
      for (var i = 0; i < n; i++) {
        final w = fr2W * ws[i];
        _dimH(b, sx, sx + w, y,
            widthMm > 0 ? '${(widthMm * ws[i]).round()}' : '?',
            small: true, below: true);
        _extV(b, sx, openT + openH, y);
        sx += w;
      }
      _extV(b, sx, openT + openH, y);
    }

    // ── ПОДПИСЬ ЛИСТА ──
    b.writeln('<text x="$wallL" y="334" font-family="Arial" font-size="8" '
        'font-weight="700" fill="#7E93AC">РАЗМЕРЫ В ММ</text>');

    b.writeln('</svg>');
    return b.toString();
  }

  // ─────────────── УГЛОВАЯ ВЫНОСКА 90° ───────────────
  static void _corner(StringBuffer b, double x, double y, int sx, int sy) {
    b.writeln('<line x1="$x" y1="$y" x2="${x + sx * 9}" y2="$y" '
        'stroke="$_ink" stroke-width="0.9"/>');
    b.writeln('<line x1="$x" y1="$y" x2="$x" y2="${y + sy * 9}" '
        'stroke="$_ink" stroke-width="0.9"/>');
  }

  // ─────────────── ПЛАШКА С БУКВОЙ СТВОРКИ ───────────────
  static void _chip(StringBuffer b, double x, double y, double w, double h,
      String text, double size) {
    b.writeln('<rect x="$x" y="$y" width="$w" height="$h" fill="$_paper" '
        'stroke="$_ink" stroke-width="1"/>');
    b.writeln('<text x="${x + w / 2}" y="${y + h / 2 + size * 0.36}" '
        'text-anchor="middle" font-family="Arial" font-size="$size" '
        'font-weight="900" fill="$_ink">$text</text>');
  }

  // ─────────────── ПЛАШКА СТЕКЛОПАКЕТА (справа) ───────────────
  static void _chipRight(StringBuffer b, double rightX, double y, String text) {
    final w = text.length * 4.3 + 7;
    final x = rightX - w;
    b.writeln('<rect x="$x" y="$y" width="$w" height="12" fill="$_paper" '
        'stroke="$_ink" stroke-width="0.7"/>');
    b.writeln('<text x="${rightX - 3.5}" y="${y + 9}" text-anchor="end" '
        'font-family="Arial" font-size="7" font-weight="800" '
        'fill="$_ink">$text</text>');
  }

  // ─────────────── РАЗМЕР ПО ГОРИЗОНТАЛИ ───────────────
  static void _dimH(StringBuffer b, double x1, double x2, double y,
      String label,
      {bool small = false, bool below = false}) {
    b.writeln('<line x1="$x1" y1="$y" x2="$x2" y2="$y" '
        'stroke="$_ink" stroke-width="0.9"/>');
    b.writeln('<line x1="$x1" y1="${y - 4}" x2="$x1" y2="${y + 4}" '
        'stroke="$_ink" stroke-width="0.9"/>');
    b.writeln('<line x1="$x2" y1="${y - 4}" x2="$x2" y2="${y + 4}" '
        'stroke="$_ink" stroke-width="0.9"/>');
    _arrow(b, x1, y, -1);
    _arrow(b, x2, y, 1);
    final ty = y + (below ? 12 : -6);
    b.writeln('<text x="${(x1 + x2) / 2}" y="$ty" text-anchor="middle" '
        'font-family="Arial" font-size="${small ? 8 : 10}" '
        'font-weight="700" fill="$_ink">$label</text>');
  }

  // ─────────────── РАЗМЕР ПО ВЕРТИКАЛИ ───────────────
  static void _dimV(StringBuffer b, double y1, double y2, double x,
      String label,
      {bool small = false}) {
    b.writeln('<line x1="$x" y1="$y1" x2="$x" y2="$y2" '
        'stroke="$_ink" stroke-width="0.9"/>');
    b.writeln('<line x1="${x - 4}" y1="$y1" x2="${x + 4}" y2="$y1" '
        'stroke="$_ink" stroke-width="0.9"/>');
    b.writeln('<line x1="${x - 4}" y1="$y2" x2="${x + 4}" y2="$y2" '
        'stroke="$_ink" stroke-width="0.9"/>');
    _arrowV(b, x, y1, -1);
    _arrowV(b, x, y2, 1);
    final ty = (y1 + y2) / 2;
    b.writeln('<text x="${x - 6}" y="$ty" text-anchor="middle" '
        'transform="rotate(-90 ${x - 6} $ty)" font-family="Arial" '
        'font-size="${small ? 8 : 10}" font-weight="700" '
        'fill="$_ink">$label</text>');
  }

  // ─────────────── ВЫНОСНЫЕ ЛИНИИ ───────────────
  static void _extV(StringBuffer b, double x, double fromY, double toY) {
    final dir = toY < fromY ? -1.0 : 1.0;
    b.writeln('<line x1="$x" y1="$fromY" x2="$x" y2="${toY + dir * 3}" '
        'stroke="$_ext" stroke-width="0.7"/>');
  }

  static void _extH(StringBuffer b, double y, double fromX, double toX) {
    final dir = toX < fromX ? -1.0 : 1.0;
    b.writeln('<line x1="$fromX" y1="$y" x2="${toX + dir * 3}" y2="$y" '
        'stroke="$_ext" stroke-width="0.7"/>');
  }

  // ─────────────── СТРЕЛКИ ───────────────
  static void _arrow(StringBuffer b, double x, double y, int dir) {
    b.writeln('<polygon points="$x,$y ${x + dir * 7},${y - 2.6} '
        '${x + dir * 7},${y + 2.6}" fill="$_ink"/>');
  }

  static void _arrowV(StringBuffer b, double x, double y, int dir) {
    b.writeln('<polygon points="$x,$y ${x - 2.6},${y + dir * 7} '
        '${x + 2.6},${y + dir * 7}" fill="$_ink"/>');
  }
}
