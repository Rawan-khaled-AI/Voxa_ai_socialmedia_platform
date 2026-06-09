import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
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
        setState(() {
          isLoading = false;
        });
        return;
      }

      final profile =
          await _profileService.getMyProfile(token);

      if (!mounted) return;

      setState(() {
        currentUser = profile;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
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

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (_) => false,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color ?? AppColors.primary,
        ),
        onTap: onTap,
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
              onPressed: () {
                Navigator.pop(context);
              },
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
      backgroundColor: AppColors.bgTop,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _tile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: _openEditProfile,
                  ),
                  _tile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.changePassword,
                      );
                    },
                  ),
                  _tile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notifications,
                      );
                    },
                  ),
                  _tile(
                    icon: Icons.info_outline,
                    title: 'About VOXA',
                    onTap: () {
                      _showAbout(context);
                    },
                  ),
                  const Spacer(),
                  _tile(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      _logout(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}