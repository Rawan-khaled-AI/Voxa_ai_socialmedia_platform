import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final AuthService _authService =
      AuthService();

  final TextEditingController
      currentPasswordController =
      TextEditingController();

  final TextEditingController
      newPasswordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> _changePassword() async {
    final currentPassword =
        currentPasswordController.text.trim();

    final newPassword =
        newPasswordController.text.trim();

    final confirmPassword =
        confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        'Please fill all fields',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'Passwords do not match',
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _authService.changePassword(
        currentPassword:
            currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      _showMessage(
        'Password updated successfully',
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage(
        'Failed to update password',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _field({
    required String hint,
    required TextEditingController
        controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor:
              AppColors.fieldFill,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.bgTop,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color:
                AppColors.textDark,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color:
              AppColors.primary,
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),

            _field(
              hint:
                  'Current Password',
              controller:
                  currentPasswordController,
            ),

            _field(
              hint: 'New Password',
              controller:
                  newPasswordController,
            ),

            _field(
              hint:
                  'Confirm Password',
              controller:
                  confirmPasswordController,
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : _changePassword,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )
                    : const Text(
                        'Update Password',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}