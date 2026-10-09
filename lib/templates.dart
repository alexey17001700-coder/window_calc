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

class SchemeColumn {
  double widthMm;
  double heightRatio;
  List<Section> sections;

  SchemeColumn({
    this.widthMm = 0,
    this.heightRatio = 1.0,
    List<Section>? sections,
  }) : sections = sections ?? [Section()];

  Map<String, dynamic> toJson() => {
    'widthMm': widthMm,
    'heightRatio': heightRatio,
    'sections': sections.map((e) => e.toJson()).toList(),
  };

  factory SchemeColumn.fromJson(Map<String, dynamic> j) => SchemeColumn(
    widthMm: (j['widthMm'] ?? 0).toDouble(),
    heightRatio: (j['heightRatio'] ?? 1.0).toDouble(),
    sections: ((j['sections'] as List?) ?? [])
        .map((e) => Section.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class TemplateColumn {
  final double heightRatio;
  final List<String> sections;

  const TemplateColumn({
    this.heightRatio = 1.0,
    required this.sections,
  });
}

class WindowTemplate {
  final String id;
  final String name;
  final List<TemplateColumn> columns;

  const WindowTemplate({
    required this.id,
    required this.name,
    required this.columns,
  });
}

const List<WindowTemplate> allTemplates = [
  WindowTemplate(
    id: 'win1',
    name: 'Окно 1-створчатое',
    columns: [TemplateColumn(sections: ['Поворотно-откидная'])],
  ),
  WindowTemplate(
    id: 'win2_povorot_gluh',
    name: 'Окно 2-ств. (поворотная + глухая)',
    columns: [
      TemplateColumn(sections: ['Поворотная']),
      TemplateColumn(sections: ['Глухая']),
    ],
  ),
  WindowTemplate(
    id: 'win2_povorot_otkid',
    name: 'Окно 2-ств. (поворотно-откидная + глухая)',
    columns: [
      TemplateColumn(sections: ['Поворотно-откидная']),
      TemplateColumn(sections: ['Глухая']),
    ],
  ),
  WindowTemplate(
    id: 'win3',
    name: 'Окно 3-ств. (поворотная + глухая + поворотная)',
    columns: [
      TemplateColumn(sections: ['Поворотная']),
      TemplateColumn(sections: ['Глухая']),
      TemplateColumn(sections: ['Поворотная']),
    ],
  ),

  // ─── Балконные блоки ───

  WindowTemplate(
    id: 'bb1',
    name: 'ББ: глухое окно (короче) + дверь (стекло/сэндвич)',
    columns: [
      TemplateColumn(heightRatio: 0.65, sections: ['Глухая']),
      TemplateColumn(heightRatio: 1.0, sections: ['Поворотная', 'Сэндвич']),
    ],
  ),
  WindowTemplate(
    id: 'bb2',
    name: 'ББ: дверь (стекло/сэндвич) + глухое окно (короче)',
    columns: [
      TemplateColumn(heightRatio: 1.0, sections: ['Поворотная', 'Сэндвич']),
      TemplateColumn(heightRatio: 0.65, sections: ['Глухая']),
    ],
  ),
  WindowTemplate(
    id: 'bb3',
    name: 'ББ: глухое окно (короче) + дверь (стекло/стекло)',
    columns: [
      TemplateColumn(heightRatio: 0.65, sections: ['Глухая']),
      TemplateColumn(heightRatio: 1.0, sections: ['Поворотная', 'Глухая']),
    ],
  ),
  WindowTemplate(
    id: 'bb4',
    name: 'ББ: глухое окно (короче) + дверь поворотно-откидная',
    columns: [
      TemplateColumn(heightRatio: 0.65, sections: ['Глухая']),
      TemplateColumn(heightRatio: 1.0, sections: ['Поворотно-откидная', 'Сэндвич']),
    ],
  ),
  WindowTemplate(
    id: 'bb5',
    name: 'ББ: створка + створка (обе полные)',
    columns: [
      TemplateColumn(sections: ['Поворотная']),
      TemplateColumn(sections: ['Поворотная']),
    ],
  ),
  WindowTemplate(
    id: 'bb6',
    name: 'ББ: глухое + поворотно-откидная (полные)',
    columns: [
      TemplateColumn(sections: ['Глухая']),
      TemplateColumn(sections: ['Поворотно-откидная']),
    ],
  ),
];
