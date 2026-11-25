import 'dart:convert';

/// Балконный блок: дверь (на всю высоту) + глухняк сверху сбоку + сэндвич-панель.
class BalconyBlock {
  BalconyBlock({
    this.doorW = 600,
    this.doorH = 2100,
    this.fixedW = 600,
    this.fixedH = 500,
    this.doorMode = 'П',
    this.fixedMode = 'Г',
    this.doorLeft = true,
  });

  int doorW; // ширина двери, мм
  int doorH; // высота двери, мм
  int fixedW; // ширина глухняка, мм
  int fixedH; // высота глухняка, мм
  String doorMode; // Г / П / ПО / О
  String fixedMode; // Г / П / ПО / О
  bool doorLeft; // дверь слева

  int get width => doorW + fixedW;
  int get height => doorH;
  int get panelMm => (doorH - fixedH).clamp(0, 20000);
  double get area => width * height / 1000000.0;
  String get sizeText => '$width × $height мм';
  String get sideText => doorLeft ? 'ДВЕРЬ СЛЕВА' : 'ДВЕРЬ СПРАВА';

  void reset() {
    doorW = 600;
    doorH = 2100;
    fixedW = 600;
    fixedH = 500;
    doorMode = 'П';
    fixedMode = 'Г';
    doorLeft = true;
  }

  BalconyBlock copy() => BalconyBlock(
        doorW: doorW,
        doorH: doorH,
        fixedW: fixedW,
        fixedH: fixedH,
        doorMode: doorMode,
        fixedMode: fixedMode,
        doorLeft: doorLeft,
      );

  Map<String, dynamic> toJson() => {
        'doorW': doorW,
        'doorH': doorH,
        'fixedW': fixedW,
        'fixedH': fixedH,
        'doorMode': doorMode,
        'fixedMode': fixedMode,
        'doorLeft': doorLeft,
      };

  factory BalconyBlock.fromJson(Map<String, dynamic> j) {
    int i(String k, int d) {
      final v = j[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? d;
      return d;
    }

    return BalconyBlock(
      doorW: i('doorW', 600),
      doorH: i('doorH', 2100),
      fixedW: i('fixedW', 600),
      fixedH: i('fixedH', 500),
      doorMode: (j['doorMode'] ?? 'П').toString(),
      fixedMode: (j['fixedMode'] ?? 'Г').toString(),
      doorLeft: j['doorLeft'] is bool ? j['doorLeft'] as bool : true,
    );
  }
}

/// Одно изделие замера целиком.
class MeasureItem {
  MeasureItem({
    this.path = const [],
    this.multi = const [],
    this.sizes = const {},
    this.glass = '',
    this.widthMm = 0,
    this.heightMm = 0,
    this.sashModes = const [],
    this.sashManual = 0,
    this.secW = const [],
    this.hinges = const [],
    BalconyBlock? block,
  }) : block = block ?? BalconyBlock();

  final List<String> path; // цепочка дерева
  final List<String> multi; // отмеченная комплектация
  final Map<String, Map<String, int>> sizes; // пункт -> поле -> мм
  final String glass;
  final int widthMm;
  final int heightMm;
  final List<String> sashModes;
  final int sashManual; // 0 — по типу изделия
  final List<double> secW; // доли ширины секций
  final List<int> hinges;
  final BalconyBlock block;

  String get kind => path.length > 1 ? path[1] : '';
  String get type => path.length > 2 ? path[2] : '';
  String get house => path.length > 3 ? path[3] : '';

  bool get isBalcony =>
      kind.contains('БАЛКОН') || kind.contains('ЛОДЖИЯ');
  bool get balcony => isBalcony || multi.any((m) => m.contains('КОЗЫРЁК'));

  int get sashCount {
    if (sashManual > 0) return sashManual.clamp(1, 4);
    final s = '$type $kind';
    if (s.contains('ОДНОСТВОР')) return 1;
    if (s.contains('ДВУХСТВОР')) return 2;
    if (s.contains('ТРЁХСТВОР')) return 3;
    if (s.contains('С ДВЕРЬЮ')) return 2;
    return 2;
  }

  List<String> get modes {
    if (sashModes.length == sashCount) return sashModes;
    return List<String>.filled(sashCount, 'Г');
  }

  List<double> get secWidths {
    if (secW.length != sashCount) {
      return List<double>.filled(sashCount, 1.0 / sashCount);
    }
    final sum = secW.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) return List<double>.filled(sashCount, 1.0 / sashCount);
    return secW.map((e) => e / sum).toList();
  }

  List<int> get hingeCounts {
    if (hinges.length == sashCount) return hinges;
    return List<int>.filled(sashCount, 2);
  }

  /// Размер поля в ММ из любого пункта комплектации.
  int mmOf(String field) {
    for (final entry in sizes.entries) {
      final v = entry.value[field];
      if (v != null && v > 0) return v;
    }
    return 0;
  }

  bool get hasSize => widthMm > 0 && heightMm > 0;
  double get area => widthMm * heightMm / 1000000.0;
  String get sizeText => hasSize ? '$widthMm × $heightMm мм' : 'РАЗМЕРЫ НЕ ЗАДАНЫ';
  String get label => type.isNotEmpty ? type : kind;
  String get blockWidth => '${block.width}';

  Map<String, dynamic> toJson() => {
        'path': path,
        'multi': multi,
        'sizes': sizes,
        'glass': glass,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'sashModes': sashModes,
        'sashManual': sashManual,
        'secW': secW,
        'hinges': hinges,
        'block': block.toJson(),
      };

  factory MeasureItem.fromJson(Map<String, dynamic> j) {
    int i(String k) {
      final v = j[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    List<String> strList(dynamic v) {
      if (v is List) return v.map((e) => '$e').toList();
      return const [];
    }

    final rawSizes = <String, Map<String, int>>{};
    final s = j['sizes'];
    if (s is Map) {
      for (final e in s.entries) {
        final val = e.value;
        if (val is Map) {
          final m = <String, int>{};
          for (final f in val.entries) {
            final fv = f.value;
            final n = fv is num ? fv.toInt() : int.tryParse('$fv') ?? 0;
            if (n != 0) m['${f.key}'] = n;
          }
          rawSizes['${e.key}'] = m;
        }
      }
    }

    final rawSec = <double>[];
    final sw = j['secW'];
    if (sw is List) {
      for (final e in sw) {
        if (e is num) rawSec.add(e.toDouble());
      }
    }

    final rawH = <int>[];
    final hg = j['hinges'];
    if (hg is List) {
      for (final e in hg) {
        if (e is num) rawH.add(e.toInt());
      }
    }

    BalconyBlock block;
    final b = j['block'];
    if (b is Map) {
      block = BalconyBlock.fromJson(Map<String, dynamic>.from(b));
    } else {
      block = BalconyBlock();
    }

    return MeasureItem(
      path: strList(j['path']),
      multi: strList(j['multi']),
      sizes: rawSizes,
      glass: (j['glass'] ?? '').toString(),
      widthMm: i('widthMm'),
      heightMm: i('heightMm'),
      sashModes: strList(j['sashModes']),
      sashManual: i('sashManual'),
      secW: rawSec,
      hinges: rawH,
      block: block,
    );
  }
}

/// Замер целиком: клиент + изделия.
class Measure {
  Measure({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.flat = '',
    this.floor = '',
    this.items = const [],
  });

  final String name;
  final String phone;
  final String address;
  final String flat;
  final String floor;
  final List<MeasureItem> items;

  String get clientLabel {
    if (name.isEmpty && address.isEmpty) return 'КЛИЕНТ НЕ УКАЗАН';
    final parts = [name, address].where((e) => e.isNotEmpty).toList();
    return parts.join(' · ');
  }

  String encode() => jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
        'flat': flat,
        'floor': floor,
        'items': items.map((e) => e.toJson()).toList(),
      });

  static Measure decode(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return Measure();
      final list = <MeasureItem>[];
      final items = j['items'];
      if (items is List) {
        for (final e in items) {
          if (e is Map) {
            list.add(MeasureItem.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      return Measure(
        name: (j['name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        flat: (j['flat'] ?? '').toString(),
        floor: (j['floor'] ?? '').toString(),
        items: list,
      );
    } catch (_) {
      return Measure();
    }
  }
}