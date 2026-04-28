import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import 'code_verification/code_verification_screen.dart';
import 'services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = AppRoutes.signUp;

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool _isLoading = false;

  bool get _canSignUp {
    final n = name.text.trim();
    final e = email.text.trim();
    final p = password.text.trim();
    final c = confirmPassword.text.trim();

    if (n.isEmpty || e.isEmpty || p.isEmpty || c.isEmpty) return false;
    if (!e.contains('@') || !e.contains('.')) return false;
    if (p.length < 6) return false;
    if (p != c) return false;
    if (_isLoading) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();

    void listen() => setState(() {});
    name.addListener(listen);
    email.addListener(listen);
    password.addListener(listen);
    confirmPassword.addListener(listen);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_canSignUp) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().signup(
        name: name.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'User created successfully.'),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const CodeVerificationScreen(isResetPasswordFlow: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
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
      body: GradientBG(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
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
              Image.asset(
                'assets/voxa_logo_white.png',
                width: size.width * 0.55,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              VoxaTextField(label: 'Name', controller: name),
              const SizedBox(height: 16),
              VoxaTextField(label: 'Email', controller: email),
              const SizedBox(height: 16),
              VoxaTextField(
                label: 'Password',
                controller: password,
                obscure: true,
              ),
              const SizedBox(height: 16),
              VoxaTextField(
                label: 'Confirm Password',
                controller: confirmPassword,
                obscure: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width * 0.62,
                height: 54,
                child: VoxaButton(
                  text: _isLoading ? 'Loading...' : 'Sign Up',
                  enabled: _canSignUp,
                  onTap: _onSignUp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
