import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

void main() => runApp(const WindowCalcApp());

// ═══════════════════════════════════════════════════════════
// ПРАЙС
// ═══════════════════════════════════════════════════════════

class PriceSettings {
  // Окна
  double window1 = 15000;
  double window2 = 25000;
  double window3 = 35000;

  // Балконы
  double balconyBlock = 45000;
  double balconyGlazingPerM2 = 8000;
  double loggiaGlazingPerM2 = 8500;
  double panoramicPerM2 = 11000;

  // Двери
  double balconyDoor = 25000;
  double pvcDoor = 30000;
  double entranceGroup = 60000;

  // Отделка - Подоконник
  double sillEconomPerM2 = 2000;
  double sillOtherPerM2 = 3000;

  // Отлив
  double dripWhitePerM2 = 1500;
  double dripBrownPerM2 = 1800;

  // Откосы
  double slopePiterPerM2 = 3000;
  double slopeEconomPerM2 = 2200;

  // Откосы доп.
  double slopeExtraPiterPerM2 = 3200;
  double slopeExtraEconomPerM2 = 2400;

  // F-угол
  double fUgol40 = 350;
  double fUgol50 = 400;
  double fUgol60 = 450;

  // Абрис, ПСУЛ, Отмазка
  double abrisPerM = 200;
  double psulPerM = 150;
  double otmazkaPerM = 250;

  // Сетки
  double mosquito = 2500;
  double anticat = 3000;
  double antidust = 2800;
  double frameNet = 2200;
  double plisse = 4500;

  // Стеклопакеты
  double glass24 = 2500;
  double glass32 = 3500;
  double glass40 = 4500;
  double extraTinting = 1000;
  double extraMulti = 1500;

  // Услуги
  double demontagePerItem = 3000;
  double montagePerItem = 3500;
  double trashRemoval = 2000;
  double liftPerFloor = 500;

  // Нестандарт
  double erkerPerM2 = 12000;
  double archWindow = 40000;
  double facadeAlumPerM2 = 15000;

  PriceSettings();

  double basePrice(String type) {
    switch (type) {
      case 'Окно 1-створчатое': return window1;
      case 'Окно 2-створчатое': return window2;
      case 'Окно 3-створчатое': return window3;
      case 'Балконный блок': return balconyBlock;
      case 'Балконная дверь': return balconyDoor;
      case 'Дверь ПВХ': return pvcDoor;
      case 'Входная группа': return entranceGroup;
      case 'Арочное окно': return archWindow;
      default: return 0;
    }
  }

  double perM2Price(String type) {
    switch (type) {
      case 'Балконное остекление': return balconyGlazingPerM2;
      case 'Остекление лоджии': return loggiaGlazingPerM2;
      case 'Панорамное остекление': return panoramicPerM2;
      case 'Эркерное остекление': return erkerPerM2;
      case 'Фасадное алюминиевое остекление': return facadeAlumPerM2;
      default: return 0;
    }
  }

  Map<String, double> toMap() => {
    'window1': window1, 'window2': window2, 'window3': window3,
    'balconyBlock': balconyBlock, 'balconyGlazingPerM2': balconyGlazingPerM2,
    'loggiaGlazingPerM2': loggiaGlazingPerM2, 'panoramicPerM2': panoramicPerM2,
    'balconyDoor': balconyDoor, 'pvcDoor': pvcDoor, 'entranceGroup': entranceGroup,
    'sillEconomPerM2': sillEconomPerM2, 'sillOtherPerM2': sillOtherPerM2,
    'dripWhitePerM2': dripWhitePerM2, 'dripBrownPerM2': dripBrownPerM2,
    'slopePiterPerM2': slopePiterPerM2, 'slopeEconomPerM2': slopeEconomPerM2,
    'slopeExtraPiterPerM2': slopeExtraPiterPerM2, 'slopeExtraEconomPerM2': slopeExtraEconomPerM2,
    'fUgol40': fUgol40, 'fUgol50': fUgol50, 'fUgol60': fUgol60,
    'abrisPerM': abrisPerM, 'psulPerM': psulPerM, 'otmazkaPerM': otmazkaPerM,
    'mosquito': mosquito, 'anticat': anticat, 'antidust': antidust,
    'frameNet': frameNet, 'plisse': plisse,
    'glass24': glass24, 'glass32': glass32, 'glass40': glass40,
    'extraTinting': extraTinting, 'extraMulti': extraMulti,
    'demontagePerItem': demontagePerItem, 'montagePerItem': montagePerItem,
    'trashRemoval': trashRemoval, 'liftPerFloor': liftPerFloor,
    'erkerPerM2': erkerPerM2, 'archWindow': archWindow, 'facadeAlumPerM2': facadeAlumPerM2,
  };

  void fromMap(Map<String, double> m) {
    window1 = m['window1'] ?? window1;
    window2 = m['window2'] ?? window2;
    window3 = m['window3'] ?? window3;
    balconyBlock = m['balconyBlock'] ?? balconyBlock;
    balconyGlazingPerM2 = m['balconyGlazingPerM2'] ?? balconyGlazingPerM2;
    loggiaGlazingPerM2 = m['loggiaGlazingPerM2'] ?? loggiaGlazingPerM2;
    panoramicPerM2 = m['panoramicPerM2'] ?? panoramicPerM2;
    balconyDoor = m['balconyDoor'] ?? balconyDoor;
    pvcDoor = m['pvcDoor'] ?? pvcDoor;
    entranceGroup = m['entranceGroup'] ?? entranceGroup;
    sillEconomPerM2 = m['sillEconomPerM2'] ?? sillEconomPerM2;
    sillOtherPerM2 = m['sillOtherPerM2'] ?? sillOtherPerM2;
    dripWhitePerM2 = m['dripWhitePerM2'] ?? dripWhitePerM2;
    dripBrownPerM2 = m['dripBrownPerM2'] ?? dripBrownPerM2;
    slopePiterPerM2 = m['slopePiterPerM2'] ?? slopePiterPerM2;
    slopeEconomPerM2 = m['slopeEconomPerM2'] ?? slopeEconomPerM2;
    slopeExtraPiterPerM2 = m['slopeExtraPiterPerM2'] ?? slopeExtraPiterPerM2;
    slopeExtraEconomPerM2 = m['slopeExtraEconomPerM2'] ?? slopeExtraEconomPerM2;
    fUgol40 = m['fUgol40'] ?? fUgol40;
    fUgol50 = m['fUgol50'] ?? fUgol50;
    fUgol60 = m['fUgol60'] ?? fUgol60;
    abrisPerM = m['abrisPerM'] ?? abrisPerM;
    psulPerM = m['psulPerM'] ?? psulPerM;
    otmazkaPerM = m['otmazkaPerM'] ?? otmazkaPerM;
    mosquito = m['mosquito'] ?? mosquito;
    anticat = m['anticat'] ?? anticat;
    antidust = m['antidust'] ?? antidust;
    frameNet = m['frameNet'] ?? frameNet;
    plisse = m['plisse'] ?? plisse;
    glass24 = m['glass24'] ?? glass24;
    glass32 = m['glass32'] ?? glass32;
    glass40 = m['glass40'] ?? glass40;
    extraTinting = m['extraTinting'] ?? extraTinting;
    extraMulti = m['extraMulti'] ?? extraMulti;
    demontagePerItem = m['demontagePerItem'] ?? demontagePerItem;
    montagePerItem = m['montagePerItem'] ?? montagePerItem;
    trashRemoval = m['trashRemoval'] ?? trashRemoval;
    liftPerFloor = m['liftPerFloor'] ?? liftPerFloor;
    erkerPerM2 = m['erkerPerM2'] ?? erkerPerM2;
    archWindow = m['archWindow'] ?? archWindow;
    facadeAlumPerM2 = m['facadeAlumPerM2'] ?? facadeAlumPerM2;
  }
}

class PriceStorage {
  static const _key = 'price_v2';

  static Future<PriceSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      final ps = PriceSettings();
      if (raw != null) {
        final map = <String, double>{};
        final json = jsonDecode(raw) as Map<String, dynamic>;
        json.forEach((k, v) {
          if (v is num) map[k] = v.toDouble();
        });
        ps.fromMap(map);
      }
      return ps;
    } catch (_) {
      return PriceSettings();
    }
  }

  static Future<void> save(PriceSettings ps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(ps.toMap()));
    } catch (_) {}
  }
}
// ═══════════════════════════════════════════════════════════
// МОДЕЛИ
// ═══════════════════════════════════════════════════════════

class ProductItem {
  String type;          // Окно 2-створчатое, Балконный блок и т.д.
  double widthMm;
  double heightMm;
  int count;

  // Стеклопакет
  double glassThickness; // 24, 32, 40
  bool tinted;
  bool multi;

  // Отделка - Подоконник
  bool hasSill;
  double sillLengthM;
  double sillDepthMm;
  String sillCategory; // 'Эконом' / 'Другое'

  // Отделка - Отлив
  bool hasDrip;
  double dripLengthM;
  double dripDepthMm;
  String dripColor; // 'Белый' / 'Коричневый'

  // Отделка - Откосы
  bool hasSlopes;
  String houseType; // 'Панелька' / 'Сталинка' / 'Кирпич'
  double slopeLengthM;
  double slopeDepthMm;
  String slopeCategory; // 'Питер' / 'Эконом'

  // Отделка - Откосы доп.
  bool hasExtraSlopes;
  double extraSlopeLengthM;
  double extraSlopeDepthMm;
  String extraSlopeCategory;

  // Отделка - F-угол
  bool hasFUgol;
  String fUgolType; // '40×3.20' / '50×3.20' / '60×3.20'
  int fUgolCount;

  // Монтаж - Абрис/ПСУЛ/Отмазка
  bool hasAbris;
  double abrisLengthM;
  bool hasPsul;
  double psulLengthM;
  bool hasOtmazka;
  double otmazkaLengthM;

  // Сетки
  bool hasMosquito;
  bool hasAnticat;
  bool hasAntidust;
  bool hasFrameNet;
  bool hasPlisse;

  // Услуги по изделию
  bool complexInstall; // демонтаж включён
  bool separateDemontage; // демонтаж отдельно

  ProductItem({
    this.type = 'Окно 2-створчатое',
    this.widthMm = 1300,
    this.heightMm = 1400,
    this.count = 1,
    this.glassThickness = 32,
    this.tinted = false,
    this.multi = false,
    this.hasSill = false,
    this.sillLengthM = 1.5,
    this.sillDepthMm = 300,
    this.sillCategory = 'Эконом',
    this.hasDrip = false,
    this.dripLengthM = 1.5,
    this.dripDepthMm = 200,
    this.dripColor = 'Белый',
    this.hasSlopes = false,
    this.houseType = 'Панелька',
    this.slopeLengthM = 1.5,
    this.slopeDepthMm = 250,
    this.slopeCategory = 'Эконом',
    this.hasExtraSlopes = false,
    this.extraSlopeLengthM = 1.5,
    this.extraSlopeDepthMm = 250,
    this.extraSlopeCategory = 'Эконом',
    this.hasFUgol = false,
    this.fUgolType = '40×3.20',
    this.fUgolCount = 1,
    this.hasAbris = false,
    this.abrisLengthM = 5.0,
    this.hasPsul = false,
    this.psulLengthM = 5.0,
    this.hasOtmazka = false,
    this.otmazkaLengthM = 5.0,
    this.hasMosquito = false,
    this.hasAnticat = false,
    this.hasAntidust = false,
    this.hasFrameNet = false,
    this.hasPlisse = false,
    this.complexInstall = true,
    this.separateDemontage = false,
  });

  double get areaM2 => (widthMm / 1000) * (heightMm / 1000) * count;
  double get perimeterM => ((widthMm + heightMm) * 2 / 1000) * count;

  double calcPrice(PriceSettings ps) {
    double total = 0;

    // Базовая цена изделия
    if (ps.perM2Price(type) > 0) {
      total += ps.perM2Price(type) * areaM2;
    } else {
      total += ps.basePrice(type) * count;
    }

    // Стеклопакет
    double glassPrice = 0;
    if (glassThickness <= 24) glassPrice = ps.glass24;
    else if (glassThickness <= 32) glassPrice = ps.glass32;
    else glassPrice = ps.glass40;
    total += glassPrice * areaM2;
    if (tinted) total += ps.extraTinting * areaM2;
    if (multi) total += ps.extraMulti * areaM2;

    // Подоконник
    if (hasSill) {
      final pricePerM2 = sillCategory == 'Эконом' ? ps.sillEconomPerM2 : ps.sillOtherPerM2;
      final area = sillLengthM * (sillDepthMm / 1000) * count;
      total += area * pricePerM2;
    }

    // Отлив
    if (hasDrip) {
      final pricePerM2 = dripColor == 'Белый' ? ps.dripWhitePerM2 : ps.dripBrownPerM2;
      final area = dripLengthM * (dripDepthMm / 1000) * count;
      total += area * pricePerM2;
    }

    // Откосы
    if (hasSlopes) {
      final pricePerM2 = slopeCategory == 'Питер' ? ps.slopePiterPerM2 : ps.slopeEconomPerM2;
      final area = slopeLengthM * (slopeDepthMm / 1000) * count;
      total += area * pricePerM2;
    }

    // Откосы доп.
    if (hasExtraSlopes) {
      final pricePerM2 = extraSlopeCategory == 'Питер' ? ps.slopeExtraPiterPerM2 : ps.slopeExtraEconomPerM2;
      final area = extraSlopeLengthM * (extraSlopeDepthMm / 1000) * count;
      total += area * pricePerM2;
    }

    // F-угол
    if (hasFUgol) {
      double p = ps.fUgol40;
      if (fUgolType.startsWith('50')) p = ps.fUgol50;
      if (fUgolType.startsWith('60')) p = ps.fUgol60;
      total += p * fUgolCount;
    }

    // Абрис, ПСУЛ, Отмазка
    if (hasAbris) total += ps.abrisPerM * abrisLengthM * count;
    if (hasPsul) total += ps.psulPerM * psulLengthM * count;
    if (hasOtmazka) total += ps.otmazkaPerM * otmazkaLengthM * count;

    // Сетки
    if (hasMosquito) total += ps.mosquito * count;
    if (hasAnticat) total += ps.anticat * count;
    if (hasAntidust) total += ps.antidust * count;
    if (hasFrameNet) total += ps.frameNet * count;
    if (hasPlisse) total += ps.plisse * count;

    // Демонтаж/монтаж
    if (complexInstall) {
      total += ps.montagePerItem * count;
    } else {
      total += ps.montagePerItem * count;
      if (separateDemontage) total += ps.demontagePerItem * count;
    }

    return total;
  }
}

class Measurement {
  String id;
  String clientName;
  String clientPhone;
  String clientAddress;
  String notes;
  List<ProductItem> items;

  // Услуги по замеру в целом
  bool hasTrashRemoval;
  bool hasLift;
  int liftFloors;

  PriceSettings priceSettings;
  DateTime createdAt;

  Measurement({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    this.notes = '',
    required this.items,
    this.hasTrashRemoval = false,
    this.hasLift = false,
    this.liftFloors = 1,
    required this.priceSettings,
    required this.createdAt,
  });

  double get itemsPrice =>
      items.fold(0.0, (s, it) => s + it.calcPrice(priceSettings));

  double get servicesPrice {
    double t = 0;
    if (hasTrashRemoval) t += priceSettings.trashRemoval;
    if (hasLift) t += priceSettings.liftPerFloor * liftFloors;
    return t;
  }

  double get totalPrice => itemsPrice + servicesPrice;

  static String fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'clientAddress': clientAddress,
    'notes': notes,
    'items': items.map((e) => e.toJson()).toList(),
    'hasTrashRemoval': hasTrashRemoval,
    'hasLift': hasLift,
    'liftFloors': liftFloors,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory Measurement.fromJson(Map<String, dynamic> j, PriceSettings ps) =>
      Measurement(
        ...
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  String toShareText() {
    final b = StringBuffer();
    b.writeln('🧾 ЗАМЕРНЫЙ ЛИСТ');
    b.writeln('═══════════════════════');
    b.writeln('Дата: ${fmtDate(createdAt)}');
    b.writeln('Клиент: $clientName');
    b.writeln('Телефон: $clientPhone');
    b.writeln('Адрес: $clientAddress');
    b.writeln('═══════════════════════');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      b.writeln('');
      b.writeln('Позиция ${i + 1}: ${it.type}');
      b.writeln('  Размер: ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count} шт.');
      b.writeln('  Стеклопакет: ${it.glassThickness.toInt()} мм');
      if (it.hasSlopes) b.writeln('  Откосы: ${it.slopeCategory} (${it.houseType})');
      if (it.hasSill) b.writeln('  Подоконник: ${it.sillLengthM} м × ${it.sillDepthMm.toInt()} мм');
      if (it.hasDrip) b.writeln('  Отлив: ${it.dripLengthM} м (${it.dripColor})');
      if (it.hasFUgol) b.writeln('  F-угол: ${it.fUgolType} × ${it.fUgolCount}');
      if (it.hasMosquito) b.writeln('  Москитная сетка');
      if (it.hasPlisse) b.writeln('  Плиссе');
      b.writeln('  Цена: ${it.calcPrice(priceSettings).toStringAsFixed(0)} ₽');
    }
    if (hasTrashRemoval) b.writeln('Вывоз мусора: ${priceSettings.trashRemoval.toStringAsFixed(0)} ₽');
    if (hasLift) b.writeln('Подъём на ${liftFloors} эт.: ${(priceSettings.liftPerFloor * liftFloors).toStringAsFixed(0)} ₽');
    if (notes.isNotEmpty) {
      b.writeln('');
      b.writeln('Примечание: $notes');
    }
    b.writeln('═══════════════════════');
    b.writeln('ИТОГО: ${totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}
// Продолжение Measurement - ProductItem.toJson/fromJson и MeasurementStorage

extension ProductItemJson on ProductItem {
  Map<String, dynamic> toJson() => {
    'type': type,
    'widthMm': widthMm,
    'heightMm': heightMm,
    'count': count,
    'glassThickness': glassThickness,
    'tinted': tinted,
    'multi': multi,
    'hasSill': hasSill,
    'sillLengthM': sillLengthM,
    'sillDepthMm': sillDepthMm,
    'sillCategory': sillCategory,
    'hasDrip': hasDrip,
    'dripLengthM': dripLengthM,
    'dripDepthMm': dripDepthMm,
    'dripColor': dripColor,
    'hasSlopes': hasSlopes,
    'houseType': houseType,
    'slopeLengthM': slopeLengthM,
    'slopeDepthMm': slopeDepthMm,
    'slopeCategory': slopeCategory,
    'hasExtraSlopes': hasExtraSlopes,
    'extraSlopeLengthM': extraSlopeLengthM,
    'extraSlopeDepthMm': extraSlopeDepthMm,
    'extraSlopeCategory': extraSlopeCategory,
    'hasFUgol': hasFUgol,
    'fUgolType': fUgolType,
    'fUgolCount': fUgolCount,
    'hasAbris': hasAbris,
    'abrisLengthM': abrisLengthM,
    'hasPsul': hasPsul,
    'psulLengthM': psulLengthM,
    'hasOtmazka': hasOtmazka,
    'otmazkaLengthM': otmazkaLengthM,
    'hasMosquito': hasMosquito,
    'hasAnticat': hasAnticat,
    'hasAntidust': hasAntidust,
    'hasFrameNet': hasFrameNet,
    'hasPlisse': hasPlisse,
    'complexInstall': complexInstall,
    'separateDemontage': separateDemontage,
  };
}

ProductItem productItemFromJson(Map<String, dynamic> j) => ProductItem(
  type: j['type'] ?? 'Окно 2-створчатое',
  widthMm: (j['widthMm'] ?? 1300).toDouble(),
  heightMm: (j['heightMm'] ?? 1400).toDouble(),
  count: (j['count'] ?? 1) as int,
  glassThickness: (j['glassThickness'] ?? 32).toDouble(),
  tinted: j['tinted'] ?? false,
  multi: j['multi'] ?? false,
  hasSill: j['hasSill'] ?? false,
  sillLengthM: (j['sillLengthM'] ?? 1.5).toDouble(),
  sillDepthMm: (j['sillDepthMm'] ?? 300).toDouble(),
  sillCategory: j['sillCategory'] ?? 'Эконом',
  hasDrip: j['hasDrip'] ?? false,
  dripLengthM: (j['dripLengthM'] ?? 1.5).toDouble(),
  dripDepthMm: (j['dripDepthMm'] ?? 200).toDouble(),
  dripColor: j['dripColor'] ?? 'Белый',
  hasSlopes: j['hasSlopes'] ?? false,
  houseType: j['houseType'] ?? 'Панелька',
  slopeLengthM: (j['slopeLengthM'] ?? 1.5).toDouble(),
  slopeDepthMm: (j['slopeDepthMm'] ?? 250).toDouble(),
  slopeCategory: j['slopeCategory'] ?? 'Эконом',
  hasExtraSlopes: j['hasExtraSlopes'] ?? false,
  extraSlopeLengthM: (j['extraSlopeLengthM'] ?? 1.5).toDouble(),
  extraSlopeDepthMm: (j['extraSlopeDepthMm'] ?? 250).toDouble(),
  extraSlopeCategory: j['extraSlopeCategory'] ?? 'Эконом',
  hasFUgol: j['hasFUgol'] ?? false,
  fUgolType: j['fUgolType'] ?? '40×3.20',
  fUgolCount: (j['fUgolCount'] ?? 1) as int,
  hasAbris: j['hasAbris'] ?? false,
  abrisLengthM: (j['abrisLengthM'] ?? 5.0).toDouble(),
  hasPsul: j['hasPsul'] ?? false,
  psulLengthM: (j['psulLengthM'] ?? 5.0).toDouble(),
  hasOtmazka: j['hasOtmazka'] ?? false,
  otmazkaLengthM: (j['otmazkaLengthM'] ?? 5.0).toDouble(),
  hasMosquito: j['hasMosquito'] ?? false,
  hasAnticat: j['hasAnticat'] ?? false,
  hasAntidust: j['hasAntidust'] ?? false,
  hasFrameNet: j['hasFrameNet'] ?? false,
  hasPlisse: j['hasPlisse'] ?? false,
  complexInstall: j['complexInstall'] ?? true,
  separateDemontage: j['separateDemontage'] ?? false,
);
String toShareText() {
  final b = StringBuffer();
  b.writeln('ЗАМЕРНЫЙ ЛИСТ');
  b.writeln('Клиент: $clientName');
  b.writeln('Телефон: $clientPhone');
  b.writeln('Адрес: $clientAddress');
  b.writeln('');
  for (var i = 0; i < items.length; i++) {
    final it = items[i];
    b.writeln('${i + 1}. ${it.type} ${it.widthMm.toInt()}x${it.heightMm.toInt()} x${it.count} — ${it.calcPrice(priceSettings).toStringAsFixed(0)} руб');
  }
  if (hasTrashRemoval) b.writeln('Вывоз мусора: ${priceSettings.trashRemoval.toStringAsFixed(0)} руб');
  if (hasLift) b.writeln('Подъём ${liftFloors} эт.: ${(priceSettings.liftPerFloor * liftFloors).toStringAsFixed(0)} руб');
  b.writeln('');
  b.writeln('ИТОГО: ${totalPrice.toStringAsFixed(0)} руб');
  return b.toString();
}
class MeasurementStorage {
  static const _key = 'measurements_v2';

  static Future<List<Measurement>> load(PriceSettings ps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      final result = <Measurement>[];
      for (final s in raw) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          result.add(Measurement.fromJson(json, ps));
        } catch (_) {}
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Measurement> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        list.map((m) => jsonEncode(m.toJson())).toList(),
      );
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════
// ГЛАВНОЕ ПРИЛОЖЕНИЕ
// ═══════════════════════════════════════════════════════════

class WindowCalcApp extends StatefulWidget {
  const WindowCalcApp({super.key});

  @override
  State<WindowCalcApp> createState() => _WindowCalcAppState();
}

class _WindowCalcAppState extends State<WindowCalcApp> {
  PriceSettings? _price;
  List<Measurement> _measurements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    PriceSettings ps;
    List<Measurement> ms;
    try {
      ps = await PriceStorage.load();
    } catch (_) {
      ps = PriceSettings();
    }
    try {
      ms = await MeasurementStorage.load(ps);
    } catch (_) {
      ms = [];
    }
    if (!mounted) return;
    setState(() {
      _price = ps;
      _measurements = ms;
      _loading = false;
    });
  }

  Future<void> _savePrice() async {
    if (_price == null) return;
    await PriceStorage.save(_price!);
    setState(() {});
  }

  Future<void> _saveMeasurements() async {
    try {
      await MeasurementStorage.save(_measurements);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MainMenuScreen(
        price: _price!,
        measurements: _measurements,
        onPriceChanged: _savePrice,
        onMeasurementAdded: (m) {
          setState(() => _measurements.insert(0, m));
          _saveMeasurements();
        },
        onMeasurementDeleted: (id) {
          setState(() => _measurements.removeWhere((m) => m.id == id));
          _saveMeasurements();
        },
      ),
    );
  }
}// ═══════════════════════════════════════════════════════════
// ГЛАВНОЕ МЕНЮ
// ═══════════════════════════════════════════════════════════

class MainMenuScreen extends StatelessWidget {
  final PriceSettings price;
  final List<Measurement> measurements;
  final Future<void> Function() onPriceChanged;
  final Function(Measurement) onMeasurementAdded;
  final Function(String) onMeasurementDeleted;

  const MainMenuScreen({
    super.key,
    required this.price,
    required this.measurements,
    required this.onPriceChanged,
    required this.onMeasurementAdded,
    required this.onMeasurementDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Замерщик окон Almas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            context,
            icon: Icons.add_circle,
            color: Colors.blue,
            title: 'Создать замер',
            subtitle: 'Новый замер клиента',
            onTap: () async {
              final result = await Navigator.push<Measurement>(
                context,
                MaterialPageRoute(
                  builder: (_) => MeasurementEditorScreen(price: price),
                ),
              );
              if (result != null) onMeasurementAdded(result);
            },
          ),
          _menuCard(
            context,
            icon: Icons.folder,
            color: Colors.green,
            title: 'Сохранённые замеры',
            subtitle: '${measurements.length} шт.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedMeasurementsScreen(
                    measurements: measurements,
                    onDelete: onMeasurementDeleted,
                  ),
                ),
              );
            },
          ),
          _menuCard(
            context,
            icon: Icons.settings,
            color: Colors.orange,
            title: 'Настройки прайса',
            subtitle: 'Цены на изделия и услуги',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PriceSettingsScreen(
                    price: price,
                    onChanged: onPriceChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// СОХРАНЁННЫЕ ЗАМЕРЫ
// ═══════════════════════════════════════════════════════════

class SavedMeasurementsScreen extends StatefulWidget {
  final List<Measurement> measurements;
  final Function(String) onDelete;
  const SavedMeasurementsScreen({
    super.key,
    required this.measurements,
    required this.onDelete,
  });

  @override
  State<SavedMeasurementsScreen> createState() => _SavedMeasurementsScreenState();
}

class _SavedMeasurementsScreenState extends State<SavedMeasurementsScreen> {
  late List<Measurement> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.measurements);
  }

  void _delete(String id) {
    setState(() => _list.removeWhere((m) => m.id == id));
    widget.onDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранённые замеры'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _list.isEmpty
          ? const Center(child: Text('Пока нет сохранённых замеров'))
          : ListView.separated(
              itemCount: _list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = _list[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.window)),
                  title: Text(m.clientName),
                  subtitle: Text('${Measurement.fmtDate(m.createdAt)} • ${m.items.length} поз.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${m.totalPrice.toStringAsFixed(0)} ₽',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(m),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(measurement: m),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(Measurement m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить замер?'),
        content: Text('Замер для "${m.clientName}" будет удалён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _delete(m.id);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════
// НАСТРОЙКИ ПРАЙСА (сворачиваемые категории)
// ═══════════════════════════════════════════════════════════

class PriceSettingsScreen extends StatefulWidget {
  final PriceSettings price;
  final Future<void> Function() onChanged;
  const PriceSettingsScreen({
    super.key,
    required this.price,
    required this.onChanged,
  });

  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  late Map<String, TextEditingController> _ctrls;
  // Какие категории раскрыты
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _ctrls = {};
    widget.price.toMap().forEach((k, v) {
      _ctrls[k] = TextEditingController(text: v.toStringAsFixed(0));
    });
  }

  @override
  void dispose() {
    for (var c in _ctrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final p = widget.price;
    double g(String k) => double.tryParse(_ctrls[k]!.text) ?? 0;
    p.window1 = g('window1');
    p.window2 = g('window2');
    p.window3 = g('window3');
    p.balconyBlock = g('balconyBlock');
    p.balconyGlazingPerM2 = g('balconyGlazingPerM2');
    p.loggiaGlazingPerM2 = g('loggiaGlazingPerM2');
    p.panoramicPerM2 = g('panoramicPerM2');
    p.balconyDoor = g('balconyDoor');
    p.pvcDoor = g('pvcDoor');
    p.entranceGroup = g('entranceGroup');
    p.sillEconomPerM2 = g('sillEconomPerM2');
    p.sillOtherPerM2 = g('sillOtherPerM2');
    p.dripWhitePerM2 = g('dripWhitePerM2');
    p.dripBrownPerM2 = g('dripBrownPerM2');
    p.slopePiterPerM2 = g('slopePiterPerM2');
    p.slopeEconomPerM2 = g('slopeEconomPerM2');
    p.slopeExtraPiterPerM2 = g('slopeExtraPiterPerM2');
    p.slopeExtraEconomPerM2 = g('slopeExtraEconomPerM2');
    p.fUgol40 = g('fUgol40');
    p.fUgol50 = g('fUgol50');
    p.fUgol60 = g('fUgol60');
    p.abrisPerM = g('abrisPerM');
    p.psulPerM = g('psulPerM');
    p.otmazkaPerM = g('otmazkaPerM');
    p.mosquito = g('mosquito');
    p.anticat = g('anticat');
    p.antidust = g('antidust');
    p.frameNet = g('frameNet');
    p.plisse = g('plisse');
    p.glass24 = g('glass24');
    p.glass32 = g('glass32');
    p.glass40 = g('glass40');
    p.extraTinting = g('extraTinting');
    p.extraMulti = g('extraMulti');
    p.demontagePerItem = g('demontagePerItem');
    p.montagePerItem = g('montagePerItem');
    p.trashRemoval = g('trashRemoval');
    p.liftPerFloor = g('liftPerFloor');
    p.erkerPerM2 = g('erkerPerM2');
    p.archWindow = g('archWindow');
    p.facadeAlumPerM2 = g('facadeAlumPerM2');
    await widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Прайс сохранён')),
      );
    }
  }

  Widget _row(String label, String key, {String suffix = '₽'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _ctrls[key],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                suffixText: suffix,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(String title, IconData icon, List<Widget> children, {String id = ''}) {
    final key = id.isEmpty ? title : id;
    final isOpen = _expanded.contains(key);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.blue),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                if (isOpen) {
                  _expanded.remove(key);
                } else {
                  _expanded.add(key);
                }
              });
            },
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки прайса'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _apply),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _category('Окна', Icons.window, [
            _row('Одностворчатое', 'window1'),
            _row('Двухстворчатое', 'window2'),
            _row('Трёхстворчатое', 'window3'),
          ]),
          _category('Балконы и лоджии', Icons.balcony, [
            _row('Балконный блок', 'balconyBlock'),
            _row('Балконное остекление', 'balconyGlazingPerM2', suffix: '₽/м²'),
            _row('Остекление лоджии', 'loggiaGlazingPerM2', suffix: '₽/м²'),
            _row('Панорамное остекление', 'panoramicPerM2', suffix: '₽/м²'),
          ]),
          _category('Двери', Icons.door_front_door, [
            _row('Балконная дверь', 'balconyDoor'),
            _row('Дверь ПВХ', 'pvcDoor'),
            _row('Входная группа', 'entranceGroup'),
          ]),
          _category('Отделка', Icons.construction, [
            const Divider(),
            const Text('Подоконник (за м²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('Эконом', 'sillEconomPerM2', suffix: '₽/м²'),
            _row('Другое', 'sillOtherPerM2', suffix: '₽/м²'),
            const Divider(),
            const Text('Отлив (за м²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('Белый', 'dripWhitePerM2', suffix: '₽/м²'),
            _row('Коричневый', 'dripBrownPerM2', suffix: '₽/м²'),
            const Divider(),
            const Text('Откосы (за м²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('Питер', 'slopePiterPerM2', suffix: '₽/м²'),
            _row('Эконом', 'slopeEconomPerM2', suffix: '₽/м²'),
            const Divider(),
            const Text('Откосы доп. (за м²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('Питер', 'slopeExtraPiterPerM2', suffix: '₽/м²'),
            _row('Эконом', 'slopeExtraEconomPerM2', suffix: '₽/м²'),
            const Divider(),
            const Text('F-угол (за шт)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('40×3.20', 'fUgol40'),
            _row('50×3.20', 'fUgol50'),
            _row('60×3.20', 'fUgol60'),
            const Divider(),
            const Text('Ленты и замазка (за м)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _row('Абрис', 'abrisPerM', suffix: '₽/м'),
            _row('ПСУЛ', 'psulPerM', suffix: '₽/м'),
            _row('Отмазка', 'otmazkaPerM', suffix: '₽/м'),
          ]),
          _category('Сетки', Icons.grid_on, [
            _row('Москитная сетка', 'mosquito'),
            _row('Антикошка', 'anticat'),
            _row('Антипыль', 'antidust'),
            _row('Рамная', 'frameNet'),
            _row('Плиссе', 'plisse'),
          ]),
          _category('Стеклопакеты', Icons.layers, [
            _row('24 мм', 'glass24', suffix: '₽/м²'),
            _row('32 мм', 'glass32', suffix: '₽/м²'),
            _row('40 мм', 'glass40', suffix: '₽/м²'),
            _row('Тонировка (доплата)', 'extraTinting', suffix: '₽/м²'),
            _row('Мультифункция (доплата)', 'extraMulti', suffix: '₽/м²'),
          ]),
          _category('Услуги', Icons.handyman, [
            _row('Демонтаж (за изделие)', 'demontagePerItem'),
            _row('Монтаж (за изделие)', 'montagePerItem'),
            _row('Вывоз мусора', 'trashRemoval'),
            _row('Подъём (за этаж)', 'liftPerFloor'),
          ]),
          _category('Нестандарт', Icons.star, [
            _row('Эркерное остекление', 'erkerPerM2', suffix: '₽/м²'),
            _row('Арочное окно', 'archWindow'),
            _row('Фасадное алюм. остекление', 'facadeAlumPerM2', suffix: '₽/м²'),
          ]),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _apply,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить прайс'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════
// РЕДАКТОР ЗАМЕРА
// ═══════════════════════════════════════════════════════════

class MeasurementEditorScreen extends StatefulWidget {
  final PriceSettings price;
  const MeasurementEditorScreen({super.key, required this.price});

  @override
  State<MeasurementEditorScreen> createState() => _MeasurementEditorScreenState();
}

class _MeasurementEditorScreenState extends State<MeasurementEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<ProductItem> _items = [ProductItem()];

  bool _hasTrashRemoval = false;
  bool _hasLift = false;
  final _liftFloorsCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    _notesCtrl.dispose();
    _liftFloorsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя клиента')),
      );
      return;
    }
    final m = Measurement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: _nameCtrl.text.trim(),
      clientPhone: _phoneCtrl.text.trim(),
      clientAddress: _addrCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: List.from(_items),
      hasTrashRemoval: _hasTrashRemoval,
      hasLift: _hasLift,
      liftFloors: int.tryParse(_liftFloorsCtrl.text) ?? 1,
      priceSettings: widget.price,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, m);
  }

  double get _itemsTotal =>
      _items.fold(0.0, (s, it) => s + it.calcPrice(widget.price));

  double get _servicesTotal {
    double t = 0;
    if (_hasTrashRemoval) t += widget.price.trashRemoval;
    if (_hasLift) {
      t += widget.price.liftPerFloor * (int.tryParse(_liftFloorsCtrl.text) ?? 1);
    }
    return t;
  }

  double get _total => _itemsTotal + _servicesTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый замер'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Клиент'),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Имя клиента', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addrCtrl,
            decoration: const InputDecoration(labelText: 'Адрес', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Изделия'),
          ...List.generate(_items.length, (i) => _itemCard(i)),
          OutlinedButton.icon(
            onPressed: () => setState(() => _items.add(ProductItem())),
            icon: const Icon(Icons.add),
            label: const Text('Добавить изделие'),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Услуги по замеру'),
          CheckboxListTile(
            value: _hasTrashRemoval,
            onChanged: (v) => setState(() => _hasTrashRemoval = v!),
            title: Text('Вывоз мусора (${widget.price.trashRemoval.toStringAsFixed(0)} ₽)'),
            dense: true,
          ),
          CheckboxListTile(
            value: _hasLift,
            onChanged: (v) => setState(() => _hasLift = v!),
            title: Text('Подъём на этаж (${widget.price.liftPerFloor.toStringAsFixed(0)} ₽/этаж)'),
            dense: true,
          ),
          if (_hasLift)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: _liftFloorsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Количество этажей'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ИТОГО:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_total.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Примечание'),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Например: монтаж в субботу'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить замер'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _itemCard(int index) {
    final it = _items[index];
    final price = it.calcPrice(widget.price);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Изделие ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _items.removeAt(index)),
                  ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: it.type,
              decoration: const InputDecoration(labelText: 'Тип изделия'),
              items: const [
                DropdownMenuItem(value: 'Окно 1-створчатое', child: Text('Окно 1-створчатое')),
                DropdownMenuItem(value: 'Окно 2-створчатое', child: Text('Окно 2-створчатое')),
                DropdownMenuItem(value: 'Окно 3-створчатое', child: Text('Окно 3-створчатое')),
                DropdownMenuItem(value: 'Балконный блок', child: Text('Балконный блок')),
                DropdownMenuItem(value: 'Балконное остекление', child: Text('Балконное остекление')),
                DropdownMenuItem(value: 'Остекление лоджии', child: Text('Остекление лоджии')),
                DropdownMenuItem(value: 'Панорамное остекление', child: Text('Панорамное остекление')),
                DropdownMenuItem(value: 'Балконная дверь', child: Text('Балконная дверь')),
                DropdownMenuItem(value: 'Дверь ПВХ', child: Text('Дверь ПВХ')),
                DropdownMenuItem(value: 'Входная группа', child: Text('Входная группа')),
                DropdownMenuItem(value: 'Эркерное остекление', child: Text('Эркерное остекление')),
                DropdownMenuItem(value: 'Арочное окно', child: Text('Арочное окно')),
                DropdownMenuItem(value: 'Фасадное алюминиевое остекление', child: Text('Фасадное алюм. остекление')),
              ],
              onChanged: (v) => setState(() => it.type = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: it.widthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Ширина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.widthMm = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: it.heightMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Высота, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.heightMm = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: it.count.toString(),
                    decoration: const InputDecoration(labelText: 'Кол-во'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.count = int.tryParse(v) ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<double>(
              value: it.glassThickness,
              decoration: const InputDecoration(labelText: 'Стеклопакет, мм'),
              items: const [
                DropdownMenuItem(value: 24, child: Text('24 мм')),
                DropdownMenuItem(value: 32, child: Text('32 мм')),
                DropdownMenuItem(value: 40, child: Text('40 мм')),
              ],
              onChanged: (v) => setState(() => it.glassThickness = v!),
            ),
            CheckboxListTile(
              value: it.tinted,
              onChanged: (v) => setState(() => it.tinted = v!),
              title: const Text('Тонировка'),
              dense: true,
            ),
            CheckboxListTile(
              value: it.multi,
              onChanged: (v) => setState(() => it.multi = v!),
              title: const Text('Мультифункциональное'),
              dense: true,
            ),

            const Divider(),
            const Text('Отделка', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
                        // ───── Подоконник ─────
            CheckboxListTile(
              value: it.hasSill,
              onChanged: (v) => setState(() => it.hasSill = v!),
              title: const Text('Подоконник'),
              dense: true,
            ),
            if (it.hasSill) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.sillLengthM.toString(),
                    decoration: const InputDecoration(labelText: 'Длина, м'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.sillLengthM = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.sillDepthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.sillDepthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: it.sillCategory,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: const [
                    DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
                    DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                  ],
                  onChanged: (v) => setState(() => it.sillCategory = v!),
                ),
              ]),
            ),

            // ───── Отлив ─────
            CheckboxListTile(
              value: it.hasDrip,
              onChanged: (v) => setState(() => it.hasDrip = v!),
              title: const Text('Отлив'),
              dense: true,
            ),
            if (it.hasDrip) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.dripLengthM.toString(),
                    decoration: const InputDecoration(labelText: 'Длина, м'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.dripLengthM = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.dripDepthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.dripDepthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: it.dripColor,
                  decoration: const InputDecoration(labelText: 'Цвет'),
                  items: const [
                    DropdownMenuItem(value: 'Белый', child: Text('Белый')),
                    DropdownMenuItem(value: 'Коричневый', child: Text('Коричневый')),
                  ],
                  onChanged: (v) => setState(() => it.dripColor = v!),
                ),
              ]),
            ),

            // ───── Откосы ─────
            CheckboxListTile(
              value: it.hasSlopes,
              onChanged: (v) => setState(() => it.hasSlopes = v!),
              title: const Text('Откосы'),
              dense: true,
            ),
            if (it.hasSlopes) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: it.houseType,
                  decoration: const InputDecoration(labelText: 'Тип дома'),
                  items: const [
                    DropdownMenuItem(value: 'Панелька', child: Text('Панелька')),
                    DropdownMenuItem(value: 'Сталинка', child: Text('Сталинка')),
                    DropdownMenuItem(value: 'Кирпич', child: Text('Кирпич')),
                  ],
                  onChanged: (v) => setState(() => it.houseType = v!),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.slopeLengthM.toString(),
                    decoration: const InputDecoration(labelText: 'Длина, м'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.slopeLengthM = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.slopeDepthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.slopeDepthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: it.slopeCategory,
                  decoration: const InputDecoration(labelText: 'Категория откоса'),
                  items: const [
                    DropdownMenuItem(value: 'Питер', child: Text('Питер')),
                    DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
                  ],
                  onChanged: (v) => setState(() => it.slopeCategory = v!),
                ),
              ]),
            ),

            // ───── Откосы доп. ─────
            CheckboxListTile(
              value: it.hasExtraSlopes,
              onChanged: (v) => setState(() => it.hasExtraSlopes = v!),
              title: const Text('Откосы доп. (с улицы)'),
              dense: true,
            ),
            if (it.hasExtraSlopes) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.extraSlopeLengthM.toString(),
                    decoration: const InputDecoration(labelText: 'Длина, м'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.extraSlopeLengthM = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.extraSlopeDepthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.extraSlopeDepthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: it.extraSlopeCategory,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: const [
                    DropdownMenuItem(value: 'Питер', child: Text('Питер')),
                    DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
                  ],
                  onChanged: (v) => setState(() => it.extraSlopeCategory = v!),
                ),
              ]),
            ),

            // ───── F-угол ─────
            CheckboxListTile(
              value: it.hasFUgol,
              onChanged: (v) => setState(() => it.hasFUgol = v!),
              title: const Text('F-угол'),
              dense: true,
            ),
            if (it.hasFUgol) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: it.fUgolType,
                  decoration: const InputDecoration(labelText: 'Тип'),
                  items: const [
                    DropdownMenuItem(value: '40×3.20', child: Text('40×3.20')),
                    DropdownMenuItem(value: '50×3.20', child: Text('50×3.20')),
                    DropdownMenuItem(value: '60×3.20', child: Text('60×3.20')),
                  ],
                  onChanged: (v) => setState(() => it.fUgolType = v!),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: it.fUgolCount.toString(),
                  decoration: const InputDecoration(labelText: 'Количество, шт'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.fUgolCount = int.tryParse(v) ?? 1),
                ),
              ]),
            ),

            // ───── Монтаж: Абрис / ПСУЛ / Отмазка ─────
            const Divider(),
            const Text('Монтажные работы', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            CheckboxListTile(
              value: it.hasAbris,
              onChanged: (v) => setState(() => it.hasAbris = v!),
              title: const Text('Абрис'),
              dense: true,
            ),
            if (it.hasAbris) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: TextFormField(
                initialValue: it.abrisLengthM.toString(),
                decoration: const InputDecoration(labelText: 'Длина, м'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.abrisLengthM = double.tryParse(v) ?? 0),
              ),
            ),
            CheckboxListTile(
              value: it.hasPsul,
              onChanged: (v) => setState(() => it.hasPsul = v!),
              title: const Text('ПСУЛ'),
              dense: true,
            ),
            if (it.hasPsul) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: TextFormField(
                initialValue: it.psulLengthM.toString(),
                decoration: const InputDecoration(labelText: 'Длина, м'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.psulLengthM = double.tryParse(v) ?? 0),
              ),
            ),
            CheckboxListTile(
              value: it.hasOtmazka,
              onChanged: (v) => setState(() => it.hasOtmazka = v!),
              title: const Text('Отмазка'),
              dense: true,
            ),
            if (it.hasOtmazka) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: TextFormField(
                initialValue: it.otmazkaLengthM.toString(),
                decoration: const InputDecoration(labelText: 'Длина, м'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.otmazkaLengthM = double.tryParse(v) ?? 0),
              ),
            ),

            // ───── Сетки ─────
            const Divider(),
            const Text('Сетки', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            CheckboxListTile(value: it.hasMosquito, onChanged: (v) => setState(() => it.hasMosquito = v!), title: const Text('Москитная'), dense: true),
            CheckboxListTile(value: it.hasAnticat, onChanged: (v) => setState(() => it.hasAnticat = v!), title: const Text('Антикошка'), dense: true),
            CheckboxListTile(value: it.hasAntidust, onChanged: (v) => setState(() => it.hasAntidust = v!), title: const Text('Антипыль'), dense: true),
            CheckboxListTile(value: it.hasFrameNet, onChanged: (v) => setState(() => it.hasFrameNet = v!), title: const Text('Рамная'), dense: true),
            CheckboxListTile(value: it.hasPlisse, onChanged: (v) => setState(() => it.hasPlisse = v!), title: const Text('Плиссе'), dense: true),

            // ───── Услуги по изделию ─────
            const Divider(),
            CheckboxListTile(
              value: it.complexInstall,
              onChanged: (v) => setState(() => it.complexInstall = v!),
              title: const Text('Комплекс (монтаж включён)'),
              dense: true,
            ),
            if (!it.complexInstall)
              CheckboxListTile(
                value: it.separateDemontage,
                onChanged: (v) => setState(() => it.separateDemontage = v!),
                title: const Text('Демонтаж отдельно'),
                dense: true,
              ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Стоимость:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('${price.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════
// ЭКРАН РЕЗУЛЬТАТА
// ═══════════════════════════════════════════════════════════

class ResultScreen extends StatelessWidget {
  final Measurement measurement;
  const ResultScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Замерный лист'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(m.clientPhone),
                  Text(m.clientAddress),
                  const Divider(height: 24),
                  const Text('Позиции:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...m.items.asMap().entries.map((e) {
                    final it = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e.key + 1}. ${it.type} — ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('   Стекло ${it.glassThickness.toInt()} мм', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (it.hasSlopes) Text('   Откосы: ${it.slopeCategory} (${it.houseType})', style: const TextStyle(fontSize: 12)),
                          if (it.hasSill) Text('   Подоконник: ${it.sillLengthM} м × ${it.sillDepthMm.toInt()} мм (${it.sillCategory})', style: const TextStyle(fontSize: 12)),
                          if (it.hasDrip) Text('   Отлив: ${it.dripLengthM} м (${it.dripColor})', style: const TextStyle(fontSize: 12)),
                          if (it.hasFUgol) Text('   F-угол: ${it.fUgolType} × ${it.fUgolCount}', style: const TextStyle(fontSize: 12)),
                          if (it.hasMosquito) Text('   + Москитная сетка', style: const TextStyle(fontSize: 12)),
                          if (it.hasPlisse) Text('   + Плиссе', style: const TextStyle(fontSize: 12)),
                          Text('   ${it.calcPrice(m.priceSettings).toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }),
                  if (m.hasTrashRemoval || m.hasLift) ...[
                    const Divider(height: 24),
                    const Text('Услуги:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (m.hasTrashRemoval) Text('• Вывоз мусора — ${m.priceSettings.trashRemoval.toStringAsFixed(0)} ₽'),
                    if (m.hasLift) Text('• Подъём на ${m.liftFloors} эт. — ${(m.priceSettings.liftPerFloor * m.liftFloors).toStringAsFixed(0)} ₽'),
                  ],
                  if (m.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Примечание: ${m.notes}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ИТОГО:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${m.totalPrice.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Поделиться:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _shareButton(context, Icons.person, 'Поделиться с клиентом', 'Красивое описание + цена', Colors.green, _clientVersion(m)),
          _shareButton(context, Icons.factory, 'Отправить на завод', 'Размеры и опции', Colors.orange, _factoryVersion(m)),
          _shareButton(context, Icons.handshake, 'Отправить дилеру', 'Полная спецификация', Colors.purple, _dealerVersion(m)),
          _shareButton(context, Icons.copy, 'Скопировать текст', 'В буфер обмена', Colors.blue, m.toShareText(), copyOnly: true),
        ],
      ),
    );
  }

  Widget _shareButton(BuildContext context, IconData icon, String label, String sub, Color color, String text, {bool copyOnly = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () async {
          if (copyOnly) {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано')));
            }
            return;
          }
          try {
            await Share.share(text, subject: label);
          } catch (_) {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано в буфер')));
            }
          }
        },
      ),
    );
  }

  String _clientVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('Здравствуйте, ${m.clientName}!');
    b.writeln('');
    b.writeln('Ваш заказ:');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('${i + 1}. ${it.type} ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм — ${it.count} шт.');
    }
    b.writeln('');
    b.writeln('ИТОГО: ${m.totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }

  String _factoryVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('=== ЗАКАЗ ===');
    b.writeln('Клиент: ${m.clientName}');
    b.writeln('Адрес: ${m.clientAddress}');
    b.writeln('Тел: ${m.clientPhone}');
    b.writeln('');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('ПОЗИЦИЯ ${i + 1}:');
      b.writeln('  Тип: ${it.type}');
      b.writeln('  Размер: ${it.widthMm.toInt()}×${it.heightMm.toInt()} мм × ${it.count}');
      b.writeln('  Стекло: ${it.glassThickness.toInt()} мм');
      if (it.hasSlopes) b.writeln('  Откосы: ${it.slopeCategory} ${it.slopeLengthM}м × ${it.slopeDepthMm.toInt()}мм');
      if (it.hasSill) b.writeln('  Подоконник: ${it.sillLengthM}м × ${it.sillDepthMm.toInt()}мм');
      if (it.hasDrip) b.writeln('  Отлив: ${it.dripLengthM}м × ${it.dripDepthMm.toInt()}мм (${it.dripColor})');
      if (it.hasFUgol) b.writeln('  F-угол: ${it.fUgolType} × ${it.fUgolCount}');
      if (it.hasAbris) b.writeln('  Абрис: ${it.abrisLengthM}м');
      if (it.hasPsul) b.writeln('  ПСУЛ: ${it.psulLengthM}м');
      if (it.hasOtmazka) b.writeln('  Отмазка: ${it.otmazkaLengthM}м');
      b.writeln('');
    }
    return b.toString();
  }

  String _dealerVersion(Measurement m) {
    final b = StringBuffer();
    b.writeln('ЗАМЕР #${m.id}');
    b.writeln('Клиент: ${m.clientName} (${m.clientPhone})');
    b.writeln('Адрес: ${m.clientAddress}');
    b.writeln('Дата: ${Measurement.fmtDate(m.createdAt)}');
    b.writeln('');
    for (var i = 0; i < m.items.length; i++) {
      final it = m.items[i];
      b.writeln('${i + 1}. ${it.type} — ${it.calcPrice(m.priceSettings).toStringAsFixed(0)} ₽');
    }
    if (m.hasTrashRemoval) b.writeln('Вывоз мусора — ${m.priceSettings.trashRemoval.toStringAsFixed(0)} ₽');
    if (m.hasLift) b.writeln('Подъём ${m.liftFloors} эт. — ${(m.priceSettings.liftPerFloor * m.liftFloors).toStringAsFixed(0)} ₽');
    b.writeln('');
    b.writeln('К ОПЛАТЕ: ${m.totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}

// ═══════════════════════════════════════════════════════════
// ВСПОМОГАТЕЛЬНОЕ
// ═══════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
