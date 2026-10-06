import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'update_checker.dart';
import 'splash_screen.dart';
import 'service_screen.dart';

void main() => runApp(const WindowCalcApp());

// ═══════════════════════════════════════════════════════════
// ПРАЙС
// ═══════════════════════════════════════════════════════════

class PriceSettings {
  double window1 = 15000;
  double window2 = 25000;
  double window3 = 35000;
  double balconyBlock = 45000;
  double balconyGlazingPerM2 = 8000;
  double loggiaGlazingPerM2 = 8500;
  double panoramicPerM2 = 11000;
  double balconyDoor = 25000;
  double pvcDoor = 30000;
  double entranceGroup = 60000;
  double furRoto = 2000;
  double furMaco = 1800;
  double furReze = 2200;
  double furOther = 1500;
  double coefRehau = 1.2;
  double coefBauline = 1.1;
  double coefNovoline = 1.0;
  double coefBrusbox = 1.05;
  double coefVeka = 1.15;
  double coefKBE = 1.0;
  double coefOther = 1.0;
  double sillEconomPerM2 = 2000;
  double sillOtherPerM2 = 3000;
  double dripWhitePerM2 = 1500;
  double dripBrownPerM2 = 1800;
  double slopePiterPerM2 = 3000;
  double slopeEconomPerM2 = 2200;
  double slopeExtraPiterPerM2 = 3200;
  double slopeExtraEconomPerM2 = 2400;
  double mountSlopesPerM2 = 500;
  double mountSillPerM2 = 400;
  double fUgol40 = 110;
  double fUgol50 = 140;
  double fUgol60 = 170;
  double abrisPerM = 200;
  double psulPerM = 150;
  double otmazkaPerM = 250;
  double mosquito = 2500;
  double anticat = 3000;
  double antidust = 2800;
  double frameNet = 2200;
  double plisse = 4500;
  double glass24 = 2500;
  double glass32 = 3500;
  double glass40 = 4500;
  double extraTinting = 1000;
  double extraMulti = 1500;
  double demontagePerItem = 3000;
  double montagePerItem = 3500;
  double trashRemoval = 2000;
  double liftPerFloor = 500;
  double delivery = 1500;
  double erkerPerM2 = 12000;
  double archWindow = 40000;
  double facadeAlumPerM2 = 15000;

  // Сервис и ремонт
  double mountSillServicePerM = 0;
  double mountSlopeServicePerM = 0;
  double mountNetServicePerPc = 0;
  double regulationPerPc = 0;
  double handleReplacePerPc = 0;
  double rubberReplacePerSash = 0;
  double rubberReplaceBlindExtra = 0;
  double glassReplacePerPc = 0;
  double glassReplaceBlindExtra = 0;
  double furnitureReplacePerPc = 0;
  double sillReplacePerM = 0;

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

  double profileCoef(String profile) {
    switch (profile) {
      case 'Rehau': return coefRehau;
      case 'Bauline': return coefBauline;
      case 'Novoline': return coefNovoline;
      case 'Brusbox': return coefBrusbox;
      case 'Veka': return coefVeka;
      case 'KBE': return coefKBE;
      default: return coefOther;
    }
  }

  double furniturePrice(String furniture) {
    switch (furniture) {
      case 'Roto': return furRoto;
      case 'Maco': return furMaco;
      case 'Reze': return furReze;
      default: return furOther;
    }
  }
    Map<String, double> toMap() => {
    'window1': window1, 'window2': window2, 'window3': window3,
    'balconyBlock': balconyBlock, 'balconyGlazingPerM2': balconyGlazingPerM2,
    'loggiaGlazingPerM2': loggiaGlazingPerM2, 'panoramicPerM2': panoramicPerM2,
    'balconyDoor': balconyDoor, 'pvcDoor': pvcDoor, 'entranceGroup': entranceGroup,
    'furRoto': furRoto, 'furMaco': furMaco, 'furReze': furReze, 'furOther': furOther,
    'coefRehau': coefRehau, 'coefBauline': coefBauline, 'coefNovoline': coefNovoline,
    'coefBrusbox': coefBrusbox, 'coefVeka': coefVeka, 'coefKBE': coefKBE, 'coefOther': coefOther,
    'sillEconomPerM2': sillEconomPerM2, 'sillOtherPerM2': sillOtherPerM2,
    'dripWhitePerM2': dripWhitePerM2, 'dripBrownPerM2': dripBrownPerM2,
    'slopePiterPerM2': slopePiterPerM2, 'slopeEconomPerM2': slopeEconomPerM2,
    'slopeExtraPiterPerM2': slopeExtraPiterPerM2, 'slopeExtraEconomPerM2': slopeExtraEconomPerM2,
    'mountSlopesPerM2': mountSlopesPerM2, 'mountSillPerM2': mountSillPerM2,
    'fUgol40': fUgol40, 'fUgol50': fUgol50, 'fUgol60': fUgol60,
    'abrisPerM': abrisPerM, 'psulPerM': psulPerM, 'otmazkaPerM': otmazkaPerM,
    'mosquito': mosquito, 'anticat': anticat, 'antidust': antidust,
    'frameNet': frameNet, 'plisse': plisse,
    'glass24': glass24, 'glass32': glass32, 'glass40': glass40,
    'extraTinting': extraTinting, 'extraMulti': extraMulti,
    'demontagePerItem': demontagePerItem, 'montagePerItem': montagePerItem,
    'trashRemoval': trashRemoval, 'liftPerFloor': liftPerFloor, 'delivery': delivery,
    'erkerPerM2': erkerPerM2, 'archWindow': archWindow, 'facadeAlumPerM2': facadeAlumPerM2,
  'mountSillServicePerM': mountSillServicePerM,
  'mountSlopeServicePerM': mountSlopeServicePerM,
  'mountNetServicePerPc': mountNetServicePerPc,
  'regulationPerPc': regulationPerPc,
  'handleReplacePerPc': handleReplacePerPc,
  'rubberReplacePerSash': rubberReplacePerSash,
  'rubberReplaceBlindExtra': rubberReplaceBlindExtra,
  'glassReplacePerPc': glassReplacePerPc,
  'glassReplaceBlindExtra': glassReplaceBlindExtra,
  'furnitureReplacePerPc': furnitureReplacePerPc,
  'sillReplacePerM': sillReplacePerM,
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
    furRoto = m['furRoto'] ?? furRoto;
    furMaco = m['furMaco'] ?? furMaco;
    furReze = m['furReze'] ?? furReze;
    furOther = m['furOther'] ?? furOther;
    coefRehau = m['coefRehau'] ?? coefRehau;
    coefBauline = m['coefBauline'] ?? coefBauline;
    coefNovoline = m['coefNovoline'] ?? coefNovoline;
    coefBrusbox = m['coefBrusbox'] ?? coefBrusbox;
    coefVeka = m['coefVeka'] ?? coefVeka;
    coefKBE = m['coefKBE'] ?? coefKBE;
    coefOther = m['coefOther'] ?? coefOther;
    sillEconomPerM2 = m['sillEconomPerM2'] ?? sillEconomPerM2;
    sillOtherPerM2 = m['sillOtherPerM2'] ?? sillOtherPerM2;
    dripWhitePerM2 = m['dripWhitePerM2'] ?? dripWhitePerM2;
    dripBrownPerM2 = m['dripBrownPerM2'] ?? dripBrownPerM2;
    slopePiterPerM2 = m['slopePiterPerM2'] ?? slopePiterPerM2;
    slopeEconomPerM2 = m['slopeEconomPerM2'] ?? slopeEconomPerM2;
    slopeExtraPiterPerM2 = m['slopeExtraPiterPerM2'] ?? slopeExtraPiterPerM2;
    slopeExtraEconomPerM2 = m['slopeExtraEconomPerM2'] ?? slopeExtraEconomPerM2;
    mountSlopesPerM2 = m['mountSlopesPerM2'] ?? mountSlopesPerM2;
    mountSillPerM2 = m['mountSillPerM2'] ?? mountSillPerM2;
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
    delivery = m['delivery'] ?? delivery;
    erkerPerM2 = m['erkerPerM2'] ?? erkerPerM2;
   archWindow = m['archWindow'] ?? archWindow;
   facadeAlumPerM2 = m['facadeAlumPerM2'] ?? facadeAlumPerM2;
   mountSillServicePerM = m['mountSillServicePerM'] ?? mountSillServicePerM;
   mountSlopeServicePerM = m['mountSlopeServicePerM'] ?? mountSlopeServicePerM;
   mountNetServicePerPc = m['mountNetServicePerPc'] ?? mountNetServicePerPc;
   regulationPerPc = m['regulationPerPc'] ?? regulationPerPc;
   handleReplacePerPc = m['handleReplacePerPc'] ?? handleReplacePerPc;
   rubberReplacePerSash = m['rubberReplacePerSash'] ?? rubberReplacePerSash;
   rubberReplaceBlindExtra = m['rubberReplaceBlindExtra'] ?? rubberReplaceBlindExtra;
   glassReplacePerPc = m['glassReplacePerPc'] ?? glassReplacePerPc;
   glassReplaceBlindExtra = m['glassReplaceBlindExtra'] ?? glassReplaceBlindExtra;
   furnitureReplacePerPc = m['furnitureReplacePerPc'] ?? furnitureReplacePerPc;
   sillReplacePerM = m['sillReplacePerM'] ?? sillReplacePerM;
 }
}
class PriceStorage {
  static const _key = 'price_v3';

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

class SillItem {
  double lengthMm;
  double depthMm;
  String category;

  SillItem({
    this.lengthMm = 1700,
    this.depthMm = 250,
    this.category = 'Эконом',
  });

  double get areaM2 => (lengthMm / 1000) * (depthMm / 1000);

  Map<String, dynamic> toJson() => {
    'lengthMm': lengthMm,
    'depthMm': depthMm,
    'category': category,
  };

  factory SillItem.fromJson(Map<String, dynamic> j) => SillItem(
    lengthMm: (j['lengthMm'] ?? 1700).toDouble(),
    depthMm: (j['depthMm'] ?? 250).toDouble(),
    category: (j['category'] ?? 'Эконом').toString(),
  );
}

class ProductItem {
  String type;
  String profile;
  String furniture;

  double widthMm;
  double heightMm;
  int count;
  int sashes;

  double glassThickness;
  bool tinted;
  bool multi;

  bool hasSlopes;
  String houseType;
  String slopeCategory;
  double slopeDepthMm;
  double slopeLengthSideMm;
  double slopeLengthTopMm;
  bool mountSlopesSeparately;

  bool hasExtraSlopes;
  String extraSlopeCategory;
  double extraSlopeDepthMm;
  double extraSlopeLengthSideMm;
  double extraSlopeLengthTopMm;

  bool hasSill;
  List<SillItem> sills;
  bool mountSillSeparately;

  bool hasDrip;
  double dripLengthMm;
  double dripDepthMm;
  String dripColor;

  bool hasFUgol;
  String fUgolType;
  int fUgolCount;

  bool hasAbris;
  double abrisLengthMm;
  bool hasPsul;
  double psulLengthMm;
  bool hasOtmazka;
  double otmazkaLengthMm;

  bool hasMosquito;
  bool hasAnticat;
  bool hasAntidust;
  bool hasFrameNet;
  bool hasPlisse;

  bool complexInstall;
  bool separateDemontage;

  ProductItem({
    this.type = 'Окно 2-створчатое',
    this.profile = 'Novoline',
    this.furniture = 'Roto',
    this.widthMm = 1300,
    this.heightMm = 1400,
    this.count = 1,
    this.sashes = 2,
    this.glassThickness = 32,
    this.tinted = false,
    this.multi = false,
    this.hasSlopes = false,
    this.houseType = 'Панелька',
    this.slopeCategory = 'Эконом',
    this.slopeDepthMm = 200,
    this.slopeLengthSideMm = 1400,
    this.slopeLengthTopMm = 1300,
    this.mountSlopesSeparately = false,
    this.hasExtraSlopes = false,
    this.extraSlopeCategory = 'Эконом',
    this.extraSlopeDepthMm = 200,
    this.extraSlopeLengthSideMm = 1400,
    this.extraSlopeLengthTopMm = 1300,
    this.hasSill = false,
    List<SillItem>? sills,
    this.mountSillSeparately = false,
    this.hasDrip = false,
    this.dripLengthMm = 1300,
    this.dripDepthMm = 200,
    this.dripColor = 'Белый',
    this.hasFUgol = false,
    this.fUgolType = '40×3.20',
    this.fUgolCount = 1,
    this.hasAbris = false,
    this.abrisLengthMm = 5000,
    this.hasPsul = false,
    this.psulLengthMm = 5000,
    this.hasOtmazka = false,
    this.otmazkaLengthMm = 5000,
    this.hasMosquito = false,
    this.hasAnticat = false,
    this.hasAntidust = false,
    this.hasFrameNet = false,
    this.hasPlisse = false,
    this.complexInstall = true,
    this.separateDemontage = false,
  }) : sills = sills ?? [];

  double get areaM2 => (widthMm / 1000) * (heightMm / 1000) * count;

  static int defaultSashes(String type) {
    switch (type) {
      case 'Окно 1-створчатое': return 1;
      case 'Окно 2-створчатое': return 2;
      case 'Окно 3-створчатое': return 3;
      case 'Балконный блок': return 3;
      case 'Балконная дверь': return 1;
      case 'Дверь ПВХ': return 1;
      default: return 1;
    }
  }
  double calcPrice(PriceSettings ps) {
  double total = 0;

  final perM2 = ps.perM2Price(type);
  if (perM2 > 0) {
    total += perM2 * areaM2 * ps.profileCoef(profile);
  } else {
    total += ps.basePrice(type) * count * ps.profileCoef(profile);
  }

  total += ps.furniturePrice(furniture) * sashes * count;

  double glassPrice = ps.glass32;
  if (glassThickness <= 24) glassPrice = ps.glass24;
  else if (glassThickness <= 32) glassPrice = ps.glass32;
  else glassPrice = ps.glass40;
  total += glassPrice * areaM2;
  if (tinted) total += ps.extraTinting * areaM2;
  if (multi) total += ps.extraMulti * areaM2;

  if (hasSlopes) {
    final pricePerM2 = slopeCategory == 'Питер' ? ps.slopePiterPerM2 : ps.slopeEconomPerM2;
    final totalLengthMm = slopeLengthSideMm * 2 + slopeLengthTopMm;
    final area = (totalLengthMm * slopeDepthMm) / 1000000 * count;
    total += area * pricePerM2;
    if (mountSlopesSeparately) total += area * ps.mountSlopesPerM2;
  }

  if (hasExtraSlopes) {
    final pricePerM2 = extraSlopeCategory == 'Питер' ? ps.slopeExtraPiterPerM2 : ps.slopeExtraEconomPerM2;
    final totalLengthMm = extraSlopeLengthSideMm * 2 + extraSlopeLengthTopMm;
    final area = (totalLengthMm * extraSlopeDepthMm) / 1000000 * count;
    total += area * pricePerM2;
  }

  if (hasSill && sills.isNotEmpty) {
    for (final s in sills) {
      final pricePerM2 = s.category == 'Эконом' ? ps.sillEconomPerM2 : ps.sillOtherPerM2;
      total += s.areaM2 * pricePerM2 * count;
      if (mountSillSeparately) total += s.areaM2 * ps.mountSillPerM2 * count;
    }
  }

  if (hasDrip) {
    final pricePerM2 = dripColor == 'Белый' ? ps.dripWhitePerM2 : ps.dripBrownPerM2;
    final area = (dripLengthMm * dripDepthMm) / 1000000 * count;
    total += area * pricePerM2;
  }

  if (hasFUgol) {
    double p = ps.fUgol40;
    if (fUgolType.startsWith('50')) p = ps.fUgol50;
    if (fUgolType.startsWith('60')) p = ps.fUgol60;
    total += p * fUgolCount;
  }

  if (hasAbris) total += (abrisLengthMm / 1000) * ps.abrisPerM * count;
  if (hasPsul) total += (psulLengthMm / 1000) * ps.psulPerM * count;
  if (hasOtmazka) total += (otmazkaLengthMm / 1000) * ps.otmazkaPerM * count;

  if (hasMosquito) total += ps.mosquito * count;
  if (hasAnticat) total += ps.anticat * count;
  if (hasAntidust) total += ps.antidust * count;
  if (hasFrameNet) total += ps.frameNet * count;
  if (hasPlisse) total += ps.plisse * count;

  total += ps.montagePerItem * count;
  if (!complexInstall && separateDemontage) {
    total += ps.demontagePerItem * count;
  }

  return total;
}

double calcMountPrice(PriceSettings ps) {
  double t = ps.montagePerItem * count;
  if (!complexInstall && separateDemontage) t += ps.demontagePerItem * count;
  return t;
}

double calcExtrasPrice(PriceSettings ps) {
  double t = 0;
  if (hasOtmazka) t += (otmazkaLengthMm / 1000) * ps.otmazkaPerM * count;
  if (mountSlopesSeparately && hasSlopes) {
    final totalLengthMm = slopeLengthSideMm * 2 + slopeLengthTopMm;
    final area = (totalLengthMm * slopeDepthMm) / 1000000 * count;
    t += area * ps.mountSlopesPerM2;
  }
  if (mountSillSeparately && hasSill && sills.isNotEmpty) {
    for (final s in sills) {
      t += s.areaM2 * ps.mountSillPerM2 * count;
    }
  }
  return t;
}
    Map<String, dynamic> toJson() => {
    'type': type,
    'profile': profile,
    'furniture': furniture,
    'widthMm': widthMm,
    'heightMm': heightMm,
    'count': count,
    'sashes': sashes,
    'glassThickness': glassThickness,
    'tinted': tinted,
    'multi': multi,
    'hasSlopes': hasSlopes,
    'houseType': houseType,
    'slopeCategory': slopeCategory,
    'slopeDepthMm': slopeDepthMm,
    'slopeLengthSideMm': slopeLengthSideMm,
    'slopeLengthTopMm': slopeLengthTopMm,
    'mountSlopesSeparately': mountSlopesSeparately,
    'hasExtraSlopes': hasExtraSlopes,
    'extraSlopeCategory': extraSlopeCategory,
    'extraSlopeDepthMm': extraSlopeDepthMm,
    'extraSlopeLengthSideMm': extraSlopeLengthSideMm,
    'extraSlopeLengthTopMm': extraSlopeLengthTopMm,
    'hasSill': hasSill,
    'sills': sills.map((e) => e.toJson()).toList(),
    'mountSillSeparately': mountSillSeparately,
    'hasDrip': hasDrip,
    'dripLengthMm': dripLengthMm,
    'dripDepthMm': dripDepthMm,
    'dripColor': dripColor,
    'hasFUgol': hasFUgol,
    'fUgolType': fUgolType,
    'fUgolCount': fUgolCount,
    'hasAbris': hasAbris,
    'abrisLengthMm': abrisLengthMm,
    'hasPsul': hasPsul,
    'psulLengthMm': psulLengthMm,
    'hasOtmazka': hasOtmazka,
    'otmazkaLengthMm': otmazkaLengthMm,
    'hasMosquito': hasMosquito,
    'hasAnticat': hasAnticat,
    'hasAntidust': hasAntidust,
    'hasFrameNet': hasFrameNet,
    'hasPlisse': hasPlisse,
    'complexInstall': complexInstall,
    'separateDemontage': separateDemontage,
  };

  factory ProductItem.fromJson(Map<String, dynamic> j) => ProductItem(
    type: (j['type'] ?? 'Окно 2-створчатое').toString(),
    profile: (j['profile'] ?? 'Novoline').toString(),
    furniture: (j['furniture'] ?? 'Roto').toString(),
    widthMm: (j['widthMm'] ?? 1300).toDouble(),
    heightMm: (j['heightMm'] ?? 1400).toDouble(),
    count: (j['count'] ?? 1) as int,
    sashes: (j['sashes'] ?? 2) as int,
    glassThickness: (j['glassThickness'] ?? 32).toDouble(),
    tinted: j['tinted'] ?? false,
    multi: j['multi'] ?? false,
    hasSlopes: j['hasSlopes'] ?? false,
    houseType: (j['houseType'] ?? 'Панелька').toString(),
    slopeCategory: (j['slopeCategory'] ?? 'Эконом').toString(),
    slopeDepthMm: (j['slopeDepthMm'] ?? 200).toDouble(),
    slopeLengthSideMm: (j['slopeLengthSideMm'] ?? 1400).toDouble(),
    slopeLengthTopMm: (j['slopeLengthTopMm'] ?? 1300).toDouble(),
    mountSlopesSeparately: j['mountSlopesSeparately'] ?? false,
    hasExtraSlopes: j['hasExtraSlopes'] ?? false,
    extraSlopeCategory: (j['extraSlopeCategory'] ?? 'Эконом').toString(),
    extraSlopeDepthMm: (j['extraSlopeDepthMm'] ?? 200).toDouble(),
    extraSlopeLengthSideMm: (j['extraSlopeLengthSideMm'] ?? 1400).toDouble(),
    extraSlopeLengthTopMm: (j['extraSlopeLengthTopMm'] ?? 1300).toDouble(),
    hasSill: j['hasSill'] ?? false,
    sills: ((j['sills'] as List?) ?? [])
        .map((e) => SillItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    mountSillSeparately: j['mountSillSeparately'] ?? false,
    hasDrip: j['hasDrip'] ?? false,
    dripLengthMm: (j['dripLengthMm'] ?? 1300).toDouble(),
    dripDepthMm: (j['dripDepthMm'] ?? 200).toDouble(),
    dripColor: (j['dripColor'] ?? 'Белый').toString(),
    hasFUgol: j['hasFUgol'] ?? false,
    fUgolType: (j['fUgolType'] ?? '40×3.20').toString(),
    fUgolCount: (j['fUgolCount'] ?? 1) as int,
    hasAbris: j['hasAbris'] ?? false,
    abrisLengthMm: (j['abrisLengthMm'] ?? 5000).toDouble(),
    hasPsul: j['hasPsul'] ?? false,
    psulLengthMm: (j['psulLengthMm'] ?? 5000).toDouble(),
    hasOtmazka: j['hasOtmazka'] ?? false,
    otmazkaLengthMm: (j['otmazkaLengthMm'] ?? 5000).toDouble(),
    hasMosquito: j['hasMosquito'] ?? false,
    hasAnticat: j['hasAnticat'] ?? false,
    hasAntidust: j['hasAntidust'] ?? false,
    hasFrameNet: j['hasFrameNet'] ?? false,
    hasPlisse: j['hasPlisse'] ?? false,
    complexInstall: j['complexInstall'] ?? true,
    separateDemontage: j['separateDemontage'] ?? false,
  );
}
// ═══════════════════════════════════════════════════════════
// ЗАМЕР
// ═══════════════════════════════════════════════════════════

class Measurement {
  String id;
  String clientName;
  String clientPhone;
  String clientAddress;
  String notes;
  List<ProductItem> items;

  bool hasTrashRemoval;
  bool hasLift;
  int liftFloors;
  bool hasDelivery;

  double? customClientPrice;

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
    this.hasDelivery = false,
    this.customClientPrice,
    required this.priceSettings,
    required this.createdAt,
  });

  double get itemsPrice =>
      items.fold(0.0, (s, it) => s + it.calcPrice(priceSettings));

  double get servicesPrice {
    double t = 0;
    if (hasTrashRemoval) t += priceSettings.trashRemoval;
    if (hasLift) t += priceSettings.liftPerFloor * liftFloors;
    if (hasDelivery) t += priceSettings.delivery;
    return t;
  }

  double get totalPrice => itemsPrice + servicesPrice;

  double get clientPrice => customClientPrice ?? totalPrice;

  double get dealerMountPrice {
    double itemsPart = 0;
    for (final it in items) {
      itemsPart += it.calcMountPrice(priceSettings);
      itemsPart += it.calcExtrasPrice(priceSettings);
    }
    double servicesPart = 0;
    if (hasLift) servicesPart += priceSettings.liftPerFloor * liftFloors;
    if (hasDelivery) servicesPart += priceSettings.delivery;
    if (hasTrashRemoval) servicesPart += priceSettings.trashRemoval;
    return itemsPart + servicesPart;
  }

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
    'hasDelivery': hasDelivery,
    'customClientPrice': customClientPrice,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Measurement.fromJson(Map<String, dynamic> j, PriceSettings ps) =>
      Measurement(
        id: (j['id'] ?? '').toString(),
        clientName: (j['clientName'] ?? '').toString(),
        clientPhone: (j['clientPhone'] ?? '').toString(),
        clientAddress: (j['clientAddress'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
        items: ((j['items'] as List?) ?? [])
            .map((e) => ProductItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        hasTrashRemoval: j['hasTrashRemoval'] ?? false,
        hasLift: j['hasLift'] ?? false,
        liftFloors: (j['liftFloors'] ?? 1) as int,
        hasDelivery: j['hasDelivery'] ?? false,
        customClientPrice: j['customClientPrice'] != null
            ? (j['customClientPrice'] as num).toDouble()
            : null,
        priceSettings: ps,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
    String toFactoryText() {
    final b = StringBuffer();
    b.writeln('=== ЗАКАЗ НА ПРОИЗВОДСТВО ===');
    b.writeln('Дата: ${fmtDate(createdAt)}');
    b.writeln('Клиент: $clientName');
    b.writeln('Адрес: $clientAddress');
    b.writeln('Тел: $clientPhone');
    b.writeln('');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      b.writeln('ПОЗИЦИЯ ${i + 1}:');
      b.writeln('  Тип: ${it.type}');
      b.writeln('  Профиль: ${it.profile}');
      b.writeln('  Фурнитура: ${it.furniture}');
      b.writeln('  Размер: ${it.widthMm.toInt()}x${it.heightMm.toInt()} мм');
      b.writeln('  Количество: ${it.count} шт');
      b.writeln('  Створок: ${it.sashes}');
      final glassOpts = <String>[];
      if (it.tinted) glassOpts.add('тонировка');
      if (it.multi) glassOpts.add('мульти');
      final glassStr = glassOpts.isEmpty ? '' : ', ${glassOpts.join(", ")}';
      b.writeln('  Стеклопакет: ${it.glassThickness.toInt()} мм$glassStr');
      if (it.hasSill && it.sills.isNotEmpty) {
        b.writeln('  Подоконники: ${it.sills.length} шт');
        for (var k = 0; k < it.sills.length; k++) {
          final s = it.sills[k];
          b.writeln('    ${k + 1}) ${s.lengthMm.toInt()}x${s.depthMm.toInt()} мм');
        }
      }
      if (it.hasDrip) {
        b.writeln('  Отлив: ${it.dripLengthMm.toInt()}x${it.dripDepthMm.toInt()} мм (${it.dripColor})');
      }
      if (it.hasFUgol) {
        b.writeln('  F-угол: ${it.fUgolType} x ${it.fUgolCount} шт');
      }
      if (it.hasMosquito) b.writeln('  Москитная сетка: да');
      if (it.hasAnticat) b.writeln('  Антикошка: да');
      if (it.hasAntidust) b.writeln('  Антипыль: да');
      if (it.hasFrameNet) b.writeln('  Рамная сетка: да');
      if (it.hasPlisse) b.writeln('  Плиссе: да');
      b.writeln('');
    }
    if (notes.isNotEmpty) b.writeln('Примечание: $notes');
    return b.toString();
  }

  String toClientText() {
    final b = StringBuffer();
    b.writeln('Здравствуйте, $clientName!');
    b.writeln('');
    b.writeln('Ваш заказ:');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      b.writeln('  ${i + 1}. ${it.type} ${it.widthMm.toInt()}x${it.heightMm.toInt()} мм — ${it.count} шт');
    }
    b.writeln('');
    final opts = <String>{};
    for (final it in items) {
      if (it.hasSill) opts.add('подоконники');
      if (it.hasDrip) opts.add('отливы');
      if (it.hasSlopes) opts.add('откосы');
      if (it.hasMosquito) opts.add('москитная сетка');
      if (it.hasPlisse) opts.add('плиссе');
      if (it.hasFUgol) opts.add('F-угол');
    }
    if (opts.isNotEmpty) {
      b.writeln('Опции: ${opts.join(", ")}');
      b.writeln('');
    }
    b.writeln('ИТОГО: ${clientPrice.toStringAsFixed(0)} ₽');
    b.writeln('');
    b.writeln('По вопросам — звоните!');
    return b.toString();
  }

  String toDealerText() {
    final b = StringBuffer();
    b.writeln('=== ЗАМЕР #$id ===');
    b.writeln('Клиент: $clientName ($clientPhone)');
    b.writeln('Адрес: $clientAddress');
    b.writeln('Дата: ${fmtDate(createdAt)}');
    b.writeln('');
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      b.writeln('ПОЗИЦИЯ ${i + 1}:');
      b.writeln('  ${it.type} — ${it.widthMm.toInt()}x${it.heightMm.toInt()} x${it.count}');
      b.writeln('  Профиль: ${it.profile}, Фурнитура: ${it.furniture}, Створок: ${it.sashes}');
      b.writeln('  Стеклопакет: ${it.glassThickness.toInt()} мм');
      if (it.hasSlopes) {
        b.writeln('  Откосы: ${it.slopeCategory} (${it.houseType})');
        b.writeln('    Глубина ${it.slopeDepthMm.toInt()} мм, бок ${it.slopeLengthSideMm.toInt()} мм, верх ${it.slopeLengthTopMm.toInt()} мм');
      }
      if (it.hasExtraSlopes) {
        b.writeln('  Откосы доп.: ${it.extraSlopeCategory}');
      }
      if (it.hasSill && it.sills.isNotEmpty) {
        b.writeln('  Подоконники:');
        for (var k = 0; k < it.sills.length; k++) {
          final s = it.sills[k];
          b.writeln('    ${k + 1}) ${s.lengthMm.toInt()}x${s.depthMm.toInt()} мм — ${s.category}');
        }
      }
      if (it.hasDrip) b.writeln('  Отлив: ${it.dripLengthMm.toInt()}x${it.dripDepthMm.toInt()} мм (${it.dripColor})');
      if (it.hasFUgol) b.writeln('  F-угол: ${it.fUgolType} x ${it.fUgolCount}');
      if (it.hasAbris) b.writeln('  Абрис: ${it.abrisLengthMm.toInt()} мм');
      if (it.hasPsul) b.writeln('  ПСУЛ: ${it.psulLengthMm.toInt()} мм');
      if (it.hasOtmazka) b.writeln('  Отмазка: ${it.otmazkaLengthMm.toInt()} мм');
      b.writeln('  Монтаж: ${it.calcMountPrice(priceSettings).toStringAsFixed(0)} ₽');
      if (it.calcExtrasPrice(priceSettings) > 0) {
        b.writeln('  Допы: ${it.calcExtrasPrice(priceSettings).toStringAsFixed(0)} ₽');
      }
      b.writeln('');
    }
    b.writeln('ИТОГО монтаж и допы: ${dealerMountPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}
// ═══════════════════════════════════════════════════════════
// ХРАНЕНИЕ ЗАМЕРОВ
// ═══════════════════════════════════════════════════════════

class MeasurementStorage {
  static const _key = 'measurements_v3';

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
// СЕРВИС И РЕМОНТ — МОДЕЛИ
// ═══════════════════════════════════════════════════════════

class ServiceItem {
  String type; // 'Монтаж подоконника', 'Замена ручки' и т.д.
  int count;   // количество
  double lengthMm; // для позиций "за м"
  double pricePerUnit; // цена за единицу (из прайса, можно править)
  // Для резинки
  int sashesCount;
  int blindCount;
  String rubberColor; // 'Серая' / 'Черная'
  // Для стеклопакета
  double glassWidthMm;
  double glassHeightMm;
  int glassSashesCount;
  int glassBlindCount;

  ServiceItem({
    required this.type,
    this.count = 1,
    this.lengthMm = 0,
    this.pricePerUnit = 0,
    this.sashesCount = 0,
    this.blindCount = 0,
    this.rubberColor = 'Серая',
    this.glassWidthMm = 0,
    this.glassHeightMm = 0,
    this.glassSashesCount = 0,
    this.glassBlindCount = 0,
  });

  double calcPrice(PriceSettings ps) {
    switch (type) {
      case 'Монтаж подоконника':
        return (lengthMm / 1000) * pricePerUnit;
      case 'Монтаж откоса':
        return (lengthMm / 1000) * pricePerUnit;
      case 'Монтаж сетки':
        return pricePerUnit * count;
      case 'Регулировка':
        return pricePerUnit * count;
      case 'Замена ручки':
        return pricePerUnit * count;
      case 'Замена резинки':
        final base = pricePerUnit * sashesCount;
        final extra = (pricePerUnit + ps.rubberReplaceBlindExtra) * blindCount;
        return base + extra;
      case 'Замена стеклопакета':
        final base = pricePerUnit * glassSashesCount;
        final extra = (pricePerUnit + ps.glassReplaceBlindExtra) * glassBlindCount;
        return base + extra;
      case 'Замена фурнитуры':
        return pricePerUnit * count;
      case 'Замена подоконника':
        return (lengthMm / 1000) * pricePerUnit;
      default:
        return 0;
    }
  }

  int get rubberMeters => (sashesCount + blindCount) * 8;
  int get totalGlassPieces => glassSashesCount + glassBlindCount;
  double get glassAreaM2 =>
      (glassWidthMm / 1000) * (glassHeightMm / 1000) * totalGlassPieces;

  Map<String, dynamic> toJson() => {
    'type': type,
    'count': count,
    'lengthMm': lengthMm,
    'pricePerUnit': pricePerUnit,
    'sashesCount': sashesCount,
    'blindCount': blindCount,
    'rubberColor': rubberColor,
    'glassWidthMm': glassWidthMm,
    'glassHeightMm': glassHeightMm,
    'glassSashesCount': glassSashesCount,
    'glassBlindCount': glassBlindCount,
  };

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
    type: (j['type'] ?? '').toString(),
    count: (j['count'] ?? 1) as int,
    lengthMm: (j['lengthMm'] ?? 0).toDouble(),
    pricePerUnit: (j['pricePerUnit'] ?? 0).toDouble(),
    sashesCount: (j['sashesCount'] ?? 0) as int,
    blindCount: (j['blindCount'] ?? 0) as int,
    rubberColor: (j['rubberColor'] ?? 'Серая').toString(),
    glassWidthMm: (j['glassWidthMm'] ?? 0).toDouble(),
    glassHeightMm: (j['glassHeightMm'] ?? 0).toDouble(),
    glassSashesCount: (j['glassSashesCount'] ?? 0) as int,
    glassBlindCount: (j['glassBlindCount'] ?? 0) as int,
  );
}

class ServiceMeasurement {
  String id;
  String clientName;
  String clientPhone;
  String clientAddress;
  String notes;
  List<ServiceItem> items;
  PriceSettings priceSettings;
  DateTime createdAt;

  ServiceMeasurement({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    this.notes = '',
    required this.items,
    required this.priceSettings,
    required this.createdAt,
  });

  double get totalPrice =>
      items.fold(0.0, (s, it) => s + it.calcPrice(priceSettings));

  static String fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'clientAddress': clientAddress,
    'notes': notes,
    'items': items.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory ServiceMeasurement.fromJson(Map<String, dynamic> j, PriceSettings ps) =>
      ServiceMeasurement(
        id: (j['id'] ?? '').toString(),
        clientName: (j['clientName'] ?? '').toString(),
        clientPhone: (j['clientPhone'] ?? '').toString(),
        clientAddress: (j['clientAddress'] ?? '').toString(),
        notes: (j['notes'] ?? '').toString(),
        items: ((j['items'] as List?) ?? [])
            .map((e) => ServiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        priceSettings: ps,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  String toClientText() {
    final b = StringBuffer();
    b.writeln('Здравствуйте, $clientName!');
    b.writeln('');
    b.writeln('Работы:');
    for (final it in items) {
      b.writeln('  ${it.type} — ${it.calcPrice(priceSettings).toStringAsFixed(0)} ₽');
    }
    b.writeln('');
    b.writeln('ИТОГО: ${totalPrice.toStringAsFixed(0)} ₽');
    return b.toString();
  }
}

class ServiceStorage {
  static const _key = 'service_v1';

  static Future<List<ServiceMeasurement>> load(PriceSettings ps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      final result = <ServiceMeasurement>[];
      for (final s in raw) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          result.add(ServiceMeasurement.fromJson(json, ps));
        } catch (_) {}
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<ServiceMeasurement> list) async {
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
  List<ServiceMeasurement> _serviceMeasurements = [];
  ThemeMode _themeMode = ThemeMode.system;;

  static const _themeKey = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _price = PriceSettings();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_themeKey);
      if (raw == 'light') _themeMode = ThemeMode.light;
      else if (raw == 'dark') _themeMode = ThemeMode.dark;
      else _themeMode = ThemeMode.system;
    } catch (_) {}
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = mode == ThemeMode.light
          ? 'light'
          : (mode == ThemeMode.dark ? 'dark' : 'system');
      await prefs.setString(_themeKey, str);
    } catch (_) {}
  }

  void _cycleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      _saveTheme(_themeMode);
    });
  }

Future<void> _loadData() async {
  PriceSettings ps;
  List<Measurement> ms;
  List<ServiceMeasurement> sm;
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
  try {
    sm = await ServiceStorage.load(ps);
  } catch (_) {
    sm = [];
  }
  await _loadTheme();
  if (!mounted) return;
  setState(() {
    _price = ps;
    _measurements = ms;
    _serviceMeasurements = sm;
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

Future<void> _saveServiceMeasurements() async {
  try {
    await ServiceStorage.save(_serviceMeasurements);
  } catch (_) {}
}
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: SplashScreen(
        loadData: _loadData,
        buildMainMenu: () => MainMenuScreen(
  price: _price!,
  measurements: _measurements,
  serviceMeasurements: _serviceMeasurements,
  onPriceChanged: _savePrice,
          onMeasurementAdded: (m) {
            setState(() => _measurements.insert(0, m));
            _saveMeasurements();          onCycleTheme: _cycleTheme,
          themeMode: _themeMode,
          onServiceAdded: (m) {
            setState(() => _serviceMeasurements.insert(0, m));
            _saveServiceMeasurements();
          },
          onServiceDeleted: (id) {
            setState(() =>
                _serviceMeasurements.removeWhere((m) => m.id == id));
            _saveServiceMeasurements();
          },
        ),
      ),
    );
  }
          }
          },
          onMeasurementDeleted: (id) {
            setState(() => _measurements.removeWhere((m) => m.id == id));
            _saveMeasurements();
          },
          onMeasurementUpdated: (updated) {
            setState(() {
              final idx = _measurements.indexWhere((m) => m.id == updated.id);
              if (idx >= 0) _measurements[idx] = updated;
            });
            _saveMeasurements();
          },
          onCycleTheme: _cycleTheme,
          themeMode: _themeMode,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ГЛАВНОЕ МЕНЮ
// ═══════════════════════════════════════════════════════════

class MainMenuScreen extends StatelessWidget {
  final PriceSettings price;
  final List<Measurement> measurements;
  final List<ServiceMeasurement> serviceMeasurements;
  final Future<void> Function() onPriceChanged;
  final Function(Measurement) onMeasurementAdded;
  final Function(String) onMeasurementDeleted;
  final Function(Measurement) onMeasurementUpdated;
  final VoidCallback onCycleTheme;
  final ThemeMode themeMode;
  final Function(ServiceMeasurement) onServiceAdded;
  final Function(String) onServiceDeleted;

const MainMenuScreen({
  super.key,
  required this.price,
  required this.measurements,
  required this.serviceMeasurements,
    required this.onPriceChanged,
    required this.onMeasurementAdded,
    required this.onMeasurementDeleted,
    required this.onMeasurementUpdated,
    required this.onCycleTheme,
    required this.themeMode,
    required this.onServiceAdded,
    required this.onServiceDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Замерщик окон Almas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final v = snapshot.data?.version ?? '';
              if (v.isEmpty) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'v$v',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Тема',
            icon: Icon(
              themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : (themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.brightness_auto),
            ),
            onPressed: onCycleTheme,
          ),
        ],
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
                    onUpdate: onMeasurementUpdated,
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
            subtitle: 'Цены и коэффициенты',
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
              
    _menuCard(
      context,
      icon: Icons.build,
      color: Colors.teal,
      title: 'Сервис и ремонт',
      subtitle: 'Отдельные работы',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceListScreen(
              price: price,
              measurements: const [],
              onAdded: (_) {},
              onDeleted: (_) {},
            ),
          ),
        );
      },
    ),
    _menuCard(
      context,
      icon: Icons.system_update,
      color: Colors.purple,
      title: 'Проверить обновление',
      subtitle: 'Диагностика + обновление',
      onTap: () => _showUpdateReport(context),
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

  Future<void> _showUpdateReport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final report = await UpdateChecker.getReport();

    if (context.mounted) Navigator.pop(context);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Проверка обновления'),
        content: SingleChildScrollView(
          child: SelectableText(report),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          if (report.contains('ДОСТУПНО ОБНОВЛЕНИЕ'))
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                final msg = await UpdateChecker.downloadAndInstall();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              },
              child: const Text('Обновить'),
            ),
        ],
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
  final Function(Measurement) onUpdate;
  const SavedMeasurementsScreen({
    super.key,
    required this.measurements,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<SavedMeasurementsScreen> createState() => _SavedMeasurementsScreenState();
}

class _SavedMeasurementsScreenState extends State<SavedMeasurementsScreen> {
  late List<Measurement> _list;
  bool _sortDesc = true;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.measurements);
    _applySort();
  }

  void _applySort() {
    _list.sort((a, b) => _sortDesc
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
  }

  void _toggleSort() {
    setState(() {
      _sortDesc = !_sortDesc;
      _applySort();
    });
  }

  void _delete(String id) {
    setState(() {
      _list.removeWhere((m) => m.id == id);
      _applySort();
    });
    widget.onDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранённые замеры'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: _sortDesc ? 'Свежие сверху' : 'Старые сверху',
            onPressed: _toggleSort,
          ),
        ],
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(
                          measurement: m,
                          onUpdate: (updated) {
                            final idx = _list.indexWhere((x) => x.id == updated.id);
                            if (idx >= 0) {
                              setState(() => _list[idx] = updated);
                            }
                            widget.onUpdate(updated);
                          },
                        ),
                      ),
                    );
                  },
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
// НАСТРОЙКИ ПРАЙСА
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
    for (var c in _ctrls.values) {
      c.dispose();
    }
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
    p.furRoto = g('furRoto');
    p.furMaco = g('furMaco');
    p.furReze = g('furReze');
    p.furOther = g('furOther');
    p.coefRehau = g('coefRehau');
    p.coefBauline = g('coefBauline');
    p.coefNovoline = g('coefNovoline');
    p.coefBrusbox = g('coefBrusbox');
    p.coefVeka = g('coefVeka');
    p.coefKBE = g('coefKBE');
    p.coefOther = g('coefOther');
    p.sillEconomPerM2 = g('sillEconomPerM2');
    p.sillOtherPerM2 = g('sillOtherPerM2');
    p.dripWhitePerM2 = g('dripWhitePerM2');
    p.dripBrownPerM2 = g('dripBrownPerM2');
    p.slopePiterPerM2 = g('slopePiterPerM2');
    p.slopeEconomPerM2 = g('slopeEconomPerM2');
    p.slopeExtraPiterPerM2 = g('slopeExtraPiterPerM2');
    p.slopeExtraEconomPerM2 = g('slopeExtraEconomPerM2');
    p.mountSlopesPerM2 = g('mountSlopesPerM2');
    p.mountSillPerM2 = g('mountSillPerM2');
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
    p.delivery = g('delivery');
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

  Widget _row(String label, String key, {String suffix = '₽', bool isCoef = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _ctrls[key],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                suffixText: isCoef ? 'x' : suffix,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(String title, IconData icon, List<Widget> children) {
    final isOpen = _expanded.contains(title);
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
                  _expanded.remove(title);
                } else {
                  _expanded.add(title);
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

  Widget _subtitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
      );
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
            _subtitle('Базовые цены (для профиля Novoline)'),
            _row('Одностворчатое', 'window1'),
            _row('Двухстворчатое', 'window2'),
            _row('Трёхстворчатое', 'window3'),
          ]),
          _category('Балконы и лоджии', Icons.balcony, [
            _row('Балконный блок', 'balconyBlock'),
            _subtitle('За м²'),
            _row('Балконное остекление', 'balconyGlazingPerM2', suffix: '₽/м²'),
            _row('Остекление лоджии', 'loggiaGlazingPerM2', suffix: '₽/м²'),
            _row('Панорамное остекление', 'panoramicPerM2', suffix: '₽/м²'),
          ]),
          _category('Двери', Icons.door_front_door, [
            _row('Балконная дверь', 'balconyDoor'),
            _row('Дверь ПВХ', 'pvcDoor'),
            _row('Входная группа', 'entranceGroup'),
          ]),
          _category('Профили (коэффициенты)', Icons.layers, [
            _subtitle('Множитель к базовой цене'),
            _row('Rehau', 'coefRehau', isCoef: true),
            _row('Bauline', 'coefBauline', isCoef: true),
            _row('Novoline', 'coefNovoline', isCoef: true),
            _row('Brusbox', 'coefBrusbox', isCoef: true),
            _row('Veka', 'coefVeka', isCoef: true),
            _row('KBE', 'coefKBE', isCoef: true),
            _row('Другой', 'coefOther', isCoef: true),
          ]),
          _category('Фурнитура (за створку)', Icons.build, [
            _subtitle('Цена за 1 створку'),
            _row('Roto', 'furRoto'),
            _row('Maco', 'furMaco'),
            _row('Reze', 'furReze'),
            _row('Другой', 'furOther'),
          ]),
          _category('Отделка', Icons.construction, [
            _subtitle('Подоконник (за м²)'),
            _row('Эконом', 'sillEconomPerM2', suffix: '₽/м²'),
            _row('Другое', 'sillOtherPerM2', suffix: '₽/м²'),
            _subtitle('Отлив (за м²)'),
            _row('Белый', 'dripWhitePerM2', suffix: '₽/м²'),
            _row('Коричневый', 'dripBrownPerM2', suffix: '₽/м²'),
            _subtitle('Откосы (за м²)'),
            _row('Питер', 'slopePiterPerM2', suffix: '₽/м²'),
            _row('Эконом', 'slopeEconomPerM2', suffix: '₽/м²'),
            _subtitle('Откосы доп. (за м²)'),
            _row('Питер', 'slopeExtraPiterPerM2', suffix: '₽/м²'),
            _row('Эконом', 'slopeExtraEconomPerM2', suffix: '₽/м²'),
            _subtitle('Монтаж отдельно (за м²)'),
            _row('Монтаж откосов', 'mountSlopesPerM2', suffix: '₽/м²'),
            _row('Монтаж подоконников', 'mountSillPerM2', suffix: '₽/м²'),
            _subtitle('F-угол (за шт)'),
            _row('40×3.20', 'fUgol40'),
            _row('50×3.20', 'fUgol50'),
            _row('60×3.20', 'fUgol60'),
            _subtitle('Ленты и замазка (за м)'),
            _row('Абрис', 'abrisPerM', suffix: '₽/м'),
            _row('ПСУЛ', 'psulPerM', suffix: '₽/м'),
            _row('Отмазка', 'otmazkaPerM', suffix: '₽/м'),
          ]),
          _category('Сетки (за шт)', Icons.grid_on, [
            _row('Москитная', 'mosquito'),
            _row('Антикошка', 'anticat'),
            _row('Антипыль', 'antidust'),
            _row('Рамная', 'frameNet'),
            _row('Плиссе', 'plisse'),
          ]),
          _category('Стеклопакеты (за м²)', Icons.window_sharp, [
            _row('24 мм', 'glass24', suffix: '₽/м²'),
            _row('32 мм', 'glass32', suffix: '₽/м²'),
            _row('40 мм', 'glass40', suffix: '₽/м²'),
            _subtitle('Доплаты (за м²)'),
            _row('Тонировка', 'extraTinting', suffix: '₽/м²'),
            _row('Мультифункция', 'extraMulti', suffix: '₽/м²'),
          ]),
          _category('Услуги', Icons.handyman, [
            _row('Демонтаж (за изделие)', 'demontagePerItem'),
            _row('Монтаж (за изделие)', 'montagePerItem'),
            _row('Вывоз мусора', 'trashRemoval'),
            _row('Подъём (за этаж)', 'liftPerFloor'),
            _row('Доставка', 'delivery'),
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
  final _liftFloorsCtrl = TextEditingController(text: '1');
  final List<ProductItem> _items = [ProductItem()];

  bool _hasTrashRemoval = false;
  bool _hasLift = false;
  bool _hasDelivery = false;

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
      hasDelivery: _hasDelivery,
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
    if (_hasLift) t += widget.price.liftPerFloor * (int.tryParse(_liftFloorsCtrl.text) ?? 1);
    if (_hasDelivery) t += widget.price.delivery;
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
            title: Text('Подъём (${widget.price.liftPerFloor.toStringAsFixed(0)} ₽/этаж)'),
            dense: true,
          ),
          if (_hasLift)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: TextField(
                controller: _liftFloorsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Этажей'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          CheckboxListTile(
            value: _hasDelivery,
            onChanged: (v) => setState(() => _hasDelivery = v!),
            title: Text('Доставка (${widget.price.delivery.toStringAsFixed(0)} ₽)'),
            dense: true,
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
                DropdownMenuItem(value: 'Фасадное алюминиевое остекление', child: Text('Фасадное алюм.')),
              ],
              onChanged: (v) => setState(() {
                it.type = v!;
                it.sashes = ProductItem.defaultSashes(v);
              }),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: it.profile,
              decoration: const InputDecoration(labelText: 'Профиль'),
              items: const [
                DropdownMenuItem(value: 'Rehau', child: Text('Rehau')),
                DropdownMenuItem(value: 'Bauline', child: Text('Bauline')),
                DropdownMenuItem(value: 'Novoline', child: Text('Novoline')),
                DropdownMenuItem(value: 'Brusbox', child: Text('Brusbox')),
                DropdownMenuItem(value: 'Veka', child: Text('Veka')),
                DropdownMenuItem(value: 'KBE', child: Text('KBE')),
                DropdownMenuItem(value: 'Другой', child: Text('Другой')),
              ],
              onChanged: (v) => setState(() => it.profile = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: it.furniture,
              decoration: const InputDecoration(labelText: 'Фурнитура'),
              items: const [
                DropdownMenuItem(value: 'Roto', child: Text('Roto')),
                DropdownMenuItem(value: 'Maco', child: Text('Maco')),
                DropdownMenuItem(value: 'Reze', child: Text('Reze')),
                DropdownMenuItem(value: 'Другой', child: Text('Другой')),
              ],
              onChanged: (v) => setState(() => it.furniture = v!),
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
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: it.count.toString(),
                    decoration: const InputDecoration(labelText: 'Кол-во'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.count = int.tryParse(v) ?? 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: it.sashes.toString(),
                    decoration: const InputDecoration(labelText: 'Створок'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.sashes = int.tryParse(v) ?? 1),
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
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      value: it.slopeCategory,
      decoration: const InputDecoration(labelText: 'Категория'),
      items: const [
        DropdownMenuItem(value: 'Питер', child: Text('Питер')),
        DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
      ],
      onChanged: (v) => setState(() => it.slopeCategory = v!),
    ),
    const SizedBox(height: 6),
    Row(children: [
      Expanded(child: TextFormField(
        initialValue: it.slopeDepthMm.toStringAsFixed(0),
        decoration: const InputDecoration(labelText: 'Глубина, мм'),
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() => it.slopeDepthMm = double.tryParse(v) ?? 0),
      )),
      const SizedBox(width: 8),
      Expanded(child: TextFormField(
        initialValue: it.slopeLengthSideMm.toStringAsFixed(0),
        decoration: const InputDecoration(labelText: 'Бок, мм'),
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() => it.slopeLengthSideMm = double.tryParse(v) ?? 0),
      )),
    ]),
    const SizedBox(height: 6),
    TextFormField(
      initialValue: it.slopeLengthTopMm.toStringAsFixed(0),
      decoration: const InputDecoration(labelText: 'Верх, мм'),
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() => it.slopeLengthTopMm = double.tryParse(v) ?? 0),
    ),
    CheckboxListTile(
      value: it.mountSlopesSeparately,
      onChanged: (v) => setState(() => it.mountSlopesSeparately = v!),
      title: const Text('Монтаж откосов отдельно'),
      dense: true,
    ),
  ]),
),
CheckboxListTile(
  value: it.hasExtraSlopes,
  onChanged: (v) => setState(() => it.hasExtraSlopes = v!),
  title: const Text('Откосы доп. (с улицы)'),
  dense: true,
),
if (it.hasExtraSlopes) Padding(
  padding: const EdgeInsets.only(left: 16, bottom: 8),
  child: Column(children: [
    DropdownButtonFormField<String>(
      value: it.extraSlopeCategory,
      decoration: const InputDecoration(labelText: 'Категория'),
      items: const [
        DropdownMenuItem(value: 'Питер', child: Text('Питер')),
        DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
      ],
      onChanged: (v) => setState(() => it.extraSlopeCategory = v!),
    ),
    const SizedBox(height: 6),
    Row(children: [
      Expanded(child: TextFormField(
        initialValue: it.extraSlopeDepthMm.toStringAsFixed(0),
        decoration: const InputDecoration(labelText: 'Глубина, мм'),
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() => it.extraSlopeDepthMm = double.tryParse(v) ?? 0),
      )),
      const SizedBox(width: 8),
      Expanded(child: TextFormField(
        initialValue: it.extraSlopeLengthSideMm.toStringAsFixed(0),
        decoration: const InputDecoration(labelText: 'Бок, мм'),
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() => it.extraSlopeLengthSideMm = double.tryParse(v) ?? 0),
      )),
    ]),
    const SizedBox(height: 6),
    TextFormField(
      initialValue: it.extraSlopeLengthTopMm.toStringAsFixed(0),
      decoration: const InputDecoration(labelText: 'Верх, мм'),
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() => it.extraSlopeLengthTopMm = double.tryParse(v) ?? 0),
    ),
  ]),
),
CheckboxListTile(
  value: it.hasSill,
  onChanged: (v) => setState(() {
    it.hasSill = v!;
    if (v && it.sills.isEmpty) {
      final len = it.hasSlopes
          ? (it.slopeLengthTopMm + 200)
          : (it.widthMm + 400);
      final dep = it.hasSlopes
          ? (it.slopeDepthMm + 50)
          : 250.0;
      it.sills = [SillItem(lengthMm: len, depthMm: dep)];
    }
  }),
  title: const Text('Подоконники'),
  dense: true,
),
if (it.hasSill) Padding(
  padding: const EdgeInsets.only(left: 16, bottom: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var k = 0; k < it.sills.length; k++)
        Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Подоконник ${k + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (it.sills.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => setState(() => it.sills.removeAt(k)),
                      ),
                  ],
                ),
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.sills[k].lengthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Длина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.sills[k].lengthMm = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.sills[k].depthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.sills[k].depthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                DropdownButtonFormField<String>(
                  value: it.sills[k].category,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: const [
                    DropdownMenuItem(value: 'Эконом', child: Text('Эконом')),
                    DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                  ],
                  onChanged: (v) => setState(() => it.sills[k].category = v!),
                ),
              ],
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: () => setState(() {
          it.sills.add(SillItem(
            lengthMm: it.widthMm + 400,
            depthMm: 250,
          ));
        }),
        icon: const Icon(Icons.add),
        label: const Text('Добавить подоконник'),
      ),
      CheckboxListTile(
        value: it.mountSillSeparately,
        onChanged: (v) => setState(() => it.mountSillSeparately = v!),
        title: const Text('Монтаж подоконников отдельно'),
        dense: true,
      ),
    ],
  ),
),
                        CheckboxListTile(
              value: it.hasDrip,
              onChanged: (v) => setState(() {
                it.hasDrip = v!;
                if (v) it.dripLengthMm = it.widthMm;
              }),
              title: const Text('Отлив'),
              dense: true,
            ),
            if (it.hasDrip) Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(children: [
                Row(children: [
                  Expanded(child: TextFormField(
                    initialValue: it.dripLengthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Длина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.dripLengthMm = double.tryParse(v) ?? 0),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    initialValue: it.dripDepthMm.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: 'Глубина, мм'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => it.dripDepthMm = double.tryParse(v) ?? 0),
                  )),
                ]),
                const SizedBox(height: 6),
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
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: it.fUgolCount.toString(),
                  decoration: const InputDecoration(labelText: 'Количество, шт'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => it.fUgolCount = int.tryParse(v) ?? 1),
                ),
              ]),
            ),
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
                initialValue: it.abrisLengthMm.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Длина, мм'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.abrisLengthMm = double.tryParse(v) ?? 0),
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
                initialValue: it.psulLengthMm.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Длина, мм'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.psulLengthMm = double.tryParse(v) ?? 0),
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
                initialValue: it.otmazkaLengthMm.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Длина, мм'),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => it.otmazkaLengthMm = double.tryParse(v) ?? 0),
              ),
            ),
            const Divider(),
            const Text('Сетки', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            CheckboxListTile(value: it.hasMosquito, onChanged: (v) => setState(() => it.hasMosquito = v!), title: const Text('Москитная'), dense: true),
            CheckboxListTile(value: it.hasAnticat, onChanged: (v) => setState(() => it.hasAnticat = v!), title: const Text('Антикошка'), dense: true),
            CheckboxListTile(value: it.hasAntidust, onChanged: (v) => setState(() => it.hasAntidust = v!), title: const Text('Антипыль'), dense: true),
            CheckboxListTile(value: it.hasFrameNet, onChanged: (v) => setState(() => it.hasFrameNet = v!), title: const Text('Рамная'), dense: true),
            CheckboxListTile(value: it.hasPlisse, onChanged: (v) => setState(() => it.hasPlisse = v!), title: const Text('Плиссе'), dense: true),
            const Divider(),
            CheckboxListTile(
              value: it.complexInstall,
              onChanged: (v) => setState(() => it.complexInstall = v!),
              title: const Text('Комплекс (монтаж + демонтаж)'),
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

class ResultScreen extends StatefulWidget {
  final Measurement measurement;
  final Function(Measurement)? onUpdate;
  const ResultScreen({super.key, required this.measurement, this.onUpdate});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Measurement m;

  @override
  void initState() {
    super.initState();
    m = widget.measurement;
  }

  Future<void> _setCustomPrice() async {
    final ctrl = TextEditingController(
      text: m.customClientPrice?.toStringAsFixed(0) ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Своя цена для клиента'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Расчётная: ${m.totalPrice.toStringAsFixed(0)} ₽',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Итоговая цена, ₽',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Оставьте пустым — будет расчётная',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != null || ctrl.text.trim().isEmpty) {
      setState(() => m.customClientPrice = result);
      widget.onUpdate?.call(m);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Text('${e.key + 1}. ${it.type} — ${it.widthMm.toInt()}x${it.heightMm.toInt()} мм x ${it.count}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('   ${it.profile} • ${it.furniture} • ${it.sashes} ств.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('   Стекло ${it.glassThickness.toInt()} мм', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (it.hasSlopes) Text('   Откосы: ${it.slopeCategory} (${it.houseType})', style: const TextStyle(fontSize: 12)),
                          if (it.hasSill && it.sills.isNotEmpty) Text('   Подоконники: ${it.sills.length} шт', style: const TextStyle(fontSize: 12)),
                          if (it.hasDrip) Text('   Отлив: ${it.dripColor}', style: const TextStyle(fontSize: 12)),
                          if (it.hasFUgol) Text('   F-угол: ${it.fUgolType} x ${it.fUgolCount}', style: const TextStyle(fontSize: 12)),
                          Text('   ${it.calcPrice(m.priceSettings).toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }),
                  if (m.hasTrashRemoval || m.hasLift || m.hasDelivery) ...[
                    const Divider(height: 24),
                    const Text('Услуги:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (m.hasTrashRemoval) Text('• Вывоз мусора — ${m.priceSettings.trashRemoval.toStringAsFixed(0)} ₽'),
                    if (m.hasLift) Text('• Подъём на ${m.liftFloors} эт. — ${(m.priceSettings.liftPerFloor * m.liftFloors).toStringAsFixed(0)} ₽'),
                    if (m.hasDelivery) Text('• Доставка — ${m.priceSettings.delivery.toStringAsFixed(0)} ₽'),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Расчётная цена:', style: TextStyle(fontSize: 15)),
                      Text('${m.totalPrice.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (m.customClientPrice != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Цена для клиента:', style: TextStyle(fontSize: 15, color: Colors.green)),
                        Text('${m.customClientPrice!.toStringAsFixed(0)} ₽',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _setCustomPrice,
            icon: const Icon(Icons.edit),
            label: Text(m.customClientPrice == null
                ? 'Указать свою цену для клиента'
                : 'Изменить цену для клиента'),
          ),
          const SizedBox(height: 20),
          const Text('Поделиться:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _shareButton(context, Icons.factory, '🏭 Отправить на завод',
              'Техданные (профиль, фурнитура, размеры)', Colors.orange, m.toFactoryText()),
          _shareButton(context, Icons.person, '👤 Отправить клиенту',
              'Красивое описание + цена', Colors.green, m.toClientText()),
          _shareButton(context, Icons.handshake, '🤝 Отправить дилеру',
              'Размеры + цены за монтаж и допы', Colors.purple, m.toDealerText()),
          _shareButton(context, Icons.copy, '📋 Скопировать текст для клиента',
              'В буфер обмена', Colors.blue, m.toClientText(), copyOnly: true),
        ],
      ),
    );
  }

  Widget _shareButton(
    BuildContext context,
    IconData icon,
    String label,
    String sub,
    Color color,
    String text, {
    bool copyOnly = false,
  }) {
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
