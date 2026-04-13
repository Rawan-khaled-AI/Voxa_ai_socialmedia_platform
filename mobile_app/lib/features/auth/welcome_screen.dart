import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  static const String routeName = AppRoutes.welcome;

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBG(
        child: Stack(
          children: [
            Positioned(
              top: size.height * 0.18,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/voxa_logo_white.png',
                  width: size.width * 1.50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size.width * 0.62,
                    height: 54,
                    child: VoxaButton(
                      text: 'Sign In',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signIn);
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: size.width * 0.62,
                    height: 54,
                    child: VoxaButton(
                      text: 'Sign Up',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}