import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import 'code_verification/code_verification_screen.dart';
import 'services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = AppRoutes.forgotPassword;

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final email = TextEditingController();

  bool _isLoading = false;

  bool get _canSend {
    final e = email.text.trim();

    if (e.isEmpty) return false;
    if (!e.contains('@') || !e.contains('.')) return false;
    if (_isLoading) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> _onSendCode() async {
    if (!_canSend) return;

    setState(() => _isLoading = true);

    try {
      final userEmail = email.text.trim();

      await AuthService().forgotPassword(
        email: userEmail,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CodeVerificationScreen(
            isResetPasswordFlow: true,
            email: userEmail,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          duration: const Duration(seconds: 3),
        ),
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
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: GradientBG(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    size.height - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 70),
                  Image.asset(
                    'assets/voxa_logo_white.png',
                    width: size.width * 0.55,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Forgot\nPassword',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Enter your email to receive verification code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  VoxaTextField(
                    label: 'Email',
                    controller: email,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: size.width * 0.62,
                    height: 54,
                    child: VoxaButton(
                      text: _isLoading ? 'Loading...' : 'Send Code',
                      enabled: _canSend,
                      onTap: _onSendCode,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}