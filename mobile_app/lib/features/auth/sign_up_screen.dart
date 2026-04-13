import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import 'code_verification/code_verification_screen.dart';

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

  bool get _canSignUp {
    final n = name.text.trim();
    final e = email.text.trim();
    final p = password.text.trim();
    final c = confirmPassword.text.trim();

    if (n.isEmpty || e.isEmpty || p.isEmpty || c.isEmpty) return false;
    if (!e.contains('@') || !e.contains('.')) return false;
    if (p.length < 6) return false;
    if (p != c) return false;

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

  void _onSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent')),
    );

    Navigator.pushNamed(
      context,
      CodeVerificationScreen.routeName,
    );
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
              VoxaTextField(
                label: 'Name',
                controller: name,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              VoxaTextField(
                label: 'Email',
                controller: email,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              VoxaTextField(
                label: 'Password',
                controller: password,
                obscure: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              VoxaTextField(
                label: 'Confirm Password',
                controller: confirmPassword,
                obscure: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width * 0.62,
                height: 54,
                child: VoxaButton(
                  text: 'Sign Up',
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