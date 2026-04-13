import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GradientBG extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientBG({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgTop,
            AppColors.bgBottom,
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}