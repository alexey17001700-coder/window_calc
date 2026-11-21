# КАРТА КОДА · window_calc / lib

Навигация по файлам. Читать ЭТУ карту, потом ОДИН нужный файл — целиком файлы не читать.

---

## ЭКРАНЫ

| Файл | Что внутри | Ключевые имена |
|---|---|---|
| `main.dart` | ЗАСТАВКА (ГЛАВНЫЙ файл библиотеки): тема,#3D-сцена, лог загрузки, прогресс, кнопки, навигация | `appNavigatorKey`, `AlmasApp`, `_AlmasAppState`, `SplashScreen`, `_SplashScreenState`, `_boot()`, `_push()`, `_replaceLast()`, `_model3d()`, `_logo()`, `_progressBar()`, `_logPanel()`, `_startButton()`, `_openOnboarding()`, `_backToSplash()`, `_openHome()`, `_checkButton()`, `_manualCheck()` |
| `home_screen.dart` | часть `main.dart`: ГЛАВНОЕ МЕНЮ, шапка, карточки, каскадное появление | `HomeScreen`, `_HomeScreenState`, `_header()`, `_card()`, `_soon()`, `_checkUpdate()`, `_Reveal`, `_RevealState` |
| `onboarding.dart` | МАСТЕР ЗАМЕРА: 6 шагов, состояние, сборка шагов (ГЛАВНЫЙ файл библиотеки) | `OnboardingScreen`, `_OnboardingScreenState`, `_cardClient()`, `_treeStep()`, `_sizesStep()`, `_visualStep()`, `_estimateStep()`, `_sheetStep()`, `_confirmTree()`, `_saveRecord()`, `_sashCount`, `_secWidths`, `_bumpSection()`, `_balcony` |
| `onboarding/widgets.dart` | часть `onboarding.dart`: поля ввода, кнопки, чипы створок, строки секций | `_PremiumField`, `_GoldButton`, `_GhostButton`, `_RoundButton`, `_SashCountChip`, `_SectionWidthRow`, `_StepBtn` |
| `onboarding/background.dart` | часть `onboarding.dart`: фон, орбы, частицы, блик | `_PremiumBg`, `_BgPainter`, `_ShinePainter` |
| `wizard_screen.dart` | экран-обёртка мастера (шаг 1) | `WizardStep1Screen` |
| `work_tree.dart` | ДЕРЕВО «ЧТО ДЕЛАЕМ» (ГЛАВНЫЙ файл библиотеки): карточки, раскладка колонок, выбор, мультивыбор, автоскролл | `WorkTreeView`, `_WorkTreeViewState`, `_level()`, `_columns()`, `_select()`, `_pruneMulti()`, `_titles()`, `_multiTitles()`, `_autoScroll()`, `_card()`, `_checkBox()`, `_iconBox()`, `_dec()`, `_appear()` |
| `work_tree_data.dart` | часть `work_tree.dart`: ВСЕ данные дерева — узлы, ветки, комплектация | `WorkNode`, `workTree`, `windowKinds`, `balconyBlockKinds`, `balconyKinds`, `loggiaKinds`, `doorKinds`, `slopeKinds`, `flashingKinds`, `sillKinds`, `facadeKinds`, `houseTypes`, `loggiaHouseTypes`, `balconyShapes`, `finishingTypes`, `serviceTypes`, `balconyFinishing`, `balconyBlockFinishing`, `noSillWorks`, `noSillParts`, `finishFor()` |
| `work_tree_painter.dart` | часть `work_tree.dart`: линии-ветки с бегущим огоньком и нажатие карточки | `_EdgePainter`, `_PressCard`, `_PressCardState` |
| `measure_sizes.dart` | ШАГ «РАЗМЕРЫ» (ГЛАВНЫЙ файл библиотеки): экран, состояние, габарит, АВТО-длины, прогресс | `MeasureSizesView`, `_MeasureSizesViewState`, `_next()`, `_back()`, `_widthMm()`, `_applyAuto()`, `_collect()`, `_collectGabarit()`, `_badField()`, `_gabaritCard()`, `_progress()` |
| `measure_sizes_specs.dart` | часть `measure_sizes.dart`: поля по пунктам, допуски, единицы, разбор мм, АВТО-формулы | `SizeSpec`, `sizeSpecs`, `_fallback`, `mmFrom()`, `parseToMm()`, `detectedUnit()`, `sizeError()`, `autoLengthMm()`, `autoLengthHint()`, `kAutoLengthField`, `kUnitMm`, `kUnitCm`, `kAutoSillWindow`, `kAutoEbbWindow`, `kAutoSillBalcony`, `kAutoEbbBalcony`, `kAutoCanopyBalcony`, `kAutoCanopyOverlap` |
| `measure_sizes_fields.dart` | часть `measure_sizes.dart`: поле размера, золотая и прозрачная кнопки | `_SizeField`, `_SizeFieldState`, `_SizeGold`, `_SizeGoldState`, `_SizeGhost`, `_SizeGhostState` |
| `measure_sheet.dart` | ЗАМЕРНЫЙ ЛИСТ: клиент, конструкция, размеры, фото, копирование, отправка | `MeasureSheetView`, `MeasureMediaPanel`, `SheetExport`, `MeasureSync`, `_sectionsMm()`, `_sheetText()` |
| `measure_media.dart` | фото проёма, хранилище, экспорт HTML/PDF, отправка на сервер | `MeasurePhoto`, `PhotoStore`, `MeasureMediaPanel`, `SheetExport`, `MeasureSync` |
| `measure_history.dart` | история замеров и база клиентов | `MeasureRecord`, `MeasureHistory`, `ClientBook`, `HistoryView`, `money()`, `stamp()` |
| `price_estimate.dart` | прайс и смета | `PriceBook`, `buildEstimate()`, `Estimate`, `EstimateLine`, `EstimateView`, `money()`, `kCurrency`, `windowPerM2For()` |

## ЧЕРТЁЖ И ВИЗУАЛ

| Файл | Что внутри | Ключевые имена |
|---|---|---|
| `window_visual.dart` | ЧЕРТЁЖ ПО ГОСТ: проём, рама, створки, стекло, фурнитура, размеры, комплектация | `WindowVisual`, `_GostPainter`, `kSashModeNames`, `kSashModeLetter`, `kSashModeShort`, `_sashRects`, `_normWidths`, `_hit`, `_hardware`, `_openingMark`, `_sashLetter`, `_hingesFor`, `_dimH`, `_dimV`, `_extH`, `_extV`, `_axisV`, `_axisH`, `_corner90` |
| `window_scheme.dart` | цветовая схема чертежа (стекло, сэндвич, стена) | цвета стеклопакета `#D8EDFC → #B6DBF4`, контур `#7FB3D5` |
| `viewer3d.dart` | 3D-рендерер заставки: окно, инструменты | `_ScenePainter`, `_prism`, `_cone`, `_scalePrims`, `_winScale` |

## ОСНОВА

| Файл | Что внутри | Ключевые имена |
|---|---|---|
| `theme.dart` | цвета и типографика приложения | `AppColors`, `AppUi` |
| `update_checker.dart` | проверка и установка обновлений с GitHub | `UpdateChecker`, `UpdateResult`, `check()`, `checkOnStart()`, `showUpdate()` |
| `version_info.dart` | версия приложения для экрана | счётчик правок |
| `STRUCTURE.md` | ЭТОТ файл — карта кода | — |

---

## ПРАВИЛА РАБОТЫ С КОДОМ

1. Правка — только точечная (`replace_in_file`), остальной код слово в слово.
2. Файлы целиком не читать: сначала эта карта, потом нужный фрагмент.
3. Дробить файл мельче 100 строк нельзя — прыжки между файлами дороже.
4. Разбивка файлов — через `part` / `part of` (приватные символы остаются доступны),
   все `import` остаются в главном файле.
5. Порядок: новый файл → сверка со старым → сборка APK → и только потом удаление.
