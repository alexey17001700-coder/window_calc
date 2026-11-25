import 'package:flutter/material.dart';
import 'theme.dart';
import 'measure_item.dart';
import 'work_tree.dart';
import 'measure_sizes.dart';
import 'window_visual.dart';
import 'price_estimate.dart';
import 'measure_sheet.dart';
import 'measure_media.dart';
import 'measure_history.dart';

/// Обёртка мастера с колбэками навигации (используется заставкой).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.onBack, this.onFinish});

  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Onboarding(onBack: onBack, onFinish: onFinish);
  }
}

/// Мастер замера: 7 шагов.
class Onboarding extends StatefulWidget {
  const Onboarding({
    super.key,
    this.onBack,
    this.onFinish,
  });

  /// Вызывается при выходе с первого шага.
  final VoidCallback? onBack;

  /// Вызывается после сохранения замера — вместо закрытия экрана.
  final VoidCallback? onFinish;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  static const List<String> steps = [
    'КЛИЕНТ',
    'ЧТО ДЕЛАЕМ',
    'РАЗМЕРЫ',
    'ВИЗУАЛЬНЫЙ ЗАМЕР',
    'СМЕТА',
    'ИЗДЕЛИЯ',
    'ЗАМЕРНЫЙ ЛИСТ',
  ];

  int _step = 0;
  final Measure _m = Measure(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    date: DateTime.now().toString().substring(0, 16),
  );
  final List<String> _photos = [];

  final _client = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String _workType = 'НОВОЕ ОКНО';
  String _product = 'ОКНО ПВХ';
  MeasureItem _item = MeasureItem(id: '1', product: 'ОКНО ПВХ');

  void _newItem() {
    _item = MeasureItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      workType: _workType,
      product: _product,
    );
    if (_item.isBalcony) _item.balcony = BalconyBlock();
  }

  void _commitItem() {
    _item.workType = _workType;
    _item.product = _product;
    if (_item.isBalcony && _item.balcony == null) {
      _item.balcony = BalconyBlock();
    }
    final i = _m.items.indexWhere((e) => e.id == _item.id);
    if (i >= 0) {
      _m.items[i] = _item;
    } else {
      _m.items.add(_item);
    }
  }

  void _next() {
    if (_step == 1) _commitItem();
    if (_step == 3) _commitItem();
    if (_step == 5) _commitItem();
    if (_step < steps.length - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      widget.onBack?.call();
    }
  }

  Future<void> _finish() async {
    _m.client = _client.text.trim();
    _m.phone = _phone.text.trim();
    _m.address = _address.text.trim();
    _commitItem();
    await MeasureStore.save(_m);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Замер сохранён в историю')),
    );
    if (widget.onFinish != null) {
      widget.onFinish!.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _client.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        foregroundColor: AppColors.text,
        title: Text(
          steps[_step],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / steps.length,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _body(),
              ),
            ),
            _navBar(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _clientStep();
      case 1:
        return WorkTreeView(
          workType: _workType,
          product: _product,
          onSelect: (w, p) {
            setState(() {
              _workType = w;
              _product = p;
              _newItem();
            });
          },
        );
      case 2:
        return MeasureSizesView(
          item: _item,
          onChanged: () => setState(() {}),
        );
      case 3:
        return WindowVisual(
          item: _item,
          onChanged: () => setState(() {}),
        );
      case 4:
        return EstimateView(items: _m.items.isEmpty ? [_item] : _m.items);
      case 5:
        return _itemsStep();
      default:
        return MeasureSheetView(measure: _m);
    }
  }

  Widget _clientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Клиент'),
        _field('ИМЯ', _client, TextInputType.name),
        const SizedBox(height: 12),
        _field('ТЕЛЕФОН', _phone, TextInputType.phone),
        const SizedBox(height: 12),
        _field('АДРЕС', _address, TextInputType.streetAddress),
        const SizedBox(height: 20),
        MeasureMedia(photos: _photos),
      ],
    );
  }

  Widget _itemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Изделия в замере'),
        ..._m.items.asMap().entries.map((e) {
          final it = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: AppUi.card(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.product,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        it.sizeText,
                        style: const TextStyle(
                          color: AppColors.dim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                  onPressed: () => setState(() => _m.items.removeAt(e.key)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() {
            _commitItem();
            _newItem();
            _step = 1;
          }),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              border: Border.all(color: AppColors.gold),
            ),
            child: const Text(
              '➕ ДОБАВИТЬ ИЗДЕЛИЕ',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUi.label(label),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: type,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppUi.radiusSm),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navBar() {
    final last = _step == steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: GestureDetector(
                onTap: _back,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppUi.radiusSm),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Text(
                    'НАЗАД',
                    style: TextStyle(
                      color: AppColors.dim,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          if (_step > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _next,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppUi.radiusSm),
                ),
                child: Text(
                  last ? '💾 СОХРАНИТЬ' : 'ДАЛЕЕ',
                  style: const TextStyle(
                    color: Color(0xFF1A1206),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
