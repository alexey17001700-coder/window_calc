import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

part 'visual/geo.dart';
part 'visual/painter.dart';

/// Обозначения створок по ГОСТ: Г · П · ПО · О.
const kSashModeNames = <String>[
  'ГЛУХАЯ',
  'ПОВОРОТНАЯ',
  'ПОВОРОТНО-ОТКИДНАЯ',
  'ОТКИДНАЯ',
];

const kSashModeLetter = <String>['Г', 'П', 'ПО', 'О'];

const kSashModeShort = <String>[
  'Г · ГЛУХАЯ',
  'П · ПОВОР.',
  'ПО · ПОВ.-ОТКИД.',
  'О · ОТКИД.',
];

/// Чертёж изделия по ГОСТ. Обычное окно либо балконный блок.
class WindowVisual extends StatefulWidget {
  const WindowVisual({
    super.key,
    this.sashCount = 2,
    this.modes = const <int>[],
    this.sectionWidths = const <double>[],
    this.widthMm = 0,
    this.heightMm = 0,
    this.arched = false,
    this.parts = const <String>[],
    this.balconyBlock = false,
    this.doorMode = 1,
    this.fixedMode = 0,
    this.doorWidthMm = 600,
    this.doorHeightMm = 2100,
    this.fixedWidthMm = 600,
    this.fixedHeightMm = 500,
    this.fixedRight = true,
    this.onSashTap,
    this.onBalconyTap,
    this.onBalconyEdit,
  });

  /// Число секций обычного окна (1…4).
  final int sashCount;

  /// Обозначения секций по ГОСТ (индексы kSashModeNames).
  final List<int> modes;

  /// Доли ширины секций (сумма ≈ 1.0). Пусто — делим поровну.
  final List<double> sectionWidths;

  final int widthMm;
  final int heightMm;
  final bool arched;

  /// Комплектация: «С ПОДОКОННИКОМ», «С ОТЛИВОМ», «С ОТКОСАМИ».
  final List<String> parts;

  /// Балконный блок: дверь + боковая колонна (глухняк + сэндвич-панель).
  final bool balconyBlock;
  final int doorMode;
  final int fixedMode;
  final int doorWidthMm;
  final int doorHeightMm;
  final int fixedWidthMm;
  final int fixedHeightMm;

  /// Глухняк справа от двери (по умолчанию) либо слева.
  final bool fixedRight;

  /// Тап по секции обычного окна.
  final ValueChanged<int>? onSashTap;

  /// Тап по двери (0) или глухняку (1) балконного блока.
  final ValueChanged<int>? onBalconyTap;

  /// Тап по размерной линии блока: 'doorW' · 'doorH' · 'fixedW' · 'fixedH'.
  final void Function(String field)? onBalconyEdit;

  @override
  State<WindowVisual> createState() => _WindowVisualState();
}

class _WindowVisualState extends State<WindowVisual> {
  int _sel = -1;

  int _modeAt(int i) {
    if (widget.modes.isEmpty) return 0;
    return widget.modes[i % widget.modes.length].clamp(0, 3);
  }

  String get _title {
    if (widget.balconyBlock) {
      return 'БАЛКОННЫЙ БЛОК · ДВЕРЬ + ГЛУХНЯК';
    }
    if (_sel >= 0) {
      return 'СЕКЦИЯ ${_sel + 1} · ${kSashModeNames[_modeAt(_sel)]}';
    }
    return 'ЧЕРТЁЖ ПО ГОСТ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: widget.balconyBlock
              ? 1.05
              : (widget.arched ? 0.95 : 1.30),
          child: LayoutBuilder(
            builder: (context, c) {
              final size = Size(c.maxWidth, c.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _tap(d.localPosition, size),
                child: CustomPaint(
                  size: size,
                  painter: _GostPainter(
                    sashCount: widget.sashCount,
                    modes: List<int>.generate(widget.sashCount, _modeAt),
                    sectionWidths: widget.sectionWidths,
                    widthMm: widget.widthMm,
                    heightMm: widget.heightMm,
                    arched: widget.arched,
                    parts: widget.parts,
                    selected: _sel,
                    balconyBlock: widget.balconyBlock,
                    doorMode: widget.doorMode.clamp(0, 3),
                    fixedMode: widget.fixedMode.clamp(0, 3),
                    doorWidthMm: widget.doorWidthMm,
                    doorHeightMm: widget.doorHeightMm,
                    fixedWidthMm: widget.fixedWidthMm,
                    fixedHeightMm: widget.fixedHeightMm,
                    fixedRight: widget.fixedRight,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _chips(),
        const SizedBox(height: 6),
        Text(
          widget.balconyBlock
              ? 'ТАП ПО ДВЕРИ ИЛИ ГЛУХНЯКУ — СМЕНА ОБОЗНАЧЕНИЯ'
              : 'ТАП ПО СТВОРКЕ — СМЕНА ОБОЗНАЧЕНИЯ ПО ГОСТ',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textDim,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  void _tap(Offset p, Size size) {
    if (widget.balconyBlock) {
      final geo = _balconyGeo(
        size,
        doorW: widget.doorWidthMm,
        doorH: widget.doorHeightMm,
        fixedW: widget.fixedWidthMm,
        fixedH: widget.fixedHeightMm,
        fixedRight: widget.fixedRight,
      );
      if (geo.door.contains(p)) {
        HapticFeedback.selectionClick();
        widget.onBalconyTap?.call(0);
        return;
      }
      if (geo.fixed.contains(p)) {
        HapticFeedback.selectionClick();
        widget.onBalconyTap?.call(1);
        return;
      }
      return;
    }

    final geo = _geo(size, arched: widget.arched, parts: widget.parts);
    final widths = _normWidths(widget.sashCount, widget.sectionWidths);
    final rects = _sashRects(geo.frame, widths);
    for (var i = 0; i < rects.length; i++) {
      if (rects[i].contains(p)) {
        setState(() => _sel = i);
        HapticFeedback.selectionClick();
        widget.onSashTap?.call(i);
        return;
      }
    }
  }

  Widget _chips() {
    if (widget.balconyBlock) {
      return Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          _chip(
            'ДВЕРЬ · ${kSashModeShort[widget.doorMode.clamp(0, 3)]}',
            () => widget.onBalconyTap?.call(0),
          ),
          _chip(
            'ГЛУХНЯК · ${kSashModeShort[widget.fixedMode.clamp(0, 3)]}',
            () => widget.onBalconyTap?.call(1),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(widget.sashCount, (i) {
        return _chip('${i + 1} · ${kSashModeShort[_modeAt(i)]}', () {
          setState(() => _sel = i);
          widget.onSashTap?.call(i);
        });
      }),
    );
  }

  Widget _chip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.navy800,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
