import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'models/post_model.dart';
import 'widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  static const String routeName = AppRoutes.feed;

  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _showWelcomePostOnce = true;
  int _currentIndex = 0;

  List<PostModel> _posts() {
    final list = <PostModel>[];

    if (_showWelcomePostOnce) {
      list.add(
        const PostModel(
          username: 'voxa',
          avatarUrl: 'assets/avatar_1.jpg',
          text:
              'مصر… حكايات عمرها آلاف السنين 🇪🇬\nVOXA مساحة تحكي فيها وتسمّع العالم.',
          imageAsset: 'assets/demo_pyramids.jpg',
          likes: 0,
          comments: 0,
        ),
      );
    }

    list.addAll(const [
      PostModel(
        username: 'cristina',
        avatarUrl: 'assets/avatar_1.jpg',
        text:
            'A timeless wonder that still leaves the world in awe.\nHistory, mystery, and pure Egyptian magic.',
        imageAsset: 'assets/demo_pyramids.jpg',
        likes: 503,
        comments: 49,
      ),
      PostModel(
        username: 'ahmed ali',
        avatarUrl: 'assets/avatar_1.jpg',
        text: 'صباح الفل ✨',
        imageAsset: 'assets/demo_pyramids.jpg',
        likes: 120,
        comments: 12,
      ),
    ]);

    return list;
  }

  void _onTapNav(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.createPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = _posts();

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
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (_showWelcomePostOnce &&
              n is ScrollUpdateNotification &&
              n.metrics.pixels > 10) {
            setState(() => _showWelcomePostOnce = false);
          }
          return false;
        },
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) => PostCard(
            post: posts[i],
            showTopDivider: i != 0,
          ),
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
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTapNav(0),
                ),
                _PlusButton(onTap: () => _onTapNav(1)),
                _NavItem(
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search,
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTapNav(2),
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