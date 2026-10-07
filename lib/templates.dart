class Section {
  String type;
  bool hasMosquito;

  Section({
    this.type = 'Глухая',
    this.hasMosquito = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'hasMosquito': hasMosquito,
  };

  factory Section.fromJson(Map<String, dynamic> j) => Section(
    type: (j['type'] ?? 'Глухая').toString(),
    hasMosquito: j['hasMosquito'] ?? false,
  );
}

class Column {
  double widthMm;
  List<Section> sections;

  Column({
    this.widthMm = 0,
    List<Section>? sections,
  }) : sections = sections ?? [Section()];

  Map<String, dynamic> toJson() => {
    'widthMm': widthMm,
    'sections': sections.map((e) => e.toJson()).toList(),
  };

  factory Column.fromJson(Map<String, dynamic> j) => Column(
    widthMm: (j['widthMm'] ?? 0).toDouble(),
    sections: ((j['sections'] as List?) ?? [])
        .map((e) => Section.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class WindowTemplate {
  final String id;
  final String name;
  final int columnsCount;
  final List<List<String>> sectionTypes; // [колонка][секция] = тип

  const WindowTemplate({
    required this.id,
    required this.name,
    required this.columnsCount,
    required this.sectionTypes,
  });
}

// ═══════════════════════════════════════════════════════════
// ШАБЛОНЫ
// ═══════════════════════════════════════════════════════════

const List<WindowTemplate> allTemplates = [
  // ─── Окна ───
  WindowTemplate(
    id: 'win1',
    name: 'Окно 1-створчатое',
    columnsCount: 1,
    sectionTypes: [
      ['Поворотно-откидная'],
    ],
  ),
  WindowTemplate(
    id: 'win2_povorot_gluh',
    name: 'Окно 2-ств. (поворотная + глухая)',
    columnsCount: 2,
    sectionTypes: [
      ['Поворотная'],
      ['Глухая'],
    ],
  ),
  WindowTemplate(
    id: 'win2_povorot_otkid',
    name: 'Окно 2-ств. (поворотно-откидная + глухая)',
    columnsCount: 2,
    sectionTypes: [
      ['Поворотно-откидная'],
      ['Глухая'],
    ],
  ),
  WindowTemplate(
    id: 'win3',
    name: 'Окно 3-ств. (поворотная + глухая + поворотная)',
    columnsCount: 3,
    sectionTypes: [
      ['Поворотная'],
      ['Глухая'],
      ['Поворотная'],
    ],
  ),

  // ─── Балконные блоки ───
  WindowTemplate(
    id: 'bb1',
    name: 'ББ: глухое + дверь (стекло/сэндвич)',
    columnsCount: 2,
    sectionTypes: [
      ['Глухая'],
      ['Поворотная', 'Сэндвич'],
    ],
  ),
  WindowTemplate(
    id: 'bb2',
    name: 'ББ: дверь (поворотно-откидная + сэндвич) + глухое',
    columnsCount: 2,
    sectionTypes: [
      ['Поворотно-откидная', 'Сэндвич'],
      ['Глухая'],
    ],
  ),
  WindowTemplate(
    id: 'bb3',
    name: 'ББ: глухое + дверь (стекло + стекло)',
    columnsCount: 2,
    sectionTypes: [
      ['Глухая'],
      ['Поворотная', 'Глухая'],
    ],
  ),
  WindowTemplate(
    id: 'bb4',
    name: 'ББ: глухое + дверь (стекло/сэндвич) + створка сверху',
    columnsCount: 2,
    sectionTypes: [
      ['Глухая'],
      ['Поворотная', 'Поворотная'],
    ],
  ),
  WindowTemplate(
    id: 'bb5',
    name: 'ББ: створка+створка (обе поворотные)',
    columnsCount: 2,
    sectionTypes: [
      ['Поворотная'],
      ['Поворотная'],
    ],
  ),
  WindowTemplate(
    id: 'bb6',
    name: 'ББ: глухое + поворотно-откидная (без деления)',
    columnsCount: 2,
    sectionTypes: [
      ['Глухая'],
      ['Поворотно-откидная'],
    ],
  ),
];
