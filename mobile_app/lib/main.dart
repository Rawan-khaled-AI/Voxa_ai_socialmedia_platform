import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/code_verification/code_verification_screen.dart';
import 'features/auth/new_password/new_password_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/feed/feed_screen.dart';
import 'features/post/create_post_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const VoxaApp());
}

class VoxaApp extends StatelessWidget {
  const VoxaApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => SignInScreen());

      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case AppRoutes.codeVerification:
        return MaterialPageRoute(
          builder: (_) => CodeVerificationScreen(),
        );

      case AppRoutes.newPassword:
        return MaterialPageRoute(builder: (_) => NewPasswordScreen());

      case AppRoutes.feed:
        return MaterialPageRoute(builder: (_) => FeedScreen());

      case AppRoutes.createPost:
        return MaterialPageRoute(builder: (_) => CreatePostScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const RouteNotFoundScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOXA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Route not found'),
      ),
    );
  }
}