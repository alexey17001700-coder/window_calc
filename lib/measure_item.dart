import 'dart:convert';

/// Балконный блок: дверь + глухое окно (глухняк), выровненное по верху двери.
/// Все размеры — в МИЛЛИМЕТРАХ.
class BalconyBlock {
  double doorWidth; // ширина двери, по умолчанию 600
  double doorHeight; // высота двери, по умолчанию 2100
  double blindWidth; // ширина глухняка, по умолчанию 600
  double blindHeight; // высота глухняка, по умолчанию 500
  bool blindRight; // true — глухняк справа от двери

  BalconyBlock({
    this.doorWidth = 600,
    this.doorHeight = 2100,
    this.blindWidth = 600,
    this.blindHeight = 500,
    this.blindRight = true,
  });

  /// Габарит блока по ширине.
  double get totalWidth => doorWidth + blindWidth;

  /// Габарит блока по высоте (равен высоте двери).
  double get totalHeight => doorHeight;

  /// Площадь блока, м².
  double get area => (totalWidth / 1000) * (totalHeight / 1000);

  /// Площадь остекления, м² (дверь ~75% стекла + глухняк целиком).
  double get glazingArea =>
      (doorWidth / 1000) * (doorHeight / 1000) * 0.75 +
      (blindWidth / 1000) * (blindHeight / 1000);

  /// Метраж уплотнителя по контурам, м.
  double get sealLength =>
      ((doorWidth + doorHeight) * 2 + (blindWidth + blindHeight) * 2) / 1000;

  void reset() {
    doorWidth = 600;
    doorHeight = 2100;
    blindWidth = 600;
    blindHeight = 500;
    blindRight = true;
  }

  Map<String, dynamic> toJson() => {
        'doorWidth': doorWidth,
        'doorHeight': doorHeight,
        'blindWidth': blindWidth,
        'blindHeight': blindHeight,
        'blindRight': blindRight,
      };

  factory BalconyBlock.fromJson(Map<String, dynamic> j) => BalconyBlock(
        doorWidth: (j['doorWidth'] ?? 600).toDouble(),
        doorHeight: (j['doorHeight'] ?? 2100).toDouble(),
        blindWidth: (j['blindWidth'] ?? 600).toDouble(),
        blindHeight: (j['blindHeight'] ?? 500).toDouble(),
        blindRight: j['blindRight'] ?? true,
      );
}

/// Одно изделие в замере.
class MeasureItem {
  String id;
  String workType;
  String product;
  double width;
  double height;
  int sashes;
  String glazing; // Г / П / ПО / О
  String note;
  BalconyBlock? balcony;

  MeasureItem({
    required this.id,
    this.workType = '',
    this.product = '',
    this.width = 0,
    this.height = 0,
    this.sashes = 1,
    this.glazing = 'Г',
    this.note = '',
    this.balcony,
  });

  bool get isBalcony => product.toUpperCase().contains('БАЛКОН');

  double get area {
    if (balcony != null) return balcony!.area;
    return (width / 1000) * (height / 1000);
  }

  String get sizeText {
    final b = balcony;
    if (b != null) {
      return 'Дверь ${b.doorWidth.round()}×${b.doorHeight.round()} · '
          'Глухняк ${b.blindWidth.round()}×${b.blindHeight.round()} '
          '(${b.blindRight ? "справа" : "слева"})';
    }
    return '${width.round()}×${height.round()} мм';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workType': workType,
        'product': product,
        'width': width,
        'height': height,
        'sashes': sashes,
        'glazing': glazing,
        'note': note,
        'balcony': balcony?.toJson(),
      };

  factory MeasureItem.fromJson(Map<String, dynamic> j) => MeasureItem(
        id: j['id'] ?? '',
        workType: j['workType'] ?? '',
        product: j['product'] ?? '',
        width: (j['width'] ?? 0).toDouble(),
        height: (j['height'] ?? 0).toDouble(),
        sashes: j['sashes'] ?? 1,
        glazing: j['glazing'] ?? 'Г',
        note: j['note'] ?? '',
        balcony: j['balcony'] == null
            ? null
            : BalconyBlock.fromJson(Map<String, dynamic>.from(j['balcony'])),
      );
}

/// Полный замер (клиент + список изделий).
class Measure {
  String id;
  String client;
  String phone;
  String address;
  String date;
  List<MeasureItem> items;

  Measure({
    required this.id,
    this.client = '',
    this.phone = '',
    this.address = '',
    this.date = '',
    List<MeasureItem>? items,
  }) : items = items ?? [];

  double get totalArea => items.fold(0.0, (s, i) => s + i.area);

  Map<String, dynamic> toJson() => {
        'id': id,
        'client': client,
        'phone': phone,
        'address': address,
        'date': date,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Measure.fromJson(Map<String, dynamic> j) => Measure(
        id: j['id'] ?? '',
        client: j['client'] ?? '',
        phone: j['phone'] ?? '',
        address: j['address'] ?? '',
        date: j['date'] ?? '',
        items: ((j['items'] ?? []) as List)
            .map((e) => MeasureItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  String encode() => jsonEncode(toJson());

  static Measure decode(String s) =>
      Measure.fromJson(Map<String, dynamic>.from(jsonDecode(s)));
}
