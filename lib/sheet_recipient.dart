/// ═══════════════════════════════════════════════════════════════════
///  КОМУ АДРЕСОВАН ЗАМЕРНЫЙ ЛИСТ  ·  v3.4.107
///  Один и тот же замер отдаётся РАЗНЫМ людям по-разному:
///   · ЗАМЕРЩИК  — полный лист, всё подряд;
///   · КЛИЕНТ    — изделие + комплектующие + общая цена;
///   · ЗАВОД     — технические параметры (профиль, стеклопакет, армировка);
///   · МОНТАЖНИК — размеры, проём, фото.
///  Флаги ниже решают, какие блоки попадут в PDF.
/// ═══════════════════════════════════════════════════════════════════

/// Адресат замерного листа.
enum SheetRecipient {
  /// Полный лист — вся информация о замере.
  measurer,

  /// Клиент: изделие, комплектующие, общая цена.
  client,

  /// Завод: технические параметры для изготовления.
  factory,

  /// Монтажник: размеры, проём, фото.
  installer,
}

extension SheetRecipientInfo on SheetRecipient {
  /// Название адресата для кнопки.
  String get label => switch (this) {
        SheetRecipient.measurer => 'ЗАМЕРЩИК',
        SheetRecipient.client => 'КЛИЕНТ',
        SheetRecipient.factory => 'ЗАВОД',
        SheetRecipient.installer => 'МОНТАЖНИК',
      };

  /// Заголовок самого листа.
  String get sheetTitle => switch (this) {
        SheetRecipient.measurer => 'ЗАМЕРНЫЙ ЛИСТ',
        SheetRecipient.client => 'ЗАКАЗ',
        SheetRecipient.factory => 'ЗАКАЗ НА ИЗГОТОВЛЕНИЕ',
        SheetRecipient.installer => 'ЛИСТ МОНТАЖА',
      };

  /// Подсказка под названием — что попадёт в лист.
  String get hint => switch (this) {
        SheetRecipient.measurer => 'ПОЛНЫЙ ЛИСТ · ВСЁ',
        SheetRecipient.client => 'ИЗДЕЛИЕ · КОМПЛЕКТУЮЩИЕ · ЦЕНА',
        SheetRecipient.factory => 'ПРОФИЛЬ · СТЕКЛОПАКЕТ · АРМИРОВКА',
        SheetRecipient.installer => 'РАЗМЕРЫ · ПРОЁМ · ФОТО',
      };

  /// Чертёж изделия — нужен всем.
  bool get showVisual => true;

  /// Правая колонка-спецификация (у монтажника её нет).
  bool get showSpec => this != SheetRecipient.installer;

  /// Блок «ДАННЫЕ ЗАМЕРА» (размеры по пунктам).
  bool get showRows =>
      this == SheetRecipient.measurer || this == SheetRecipient.installer;

  /// Фото проёма.
  bool get showPhotos =>
      this == SheetRecipient.measurer || this == SheetRecipient.installer;

  /// Блок «КЛИЕНТ» (имя).
  bool get showClient =>
      this == SheetRecipient.measurer || this == SheetRecipient.client;

  /// Общая цена — только клиенту.
  bool get showPrice => this == SheetRecipient.client;

  /// Номер заказа в шапке (монтажнику он не нужен).
  bool get showOrder => this != SheetRecipient.installer;
}
