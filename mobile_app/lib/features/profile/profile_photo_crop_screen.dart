import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';

class ProfilePhotoCropScreen extends StatefulWidget {
  final File imageFile;

  const ProfilePhotoCropScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ProfilePhotoCropScreen> createState() =>
      _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _controller =
      TransformationController();

  bool isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCroppedImage() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final boundary = _cropKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final image = await boundary.toImage(
        pixelRatio: 3,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();

      final file = File(
        '${dir.path}/voxa_profile_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(bytes);

      if (!mounted) return;

      Navigator.pop(context, file);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void _resetImage() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    const cropSize = 320.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFD),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFAFD),
              Color(0xFFF6EDFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.primary,
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Adjust Photo',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Move and zoom your photo',
                            style: TextStyle(
                              color: Color(0xFF8F889A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving ? null : _resetImage,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: RepaintBoundary(
                  key: _cropKey,
                  child: Container(
                    width: cropSize,
                    height: cropSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InteractiveViewer(
                      transformationController: _controller,
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 1,
                      maxScale: 5,
                      boundaryMargin: const EdgeInsets.all(240),
                      child: SizedBox(
                        width: 520,
                        height: 520,
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.78),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Pinch to zoom • Drag to reposition',
                  style: TextStyle(
                    color: Color(0xFF8F889A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveCroppedImage,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      isSaving ? 'Saving...' : 'Use Photo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}