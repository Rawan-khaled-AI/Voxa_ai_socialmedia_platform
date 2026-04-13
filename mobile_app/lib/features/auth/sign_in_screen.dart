import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/widgets.dart';
import 'code_verification/code_verification_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  static const String routeName = AppRoutes.signIn;

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool get _canSignIn {
    final e = email.text.trim();
    final p = password.text.trim();

    if (e.isEmpty || p.isEmpty) return false;
    if (!e.contains('@') || !e.contains('.')) return false;
    if (p.length < 6) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();

    void listen() => setState(() {});
    email.addListener(listen);
    password.addListener(listen);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBG(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              const SizedBox(height: 20),

              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              SizedBox(
                width: size.width * 0.62,
                height: 54,
                child: VoxaButton(
                  text: 'Sign In',
                  enabled: _canSignIn,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.feed,
                    );
                  },
                ),
              ),

              const SizedBox(height: 11),

              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code sent'),
                    ),
                  );

                  Navigator.pushNamed(
                    context,
                    CodeVerificationScreen.routeName,
                  );
                },
                child: const Text(
                  'forget password',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 13),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have account? ",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SignUpScreen.routeName,
                      );
                    },
                    child: const Text(
                      "sign up",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}