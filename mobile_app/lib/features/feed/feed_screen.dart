import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
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

  List<PostModel> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final data = await _postService.getPosts();

      setState(() {
        posts = data.map<PostModel>((e) {
          return PostModel(
            username: "user_${e['user_id']}",
            avatarUrl: 'assets/avatar_1.jpg',
            text: e['text'] ?? '',
            imageUrl: e['image_url'],
            likes: 0,
            comments: 0,
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Image.asset(
          'assets/voxa_logo_color.png',
          height: 30,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text("No posts yet"))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) => PostCard(
                    post: posts[i],
                    showTopDivider: i != 0,
                  ),
                ),
      bottomNavigationBar: Container(
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAD9FF),
              const Color(0xFFB88CFF).withOpacity(0.85),
            ],
          ),
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  isSelected: true,
                  onTap: () {},
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
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 30,
          color: Colors.white,
        ),
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
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.add,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}