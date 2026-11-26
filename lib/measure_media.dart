import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'screen_flash.dart';

/// ═══════════════════════════════════════════════════════════════════
///  ЭТАП 5 · ФОТО ПРОЁМА + PDF-ЛИСТ + ОТПРАВКА НА СЕРВЕР
///  Всё локально: фото копируются в папку приложения, лист собирается
///  в HTML (печать → PDF), отправка на сервер — очередью, без потери
///  замера при отсутствии сети.
/// ═══════════════════════════════════════════════════════════════════

// ─────────────────────────── ФОТО ───────────────────────────

/// Одно фото проёма.
class MeasurePhoto {
  const MeasurePhoto({
    required this.path,
    required this.takenAt,
    this.label = '',
  });

  /// Абсолютный путь к копии файла в папке приложения.
  final String path;

  /// Время съёмки (мс с эпохи).
  final int takenAt;

  /// Подпись: «ОБЩИЙ ВИД», «ОТКОС», «ПОДОКОННИК» и т.п.
  final String label;

  Map<String, dynamic> toJson() =>
      {'p': path, 't': takenAt, 'l': label};

  static MeasurePhoto? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final p = raw['p'];
    if (p is! String || p.isEmpty) return null;
    return MeasurePhoto(
      path: p,
      takenAt: raw['t'] is int ? raw['t'] as int : 0,
      label: raw['l'] is String ? raw['l'] as String : '',
    );
  }

  /// Дата «14.03.2026 · 18:40».
  String get stamp {
    if (takenAt <= 0) return '—';
    final d = DateTime.fromMillisecondsSinceEpoch(takenAt);
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${two(d.day)}.${two(d.month)}.${d.year} · '
        '${two(d.hour)}:${two(d.minute)}';
  }
}

/// Хранилище фото: копии лежат в <документы>/photos, список — в prefs.
class PhotoStore {
  static const _prefix = 'window_calc_photos_';

  /// Максимум фото на один замер.
  static const maxPhotos = 12;

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/photos');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  /// Загрузить список фото замера. Битая запись не роняет приложение.
  static Future<List<MeasurePhoto>> load(String key) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('$_prefix$key');
      if (raw == null || raw.isEmpty) return [];
      final data = jsonDecode(raw);
      if (data is! List) return [];
      return data
          .map(MeasurePhoto.fromJson)
          .whereType<MeasurePhoto>()
          .toList(growable: true);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(String key, List<MeasurePhoto> photos) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      '$_prefix$key',
      jsonEncode(photos.map((p) => p.toJson()).toList()),
    );
  }

  /// Добавить снимки: файлы КОПИРУЮТСЯ в папку приложения, чтобы не
  /// пропали, если пользователь удалит оригинал из галереи.
  static Future<List<MeasurePhoto>> add(
    String key,
    List<MeasurePhoto> current,
    List<XFile> files, {
    String label = '',
  }) async {
    final out = List<MeasurePhoto>.from(current);
    final d = await _dir();
    for (final f in files) {
      if (out.length >= maxPhotos) break;
      try {
        final name = 'ph_${DateTime.now().microsecondsSinceEpoch}'
            '${f.path.contains('.') ? '.${f.path.split('.').last}' : '.jpg'}';
        final dest = File('${d.path}/$name');
        await File(f.path).copy(dest.path);
        out.add(MeasurePhoto(
          path: dest.path,
          takenAt: DateTime.now().millisecondsSinceEpoch,
          label: label,
        ));
      } catch (_) {
        // Одно фото не скопировалось — остальные добавляем.
      }
    }
    await _save(key, out);
    return out;
  }

  /// Удалить фото по индексу (файл тоже удаляем).
  static Future<List<MeasurePhoto>> remove(
    String key,
    List<MeasurePhoto> current,
    int index,
  ) async {
    if (index < 0 || index >= current.length) return current;
    final out = List<MeasurePhoto>.from(current);
    final gone = out.removeAt(index);
    try {
      final f = File(gone.path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    await _save(key, out);
    return out;
  }

  /// Стереть все фото замера.
  static Future<List<MeasurePhoto>> clear(
    String key,
    List<MeasurePhoto> current,
  ) async {
    for (final p in current) {
      try {
        final f = File(p.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    final sp = await SharedPreferences.getInstance();
    await sp.remove('$_prefix$key');
    return [];
  }

  /// Фото в base64 — для вставки в HTML-лист.
  static Future<List<(MeasurePhoto, String)>> asBase64(
    List<MeasurePhoto> photos,
  ) async {
    final out = <(MeasurePhoto, String)>[];
    for (final p in photos) {
      try {
        final f = File(p.path);
        if (!await f.exists()) continue;
        final bytes = await f.readAsBytes();
        out.add((p, base64Encode(bytes)));
      } catch (_) {}
    }
    return out;
  }
}

// ─────────────────────────── ПАНЕЛЬ ФОТО ───────────────────────────

/// Блок «ФОТО ПРОЁМА» для замерного листа.
class MeasureMediaPanel extends StatefulWidget {
  const MeasureMediaPanel({
    super.key,
    required this.sessionKey,
    required this.photos,
    required this.onChanged,
  });

  /// Ключ сессии (клиент + адрес).
  final String sessionKey;

  final List<MeasurePhoto> photos;

  /// Отдаём наружу обновлённый список.
  final ValueChanged<List<MeasurePhoto>> onChanged;

  @override
  State<MeasureMediaPanel> createState() => _MeasureMediaPanelState();
}

class _MeasureMediaPanelState extends State<MeasureMediaPanel> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource src) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (src == ImageSource.camera) {
        final one = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 72,
          maxWidth: 1600,
        );
        if (one != null) {
          final out = await PhotoStore.add(
            widget.sessionKey,
            widget.photos,
            [one],
          );
          widget.onChanged(out);
        }
      } else {
        final many = await _picker.pickMultiImage(imageQuality: 72);
        if (many.isNotEmpty) {
          final out = await PhotoStore.add(
            widget.sessionKey,
            widget.photos,
            many,
          );
          widget.onChanged(out);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF12233A),
            content: Text(
              'НЕ УДАЛОСЬ ОТКРЫТЬ КАМЕРУ / ГАЛЕРЕЮ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.gold,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(int i) async {
    final out = await PhotoStore.remove(widget.sessionKey, widget.photos, i);
    widget.onChanged(out);
  }

  Future<void> _clear() async {
    final ok = await _confirm('УДАЛИТЬ ВСЕ ФОТО ЗАМЕРА?');
    if (!ok) return;
    final out = await PhotoStore.clear(widget.sessionKey, widget.photos);
    widget.onChanged(out);
  }

  Future<bool> _confirm(String text) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1524),
        title: const Text(
          'ПОДТВЕРДИТЕ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.gold,
          ),
        ),
        content: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ОТМЕНА',
                style: TextStyle(color: Color(0xFF7E93AC))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('УДАЛИТЬ',
                style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final ph = widget.photos;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ФОТО ПРОЁМА',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.gold,
                  ),
                ),
              ),
              if (ph.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    flashScreen();
                    _clear();
                  },
                  child: const Text(
                    'ОЧИСТИТЬ',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Color(0xFF7E93AC),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (ph.isEmpty)
            const Text(
              'ФОТО НЕ ДОБАВЛЕНЫ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF7E93AC),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ph.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _thumb(ph[i], i),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _mediaBtn(
                  'КАМЕРА',
                  Icons.photo_camera_rounded,
                  _busy ? null : () => _pick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _mediaBtn(
                  'ГАЛЕРЕЯ',
                  Icons.photo_library_rounded,
                  _busy ? null : () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ДОБАВЛЕНО ${ph.length} ИЗ ${PhotoStore.maxPhotos}',
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Color(0xFF5B6B80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(MeasurePhoto p, int i) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 92,
            height: 92,
            color: const Color(0xFF0B1524),
            child: Image.file(
              File(p.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_rounded,
                    size: 20, color: Color(0xFF5B6B80)),
              ),
            ),
          ),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: () {
              flashScreen();
              _delete(i);
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xCC0B1524),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 13, color: AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mediaBtn(String text, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              flashScreen();
              onTap();
            },
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1.0,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1524),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.gold.withOpacity(0.42)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── PDF / ЛИСТ ───────────────────────────

/// Сборка замерного листа в HTML и отправка файла.
/// PDF получается системной печатью: «Печать → Сохранить как PDF».
class SheetExport {
  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  /// HTML замерного листа с фото (фото в base64 — файл самодостаточный).
  static String html({
    required String client,
    required String product,
    required List<(String, String)> rows,
    required List<(MeasurePhoto, String)> photos,
    String footer = 'Сформировано в Window Measure Pro',
  }) {
    final b = StringBuffer();
    b.writeln('<!DOCTYPE html><html><head><meta charset="utf-8">');
    b.writeln('<title>Замерный лист</title><style>');
    b.writeln('*{box-sizing:border-box}body{margin:0;padding:24px;'
        'font-family:-apple-system,Roboto,Arial,sans-serif;color:#0B1524}');
    b.writeln('h1{font-size:20px;letter-spacing:1px;margin:0 0 4px}');
    b.writeln('.sub{font-size:11px;letter-spacing:1.6px;color:#8A7A45;'
        'font-weight:700;margin-bottom:18px}');
    b.writeln('.card{border:1px solid #D8C98F;border-radius:12px;'
        'padding:14px 16px;margin-bottom:14px}');
    b.writeln('.t{font-size:10px;letter-spacing:1.6px;font-weight:800;'
        'color:#8A7A45;margin-bottom:10px}');
    b.writeln('table{width:100%;border-collapse:collapse}');
    b.writeln('td{padding:4px 0;font-size:12.5px;vertical-align:top}');
    b.writeln('td.k{width:38%;color:#5B6B80;font-weight:600}');
    b.writeln('td.v{font-weight:700}');
    b.writeln('.ph{display:flex;flex-wrap:wrap;gap:10px}');
    b.writeln('.ph figure{margin:0;width:31%;min-width:130px}');
    b.writeln('.ph img{width:100%;border-radius:8px;border:1px solid #D8C98F}');
    b.writeln('figcaption{font-size:9.5px;color:#5B6B80;margin-top:4px}');
    b.writeln('.ft{font-size:9.5px;color:#8A97A8;margin-top:18px;'
        'text-align:center;letter-spacing:1px}');
    b.writeln('@media print{body{padding:0}}');
    b.writeln('</style></head><body>');
    b.writeln('<h1>ЗАМЕРНЫЙ ЛИСТ</h1>');
    b.writeln('<div class="sub">ВСЕ РАЗМЕРЫ В МИЛЛИМЕТРАХ</div>');

    b.writeln('<div class="card"><div class="t">КЛИЕНТ</div>'
        '<table><tr><td class="k">ИМЯ</td><td class="v">${_esc(client)}</td></tr>'
        '</table></div>');

    b.writeln('<div class="card"><div class="t">ИЗДЕЛИЕ</div>'
        '<table><tr><td class="k">ЦЕПОЧКА</td>'
        '<td class="v">${_esc(product)}</td></tr></table></div>');

    if (rows.isNotEmpty) {
      b.writeln('<div class="card"><div class="t">ДАННЫЕ ЗАМЕРА</div><table>');
      for (final r in rows) {
        b.writeln('<tr><td class="k">${_esc(r.$1)}</td>'
            '<td class="v">${_esc(r.$2)}</td></tr>');
      }
      b.writeln('</table></div>');
    }

    if (photos.isNotEmpty) {
      b.writeln('<div class="card"><div class="t">ФОТО ПРОЁМА</div>'
          '<div class="ph">');
      for (final p in photos) {
        b.writeln('<figure><img src="data:image/jpeg;base64,${p.$2}">'
            '<figcaption>${_esc(p.$1.stamp)}</figcaption></figure>');
      }
      b.writeln('</div></div>');
    }

    b.writeln('<div class="ft">${_esc(footer)}</div>');
    b.writeln('</body></html>');
    return b.toString();
  }

  /// Сохранить лист в файл и отдать на печать / отправку.
  /// Возвращает путь к файлу ('' — не вышло).
  static Future<String> save(String html, String baseName) async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/sheets');
      if (!await dir.exists()) await dir.create(recursive: true);
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final f = File('${dir.path}/${baseName}_$stamp.html');
      await f.writeAsString(html);
      return f.path;
    } catch (_) {
      return '';
    }
  }

  /// Отправить готовый лист (печать → PDF, мессенджер, почта).
  static Future<void> share(String path, String sheetText) async {
    if (path.isEmpty) {
      await Share.share(sheetText, subject: 'Замерный лист');
      return;
    }
    await Share.shareXFiles(
      [XFile(path, mimeType: 'text/html')],
      subject: 'Замерный лист',
      text: 'Лист замера. Для PDF: печать → «Сохранить как PDF».',
    );
  }

  /// Скопировать путь листа в буфер (если нужно отдать вручную).
  static Future<void> copyPath(String path) async {
    await Clipboard.setData(ClipboardData(text: path));
  }
}

// ─────────────────────────── ОТПРАВКА НА СЕРВЕР ───────────────────────────

/// Отправка замеров на сервер Штаба.
/// Адрес и ключ — в настройках приложения (prefs). Нет сети или адреса —
/// замер встаёт в ОЧЕРЕДЬ и уйдёт при следующем запуске/нажатии.
class MeasureSync {
  static const _urlKey = 'window_calc_sync_url';
  static const _tokenKey = 'window_calc_sync_token';
  static const _queueKey = 'window_calc_sync_queue';

  static Future<String> get url async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_urlKey) ?? '';
  }

  static Future<void> setUrl(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_urlKey, v.trim());
  }

  static Future<String> get token async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey) ?? '';
  }

  static Future<void> setToken(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, v.trim());
  }

  static Future<List<Map<String, dynamic>>> _queue() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_queueKey);
      if (raw == null || raw.isEmpty) return [];
      final d = jsonDecode(raw);
      if (d is! List) return [];
      return d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _setQueue(List<Map<String, dynamic>> q) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_queueKey, jsonEncode(q));
  }

  /// Сколько замеров ждёт отправки.
  static Future<int> pending() async => (await _queue()).length;

  /// Положить замер в очередь.
  static Future<void> enqueue(Map<String, dynamic> payload) async {
    final q = await _queue();
    q.add(payload);
    if (q.length > 200) q.removeRange(0, q.length - 200);
    await _setQueue(q);
  }

  /// Отправить один замер. true — ушёл.
  static Future<bool> _post(Map<String, dynamic> payload) async {
    final base = await url;
    if (base.isEmpty) return false;
    final tok = await token;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final target = Uri.parse(base.endsWith('/')
          ? '${base}api/measure'
          : '$base/api/measure');
      final req = await client.postUrl(target);
      req.headers.contentType = ContentType.json;
      if (tok.isNotEmpty) req.headers.set('X-Auth', tok);
      req.write(jsonEncode(payload));
      final res = await req.close().timeout(const Duration(seconds: 15));
      client.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Отправить сейчас: ушло — true, иначе замер уходит в очередь.
  static Future<bool> push(Map<String, dynamic> payload) async {
    final ok = await _post(payload);
    if (!ok) await enqueue(payload);
    return ok;
  }

  /// Дослать очередь. Возвращает число отправленных.
  static Future<int> flush() async {
    final q = await _queue();
    if (q.isEmpty) return 0;
    final left = <Map<String, dynamic>>[];
    var sent = 0;
    for (final item in q) {
      if (await _post(item)) {
        sent++;
      } else {
        left.add(item);
      }
    }
    await _setQueue(left);
    return sent;
  }
}
