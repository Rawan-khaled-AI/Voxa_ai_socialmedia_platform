import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/widgets/gradient_bg.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = AppRoutes.splash;

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.welcome,
      );
    });
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