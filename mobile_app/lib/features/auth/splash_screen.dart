import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/widgets/gradient_bg.dart';
import '../auth/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = AppRoutes.splash;

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await _authService.getToken();

      if (token == null || token.isEmpty) {
        _goToWelcome();
        return;
      }

      await _authService.getCurrentUser();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.feed,
      );
    } catch (_) {
      await _authService.logout();
      _goToWelcome();
    }
  }

  void _goToWelcome() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBG(
        child: Center(
          child: Image.asset(
            'assets/voxa_logo_color.png',
            width: size.width * 1.5,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}