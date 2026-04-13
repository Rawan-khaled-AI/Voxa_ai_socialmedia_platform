import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class VoxaTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  const VoxaTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textDark),
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}