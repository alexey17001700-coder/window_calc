import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'theme.dart';

/// Фото проёма: камера или галерея.
class MeasureMedia extends StatefulWidget {
  final List<String> photos;
  const MeasureMedia({super.key, required this.photos});

  @override
  State<MeasureMedia> createState() => _MeasureMediaState();
}

class _MeasureMediaState extends State<MeasureMedia> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await _picker.pickImage(source: src, imageQuality: 70);
      if (x == null) return;
      setState(() => widget.photos.add(x.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить фото')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppUi.sectionTitle(context, 'Фото проёма'),
        Row(
          children: [
            Expanded(
              child: _btn('📷 КАМЕРА', () => _pick(ImageSource.camera)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _btn('🖼 ГАЛЕРЕЯ', () => _pick(ImageSource.gallery)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.photos.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.photos.map((p) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(p),
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 84,
                        height: 84,
                        color: AppColors.card,
                        child: const Icon(Icons.broken_image,
                            color: AppColors.dim),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => widget.photos.remove(p)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _btn(String t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppUi.radiusSm),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          t,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
