import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../auth/code_verification/code_verification_screen.dart';
import '../auth/services/auth_service.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/models/user_profile_model.dart';
import '../profile/services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  UserProfileModel? currentUser;
  bool isLoading = true;
  bool isSendingCode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      final profile = await _profileService.getMyProfile(token);

      if (!mounted) return;

      setState(() {
        currentUser = profile;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _openEditProfile() async {
    if (currentUser == null) return;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: currentUser!,
        ),
      ),
    );

    if (updated == true) {
      _loadProfile();
    }
  }

  Future<void> _openChangePasswordVerification() async {
    if (isSendingCode) return;

    setState(() => isSendingCode = true);

    try {
      final user = await _authService.getCurrentUser();
      final email = user['email']?.toString().trim();

      if (email == null || email.isEmpty) {
        throw Exception('Email is missing');
      }

      await _authService.forgotPassword(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CodeVerificationScreen(
            isResetPasswordFlow: true,
            email: email,
            openChangePasswordAfterVerify: true,
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
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSendingCode = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (_) => false,
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFC987F4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        height: 54,
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Log out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('About VOXA'),
          content: const Text(
            'VOXA is an AI-powered social media platform for sharing posts, voice content, comments and connecting with people.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          'assets/voxa_logo_clean.png',
                          width: 78,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _settingsItem(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: _openEditProfile,
                    ),
                    _settingsItem(
                      icon: Icons.lock_outline,
                      title: isSendingCode
                          ? 'Sending Code...'
                          : 'Change Password',
                      onTap: _openChangePasswordVerification,
                    ),
                    _settingsItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        );
                      },
                    ),
                    _settingsItem(
                      icon: Icons.info_outline,
                      title: 'About VOXA',
                      onTap: () {
                        _showAbout(context);
                      },
                    ),
                    const Spacer(),
                    _logoutButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}