import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class VoxaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;

  const VoxaButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}