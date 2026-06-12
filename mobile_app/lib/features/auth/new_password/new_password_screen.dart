import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/voxa_button.dart';
import '../../../shared/widgets/voxa_text_field.dart';
import '../services/auth_service.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String routeName = AppRoutes.newPassword;

  final String? email;

  const NewPasswordScreen({
    super.key,
    this.email,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  String? _error;
  bool _isLoading = false;

  bool get _canChange {
    final newP = _newPasswordController.text.trim();
    final confirmP = _confirmPasswordController.text.trim();

    if (newP.isEmpty || confirmP.isEmpty) return false;
    if (newP.length < 6) return false;
    if (newP != confirmP) return false;
    if (_isLoading) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();

    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    void listen() => setState(() => _error = null);

    _newPasswordController.addListener(listen);
    _confirmPasswordController.addListener(listen);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onChangePassword() async {
    if (!_canChange) return;

    final email = widget.email?.trim();

    if (email == null || email.isEmpty) {
      setState(() => _error = 'Email is missing.');
      return;
    }

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

    setState(() => _isLoading = true);

    try {
      await AuthService().resetPassword(
        email: email,
        newPassword: newP,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(
        () => _error = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
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
                    text: _isLoading ? 'Loading...' : 'change',
                    enabled: _canChange,
                    onTap: _onChangePassword,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}