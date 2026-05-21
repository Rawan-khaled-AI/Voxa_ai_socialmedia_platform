import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MediaPreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onRemove;

  const MediaPreview({
    super.key,
    required this.imageFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),

      child: Stack(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),

            child: Container(
              width: double.infinity,

              constraints:
                  const BoxConstraints(
                maxHeight: 340,
              ),

              color: const Color(
                0xFFF3ECFF,
              ),

              child: Image.file(
                imageFile!,

                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,

            child: InkWell(
              onTap: onRemove,

              borderRadius:
                  BorderRadius.circular(
                999,
              ),

              child: Container(
                width: 38,
                height: 38,

                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons.close,

                  color:
                      AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}