import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../profile/services/profile_service.dart';
import 'models/post_model.dart';
import 'services/post_service.dart';
import 'widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  static const String routeName = AppRoutes.feed;

  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();

  List<PostModel> posts = [];
  bool isLoading = true;

  String? currentUserImage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final data = await _postService.getPosts();

      try {
        final token = await AuthService().getToken();

        if (token != null) {
          final profile =
              await _profileService.getMyProfile(token);

          currentUserImage = profile.profileImageUrl;
        }
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _updatePostInList(PostModel updatedPost) {
    setState(() {
      posts = posts.map((post) {
        return post.id == updatedPost.id
            ? updatedPost
            : post;
      }).toList();
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (route) => false,
    );
  }

  void _openMyProfile() {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFD),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFAFD),
              Color(0xFFF6EDFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : posts.isEmpty
                        ? const Center(
                            child: Text(
                              'No posts yet',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadPosts,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                110,
                              ),
                              itemCount: posts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, index) {
                                return PostCard(
                                  post: posts[index],
                                  onPostUpdated: _updatePostInList,
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        6,
      ),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Image.asset(
                'assets/voxa_logo_clean.png',
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.notifications,
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                size: 31,
              ),
              color: AppColors.primary,
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.settings_outlined,
                size: 31,
              ),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 94,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD86BFF),
            Color(0xFF9F55FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(.18),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 42,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ProfileNavItem(
                imagePath: currentUserImage,
                onTap: _openMyProfile,
              ),
              _PlusButton(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.createPost,
                  );

                  if (result == true) {
                    _loadPosts();
                  }
                },
              ),
              _NavItem(
                icon: Icons.search,
                label: 'Search',
                isSelected: false,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.search,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ProfileNavItem({
    required this.imagePath,
    required this.onTap,
  });

  bool get hasImage {
    return imagePath != null &&
        imagePath!.isNotEmpty &&
        imagePath != 'string';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        hasImage ? '${ApiService.baseUrl}$imagePath' : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.6,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _fallback();
                      },
                    )
                  : _fallback(),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withOpacity(.24),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withOpacity(.28)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlusButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.12),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: const Icon(
          Icons.add,
          size: 42,
          color: Colors.white,
        ),
      ),
    );
  }
}