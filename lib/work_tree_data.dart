part of 'work_tree.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ДАННЫЕ ДЕРЕВА ВИДОВ РАБОТ  ·  v3.4.31
///  Дерево собрано из ОДИНАКОВЫХ КАРТОЧЕК — одна карточка = один пункт.
///  • 1-й уровень: 4 ОТДЕЛЬНЫЕ карточки (ЗАМЕР, МОНТАЖ, РЕМОНТ, РЕКЛАМАЦИИ).
///  • Нажал карточку → справа вырастает столбик её подпунктов.
///  • НИКАКОЙ общей карточки-обёртки с меню внутри.
///  • Автоскролл вправо + ручной скролл вперёд/назад.
///  • Финальный уровень (комплектация) — МУЛЬТИВЫБОР: можно отметить
///    один пункт, несколько или все. Есть хоть одна отметка — мастер
///    показывает кнопку «ПОДТВЕРДИТЬ».
/// ═══════════════════════════════════════════════════════════════════

/// Ветка дерева: иконка + название + подпункты.
class WorkNode {
  const WorkNode(this.icon, this.title, [this.children = const []]);
  final IconData icon;
  final String title;
  final List<WorkNode> children;
}

/// Стеклопакет — выбор ПОД визуальным окном (в дерево не входит).
const List<WorkNode> glassTypes = [
  WorkNode(Icons.crop_square_rounded, 'ОДНОКАМЕРНЫЙ'),
  WorkNode(Icons.layers_rounded, 'ДВУХКАМЕРНЫЙ'),
  WorkNode(Icons.layers_clear_rounded, 'ТРЁХКАМЕРНЫЙ'),
  WorkNode(Icons.energy_savings_leaf_rounded, 'ЭНЕРГОСБЕРЕГАЮЩИЙ'),
  WorkNode(Icons.shield_rounded, 'УДАРОПРОЧНЫЙ'),
  WorkNode(Icons.blur_on_rounded, 'МАТОВЫЙ'),
];

/// Финальный уровень дерева — КОМПЛЕКТАЦИЯ. Мультивыбор.
/// Это ПОСЛЕДНИЕ пункты: дальше дерево не растёт.
const List<WorkNode> finishingTypes = [
  WorkNode(Icons.window_rounded, 'ПРОСТО ОКНО'),
  WorkNode(Icons.water_drop_rounded, 'С ОТЛИВОМ'),
  WorkNode(Icons.shelves, 'С ПОДОКОННИКОМ'),
  WorkNode(Icons.architecture_rounded, 'С ОТКОСАМИ'),
  WorkNode(Icons.change_history_rounded, 'АБРИС'),
  WorkNode(Icons.linear_scale_rounded, 'ПСУЛ'),
  WorkNode(Icons.cleaning_services_rounded, 'ОТМАЗКА'),
  WorkNode(Icons.compare_arrows_rounded, 'ОТМАЗКА С ДВУХ СТОРОН'),
];

/// Козырёк бывает ТОЛЬКО на балконе / лоджии — у окна его нет.
/// Длина считается АВТОМАТИЧЕСКИ: ширина изделия + 200 мм
/// (балкон 3000 → козырёк 3200). Из двух частей: каждая = половина +
/// нахлёст 150 мм (балкон 3000 → 3200 → по 1750 мм).
const List<WorkNode> balconyFinishing = [
  ...finishingTypes,
  WorkNode(Icons.roofing_rounded, 'КОЗЫРЁК'),
  WorkNode(Icons.splitscreen_rounded, 'КОЗЫРЁК ИЗ 2 ЧАСТЕЙ'),
];

/// ═══════════════════════════════════════════════════════════════════
///  ЧЕГО НЕ БЫВАЕТ ПРИ РАБОТЕ
///  ПСУЛ (уплотнение), АБРИС (наличник) и замена резинки — работы
///  по проёму: подоконник при них не ставится, поэтому пункт
///  «С ПОДОКОННИКОМ» из комплектации ГАСНЕТ.
/// ═══════════════════════════════════════════════════════════════════
const List<String> noSillWorks = ['ПСУЛ', 'АБРИС', 'ЗАМЕНА РЕЗИНКИ'];

/// Пункты комплектации, которые убираем при работах из [noSillWorks].
const List<String> noSillParts = ['С ПОДОКОННИКОМ'];

/// Убрать из финального уровня пункты, которых НЕ БЫВАЕТ при выбранной
/// работе. [picked] — цепочка дерева + отмеченная комплектация.
List<WorkNode> finishFor(List<WorkNode> nodes, List<String> picked) {
  final all = picked.join(' ').toUpperCase();
  if (!noSillWorks.any(all.contains)) return nodes;
  return [
    for (final n in nodes)
      if (!noSillParts.contains(n.title)) n,
  ];
}

/// Тип дома — 3-й уровень дерева (после выбора изделия и его вида).
/// Дальше идёт финальный уровень — комплектация (мультивыбор).
const List<WorkNode> houseTypes = [
  WorkNode(Icons.grid_on_rounded, 'КИРПИЧКА', finishingTypes),
  WorkNode(Icons.view_module_rounded, 'ПАНЕЛЬКА', finishingTypes),
  WorkNode(Icons.holiday_village_rounded, 'ХРУЩЁВКА', finishingTypes),
  WorkNode(Icons.account_balance_rounded, 'СТАЛИНКА', finishingTypes),
  WorkNode(Icons.cottage_rounded, 'ДЕРЕВЯННЫЙ ДОМ', finishingTypes),
  WorkNode(Icons.widgets_rounded, 'ИЗ БЛОКА', finishingTypes),
];

/// ─── ВИДЫ ИЗДЕЛИЙ (3-й уровень дерева) ───
/// У КАЖДОГО изделия СВОЁ дерево: вид изделия → тип дома → комплектация.
/// Пустых веток нет — галочка-квадратик появляется ТОЛЬКО на финальном
/// уровне (комплектация), а не на изделии.
const List<WorkNode> windowKinds = [
  WorkNode(Icons.crop_portrait_rounded, 'ОДНОСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.splitscreen_rounded, 'ДВУХСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.view_column_rounded, 'ТРЁХСТВОРЧАТОЕ', houseTypes),
  WorkNode(Icons.polyline_rounded, 'ФИГУРНОЕ', houseTypes),
];

// Комплектация БАЛКОННОГО БЛОКА. Козырька здесь НЕТ —
// козырёк бывает только у БАЛКОНА и ЛОДЖИИ (balconyFinishing).
const List<WorkNode> balconyBlockFinishing = [
  WorkNode(Icons.window_rounded, 'ПРОСТО ОКНО'),
  WorkNode(Icons.water_drop_rounded, 'С ОТЛИВОМ'),
  WorkNode(Icons.shelves, 'С ПОДОКОННИКОМ'),
  WorkNode(Icons.architecture_rounded, 'С ОТКОСАМИ'),
  // Откосы с двух сторон: внутренние + наружные.
  WorkNode(Icons.compare_arrows_rounded, 'ОТКОСЫ С ДВУХ СТОРОН'),
  WorkNode(Icons.change_history_rounded, 'АБРИС'),
  WorkNode(Icons.linear_scale_rounded, 'ПСУЛ'),
  WorkNode(Icons.cleaning_services_rounded, 'ОТМАЗКА'),
  WorkNode(Icons.compare_arrows_rounded, 'ОТМАЗКА С ДВУХ СТОРОН'),
];

const List<WorkNode> balconyBlockHouseTypes = [
  WorkNode(Icons.grid_on_rounded, 'КИРПИЧКА', balconyBlockFinishing),
  WorkNode(Icons.view_module_rounded, 'ПАНЕЛЬКА', balconyBlockFinishing),
  WorkNode(Icons.holiday_village_rounded, 'ХРУЩЁВКА', balconyBlockFinishing),
  WorkNode(Icons.account_balance_rounded, 'СТАЛИНКА', balconyBlockFinishing),
  WorkNode(Icons.cottage_rounded, 'ДЕРЕВЯННЫЙ ДОМ', balconyBlockFinishing),
  WorkNode(Icons.widgets_rounded, 'ИЗ БЛОКА', balconyBlockFinishing),
];

// Балконный блок И ТАК идёт с дверью — отдельный пункт «С ДВЕРЬЮ» убран.
const List<WorkNode> balconyBlockKinds = [
  WorkNode(Icons.crop_square_rounded, 'ГЛУШНЯК', balconyBlockHouseTypes),
  WorkNode(Icons.splitscreen_rounded, 'ДВУХСТВОРЧАТЫЙ', balconyBlockHouseTypes),
  WorkNode(Icons.view_column_rounded, 'ТРЁХСТВОРЧАТЫЙ', balconyBlockHouseTypes),
];

/// ФОРМА БАЛКОНА — уровень дерева после вида работ.
/// Дальше идёт комплектация: подоконник, отлив, козырёк.
const List<WorkNode> balconyShapes = [
  WorkNode(Icons.horizontal_rule_rounded, 'ПРЯМОЙ', balconyFinishing),
  WorkNode(Icons.space_bar_rounded, 'П-ОБРАЗНЫЙ', balconyFinishing),
  WorkNode(Icons.turn_right_rounded, 'Г-ОБРАЗНЫЙ', balconyFinishing),
  WorkNode(Icons.remove_circle_outline_rounded, 'БЕЗ ПАРАПЕТА',
      balconyFinishing),
];

// «УГЛОВОЙ» убран: угловой балкон = Г-ОБРАЗНЫЙ (он есть в balconyShapes).
const List<WorkNode> balconyKinds = [
  WorkNode(Icons.window_rounded, 'ОСТЕКЛЕНИЕ', balconyShapes),
  WorkNode(Icons.open_in_full_rounded, 'С ВЫНОСОМ', balconyShapes),
  WorkNode(Icons.roofing_rounded, 'С КРЫШЕЙ', balconyShapes),
];

// Лоджия — тоже балкон, поэтому комплектация С КОЗЫРЬКОМ (как у балкона).
const List<WorkNode> loggiaHouseTypes = [
  WorkNode(Icons.grid_on_rounded, 'КИРПИЧКА', balconyFinishing),
  WorkNode(Icons.view_module_rounded, 'ПАНЕЛЬКА', balconyFinishing),
  WorkNode(Icons.holiday_village_rounded, 'ХРУЩЁВКА', balconyFinishing),
  WorkNode(Icons.account_balance_rounded, 'СТАЛИНКА', balconyFinishing),
  WorkNode(Icons.cottage_rounded, 'ДЕРЕВЯННЫЙ ДОМ', balconyFinishing),
  WorkNode(Icons.widgets_rounded, 'ИЗ БЛОКА', balconyFinishing),
];

const List<WorkNode> loggiaKinds = [
  WorkNode(Icons.window_rounded, 'ОСТЕКЛЕНИЕ', loggiaHouseTypes),
  WorkNode(Icons.open_in_full_rounded, 'С ВЫНОСОМ', loggiaHouseTypes),
  WorkNode(Icons.swap_horiz_rounded, 'РАЗДВИЖНАЯ', loggiaHouseTypes),
  WorkNode(Icons.crop_landscape_rounded, 'УГЛОВАЯ', loggiaHouseTypes),
];

const List<WorkNode> doorKinds = [
  WorkNode(Icons.door_front_door_rounded, 'БАЛКОННАЯ ПВХ', houseTypes),
  WorkNode(Icons.door_back_door_rounded, 'ВХОДНАЯ ПВХ', houseTypes),
  WorkNode(Icons.door_sliding_rounded, 'РАЗДВИЖНАЯ', houseTypes),
  WorkNode(Icons.sensor_door_rounded, 'АЛЮМИНИЕВАЯ', houseTypes),
];

const List<WorkNode> slopeKinds = [
  WorkNode(Icons.architecture_rounded, 'ВНУТРЕННИЕ', houseTypes),
  WorkNode(Icons.water_drop_rounded, 'НАРУЖНЫЕ', houseTypes),
  WorkNode(Icons.compare_arrows_rounded, 'ВНУТРЕННИЕ И НАРУЖНЫЕ', houseTypes),
  WorkNode(Icons.crop_landscape_rounded, 'УГЛОВЫЕ', houseTypes),
];

const List<WorkNode> flashingKinds = [
  WorkNode(Icons.water_drop_rounded, 'МЕТАЛЛИЧЕСКИЙ', houseTypes),
  WorkNode(Icons.window_rounded, 'ПЛАСТИКОВЫЙ', houseTypes),
  WorkNode(Icons.linear_scale_rounded, 'С ЗАГЛУШКАМИ', houseTypes),
  WorkNode(Icons.open_in_full_rounded, 'ШИРОКИЙ', houseTypes),
];

const List<WorkNode> sillKinds = [
  WorkNode(Icons.shelves, 'ПВХ', houseTypes),
  WorkNode(Icons.layers_rounded, 'ЛАМИНИРОВАННЫЙ', houseTypes),
  WorkNode(Icons.linear_scale_rounded, 'С ЗАГЛУШКАМИ', houseTypes),
  WorkNode(Icons.build_rounded, 'С КРОНШТЕЙНАМИ', houseTypes),
];

const List<WorkNode> facadeKinds = [
  WorkNode(Icons.grid_on_rounded, 'СТОЙКА-РИГЕЛЬ', houseTypes),
  WorkNode(Icons.blur_on_rounded, 'СПАЙДЕР', houseTypes),
  WorkNode(Icons.view_module_rounded, 'СТРУКТУРНОЕ', houseTypes),
  WorkNode(Icons.roofing_rounded, 'ЗЕНИТНЫЙ ФОНАРЬ', houseTypes),
];

/// Финальный уровень для монтажа, ремонта и рекламаций — работы по месту.
const List<WorkNode> serviceTypes = [
  WorkNode(Icons.cleaning_services_rounded, 'БЕЗ УБОРКИ'),
  WorkNode(Icons.auto_awesome_rounded, 'С УБОРКОЙ'),
  WorkNode(Icons.water_drop_rounded, 'С ОТЛИВОМ'),
  WorkNode(Icons.linear_scale_rounded, 'ПСУЛ'),
  WorkNode(Icons.brush_rounded, 'ОТМАЗКА'),
  WorkNode(Icons.delete_sweep_rounded, 'С ВЫВОЗОМ МУСОРА'),
];

/// Данные дерева. У КАЖДОГО пункта — своё дерево, галочек-тупиков нет.
const List<WorkNode> workTree = [
  WorkNode(Icons.straighten_rounded, 'ЗАМЕР', [
    WorkNode(Icons.window_rounded, 'ОКНО', windowKinds),
    WorkNode(Icons.door_sliding_rounded, 'БАЛКОННЫЙ БЛОК', balconyBlockKinds),
    WorkNode(Icons.roofing_rounded, 'БАЛКОН', balconyKinds),
    WorkNode(Icons.deck_rounded, 'ЛОДЖИЯ', loggiaKinds),
    WorkNode(Icons.door_front_door_rounded, 'ДВЕРЬ', doorKinds),
    WorkNode(Icons.architecture_rounded, 'ОТКОСЫ', slopeKinds),
    WorkNode(Icons.water_drop_rounded, 'ОТЛИВ', flashingKinds),
    WorkNode(Icons.shelves, 'ПОДОКОННИКИ', sillKinds),
    WorkNode(Icons.apartment_rounded, 'ФАСАДНОЕ ОСТЕКЛЕНИЕ', facadeKinds),
  ]),
  WorkNode(Icons.construction_rounded, 'МОНТАЖ', [
    WorkNode(Icons.delete_sweep_rounded, 'ДЕМОНТАЖ', [
      WorkNode(Icons.content_cut_rounded, 'ЧАСТИЧНЫЙ', serviceTypes),
      WorkNode(Icons.delete_forever_rounded, 'ПОЛНЫЙ', serviceTypes),
      WorkNode(Icons.local_shipping_rounded, 'С ВЫВОЗОМ', serviceTypes),
    ]),
    WorkNode(Icons.build_rounded, 'УСТАНОВКА', [
      WorkNode(Icons.hardware_rounded, 'НА АНКЕР', serviceTypes),
      WorkNode(Icons.linear_scale_rounded, 'НА ПЛАСТИНЫ', serviceTypes),
      WorkNode(Icons.blur_on_rounded, 'НА ПЕНУ', serviceTypes),
    ]),
    WorkNode(Icons.water_drop_rounded, 'ОТКОСЫ И ОТЛИВЫ', [
      WorkNode(Icons.architecture_rounded, 'НАРУЖНЫЕ', serviceTypes),
      WorkNode(Icons.home_rounded, 'ВНУТРЕННИЕ', serviceTypes),
      WorkNode(Icons.all_inclusive_rounded, 'ПОЛНЫЙ КОНТУР', serviceTypes),
    ]),
    WorkNode(Icons.cleaning_services_rounded, 'УБОРКА', [
      WorkNode(Icons.auto_awesome_rounded, 'СУХАЯ', serviceTypes),
      WorkNode(Icons.water_drop_rounded, 'ВЛАЖНАЯ', serviceTypes),
      WorkNode(Icons.construction_rounded, 'ПОСЛЕ МОНТАЖА', serviceTypes),
    ]),
  ]),
  WorkNode(Icons.build_circle_rounded, 'РЕМОНТ', [
    WorkNode(Icons.tune_rounded, 'РЕГУЛИРОВКА', [
      WorkNode(Icons.door_sliding_rounded, 'СТВОРКИ', serviceTypes),
      WorkNode(Icons.hardware_rounded, 'ФУРНИТУРЫ', serviceTypes),
      WorkNode(Icons.compress_rounded, 'ПРИЖИМА', serviceTypes),
    ]),
    WorkNode(Icons.swap_horiz_rounded, 'ЗАМЕНА УЗЛА', [
      WorkNode(Icons.hardware_rounded, 'ПЕТЛИ', serviceTypes),
      WorkNode(Icons.back_hand_rounded, 'РУЧКА', serviceTypes),
      WorkNode(Icons.lock_rounded, 'ЗАПОР', serviceTypes),
      WorkNode(Icons.open_in_full_rounded, 'НОЖНИЦЫ', serviceTypes),
      // Резинка (уплотнитель). Подоконника при этой работе не бывает.
      WorkNode(Icons.linear_scale_rounded, 'ЗАМЕНА РЕЗИНКИ', serviceTypes),
    ]),
    WorkNode(Icons.window_rounded, 'ЗАМЕНА СТЕКЛОПАКЕТА', [
      WorkNode(Icons.crop_square_rounded, 'ОДНОКАМЕРНЫЙ', serviceTypes),
      WorkNode(Icons.layers_rounded, 'ДВУХКАМЕРНЫЙ', serviceTypes),
      WorkNode(Icons.shield_rounded, 'ТРИПЛЕКС', serviceTypes),
    ]),
  ]),
  WorkNode(Icons.report_problem_rounded, 'РЕКЛАМАЦИИ', [
    WorkNode(Icons.verified_rounded, 'ГАРАНТИЙНЫЙ СЛУЧАЙ', [
      WorkNode(Icons.air_rounded, 'ПРОДУВАНИЕ', serviceTypes),
      WorkNode(Icons.water_drop_rounded, 'КОНДЕНСАТ', serviceTypes),
      WorkNode(Icons.blur_on_rounded, 'ЗАПОТЕВАНИЕ', serviceTypes),
      WorkNode(Icons.umbrella_rounded, 'ПРОТЕЧКА', serviceTypes),
    ]),
    WorkNode(Icons.replay_rounded, 'ПОВТОРНЫЙ ВЫЕЗД', [
      WorkNode(Icons.verified_rounded, 'ПО ГАРАНТИИ', serviceTypes),
      WorkNode(Icons.payments_rounded, 'ПЛАТНЫЙ', serviceTypes),
    ]),
  ]),
];