import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/voxa_button.dart';
import '../../../shared/widgets/voxa_text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String routeName = AppRoutes.newPassword;

  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  String? _error;

  bool get _canChange {
    final oldP = _oldPasswordController.text.trim();
    final newP = _newPasswordController.text.trim();
    final confirmP = _confirmPasswordController.text.trim();

    if (oldP.isEmpty || newP.isEmpty || confirmP.isEmpty) return false;
    if (newP.length < 6) return false;
    if (newP != confirmP) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    void listen() => setState(() => _error = null);

    _oldPasswordController.addListener(listen);
    _newPasswordController.addListener(listen);
    _confirmPasswordController.addListener(listen);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() {
    final newP = _newPasswordController.text.trim();
    final confirmP = _confirmPasswordController.text.trim();

    if (newP.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    if (newP != confirmP) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'New\npassword',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 14),

              const Icon(
                Icons.lock_outline,
                size: 78,
                color: AppColors.primary,
              ),

              const SizedBox(height: 22),

              VoxaTextField(
                label: 'enter old password',
                controller: _oldPasswordController,
                obscure: true,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 14),

              VoxaTextField(
                label: 'enter new password',
                controller: _newPasswordController,
                obscure: true,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 14),

              VoxaTextField(
                label: 'confirm new password',
                controller: _confirmPasswordController,
                obscure: true,
                onChanged: (_) => setState(() {}),
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              VoxaButton(
                text: 'change',
                enabled: _canChange,
                onTap: _onChangePassword,
              ),

              const Spacer(),

              const Text(
                'sign up',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}