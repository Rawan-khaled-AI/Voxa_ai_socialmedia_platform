import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../feed/models/post_model.dart';
import '../feed/services/post_service.dart';
import '../feed/widgets/post_card.dart';
import 'edit_profile_screen.dart';
import 'models/user_profile_model.dart';
import 'services/follow_service.dart';
import 'services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  final int? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final ProfileService _profileService =
      ProfileService();

  final PostService _postService =
      PostService();

  final FollowService _followService =
      FollowService();

  UserProfileModel? currentUser;

  List<PostModel> posts = [];

  bool isLoading = true;
  bool isMyProfile = false;

  bool isFollowing = false;
  bool isFollowLoading = false;

  int followersCount = 0;
  int followingCount = 0;

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final token =
          await AuthService().getToken();

      if (token == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final currentUserData =
          await AuthService().getCurrentUser();

      final currentUserId =
          currentUserData['id'];

      final profile = widget.userId != null
          ? await _profileService.getUserProfile(
              widget.userId!,
            )
          : await _profileService.getMyProfile(
              token,
            );

      bool following = false;
      int followers = 0;
      int followingUsers = 0;

      try {
        final followData =
            await _followService.getFollowStatus(
          profile.id,
        );

        following =
            followData['following'] ?? false;

        followers =
            followData['followers_count'] ?? 0;

        followingUsers =
            followData['following_count'] ?? 0;
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        currentUser = profile;

        isMyProfile =
            profile.id == currentUserId;

        isFollowing = following;
        followersCount = followers;
        followingCount = followingUsers;

        isLoading = false;
      });

      try {
        final userPosts =
            await _postService.getUserPosts(
          profile.id,
        );

        if (!mounted) return;

        setState(() {
          posts = userPosts;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          posts = [];
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (currentUser == null ||
        isMyProfile ||
        isFollowLoading) {
      return;
    }

    try {
      setState(() {
        isFollowLoading = true;
      });

      final result =
          await _followService.toggleFollow(
        currentUser!.id,
      );

      if (!mounted) return;

      setState(() {
        isFollowing =
            result['following'] ?? false;

        followersCount =
            result['followers_count'] ??
                followersCount;

        followingCount =
            result['following_count'] ??
                followingCount;

        isFollowLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isFollowLoading = false;
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

  Future<void> _openEditProfile() async {
    if (currentUser == null) return;

    final updated =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(
          user: currentUser!,
        ),
      ),
    );

    if (updated == true) {
      _loadProfileData();
    }
  }

  List<PostModel> get visiblePosts {
    if (selectedTab == 1) {
      return posts.where((post) {
        final audio =
            post.audioUrl;

        return audio != null &&
            audio.isNotEmpty &&
            audio != 'string';
      }).toList();
    }

    return posts;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAFD),

      body: Container(
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            begin:
                Alignment.topCenter,
            end: Alignment
                .bottomCenter,
            colors: [
              Color(0xFFFFFAFD),
              Color(0xFFF6EDFF),
            ],
          ),
        ),

        child: SafeArea(
          child: isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        AppColors.primary,
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadProfileData,

                  color:
                      AppColors.primary,

                  child: ListView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      18,
                      8,
                      18,
                      120,
                    ),

                    children: [
                      _buildTopBar(),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildProfileCard(),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildTabs(),

                      const SizedBox(
                        height: 18,
                      ),

                      if (visiblePosts
                          .isEmpty)
                        _buildEmptyState()
                      else
                        ...visiblePosts
                            .map(
                          (post) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    16,
                              ),
                              child:
                                  PostCard(
                                post:
                                    post,
                                allowOpenProfile:
                                    false,
                                onPostUpdated:
                                    _updatePostInList,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
        ),
      ),

      bottomNavigationBar:
          _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 58,

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
              Icons
                  .notifications_none,
              size: 31,
            ),

            color:
                AppColors.primary,
          ),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.settings,
              );
            },

            icon: const Icon(
              Icons.settings_outlined,
              size: 31,
            ),

            color:
                AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final hasProfileImage =
        currentUser
                    ?.profileImageUrl !=
                null &&
            currentUser!
                .profileImageUrl!
                .isNotEmpty &&
            currentUser!
                    .profileImageUrl !=
                'string';

    final profileImageUrl =
        hasProfileImage
            ? '${ApiService.baseUrl}${currentUser!.profileImageUrl}'
            : null;

    final name =
        currentUser?.name ??
            'rawan';

    final initial =
        name.isNotEmpty
            ? name[0]
                .toUpperCase()
            : 'R';

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        22,
        26,
        22,
        26,
      ),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          34,
        ),

        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9FF),
            Color(0xFFF6E7FF),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.purple
                .withOpacity(.07),

            blurRadius: 26,

            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          Stack(
            alignment:
                Alignment.bottomRight,

            children: [
              Container(
                padding:
                    const EdgeInsets
                        .all(5),

                decoration:
                    const BoxDecoration(
                  color:
                      Colors.white,

                  shape:
                      BoxShape.circle,
                ),

                child: CircleAvatar(
                  radius: 58,

                  backgroundColor:
                      const Color(
                    0xFFEEDBFF,
                  ),

                  backgroundImage:
                      profileImageUrl !=
                              null
                          ? NetworkImage(
                              profileImageUrl,
                            )
                          : null,

                  child:
                      profileImageUrl ==
                              null
                          ? Text(
                              initial,

                              style:
                                  const TextStyle(
                                color:
                                    AppColors.primary,

                                fontWeight:
                                    FontWeight.bold,

                                fontSize:
                                    34,
                              ),
                            )
                          : null,
                ),
              ),

              if (isMyProfile)
                Container(
                  width: 46,
                  height: 46,

                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,

                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(
                          0xFFD86BFF,
                        ),
                        Color(
                          0xFF8E45FF,
                        ),
                      ],
                    ),

                    border:
                        Border.all(
                      color:
                          Colors.white,

                      width: 3,
                    ),
                  ),

                  child: const Icon(
                    Icons
                        .camera_alt_outlined,

                    color:
                        Colors.white,

                    size: 22,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            name,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 31,

              fontWeight:
                  FontWeight.w900,

              color:
                  AppColors.textDark,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            '@${name.toLowerCase()}.voxa',

            style:
                const TextStyle(
              color:
                  Color(0xFF8F889A),

              fontSize: 17,

              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            currentUser
                        ?.bio
                        ?.isNotEmpty ==
                    true
                ? currentUser!.bio!
                : 'just sharing my thoughts.. 💜',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  AppColors.textDark,

              fontSize: 16,

              height: 1.4,

              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _StatItem(
                value:
                    followersCount.toString(),
                label: 'Followers',
              ),

              const SizedBox(
                width: 44,
              ),

              _StatItem(
                value:
                    followingCount.toString(),
                label: 'Following',
              ),
            ],
          ),

          if (isMyProfile) ...[
            const SizedBox(
              height: 22,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 56,

              child:
                  OutlinedButton.icon(
                onPressed:
                    _openEditProfile,

                icon: const Icon(
                  Icons
                      .edit_outlined,
                ),

                label: const Text(
                  'Edit Profile',
                ),

                style:
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      AppColors
                          .primary,

                  side:
                      const BorderSide(
                    color: Color(
                      0xFFC77BFF,
                    ),

                    width: 1.3,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),

                  textStyle:
                      const TextStyle(
                    fontSize: 17,

                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),
            ),
          ],

          if (!isMyProfile) ...[
            const SizedBox(
              height: 22,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 56,

              child:
                  ElevatedButton(
                onPressed:
                    isFollowLoading
                        ? null
                        : _toggleFollow,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      isFollowing
                          ? Colors.white
                          : AppColors
                              .primary,

                  foregroundColor:
                      isFollowing
                          ? AppColors
                              .primary
                          : Colors.white,

                  disabledBackgroundColor:
                      AppColors.primary
                          .withOpacity(.45),

                  disabledForegroundColor:
                      Colors.white,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),

                    side:
                        const BorderSide(
                      color:
                          AppColors.primary,
                      width: 1.2,
                    ),
                  ),

                  textStyle:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                child: isFollowLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color:
                              Colors.white,
                        ),
                      )
                    : Text(
                        isFollowing
                            ? 'Following'
                            : 'Follow',
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 74,

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          .92,
        ),

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.purple
                .withOpacity(.05),

            blurRadius: 18,

            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          _TabItem(
            icon:
                Icons.grid_view_rounded,

            label: 'Posts',

            isSelected:
                selectedTab == 0,

            onTap: () {
              setState(() {
                selectedTab = 0;
              });
            },
          ),

          _TabItem(
            icon:
                Icons.graphic_eq,

            label: 'Voices',

            isSelected:
                selectedTab == 1,

            onTap: () {
              setState(() {
                selectedTab = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 40,
      ),

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(
          .9,
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.auto_awesome,

            color:
                AppColors.primary,

            size: 34,
          ),

          SizedBox(height: 12),

          Text(
            'No posts here yet',

            style: TextStyle(
              color:
                  AppColors.textDark,

              fontWeight:
                  FontWeight.w800,

              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 94,

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFD86BFF),
            Color(0xFF9F55FF),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.purple
                .withOpacity(.18),

            blurRadius: 24,

            offset:
                const Offset(
              0,
              -8,
            ),
          ),
        ],

        borderRadius:
            const BorderRadius.only(
          topLeft:
              Radius.circular(34),
          topRight:
              Radius.circular(34),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 42,
            vertical: 10,
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              _NavItem(
                icon: Icons.home,

                label: 'Home',

                isSelected: false,

                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.feed,
                    (
                      route,
                    ) =>
                        false,
                  );
                },
              ),

              _PlusButton(
                onTap: () async {
                  final result =
                      await Navigator
                          .pushNamed(
                    context,
                    AppRoutes
                        .createPost,
                  );

                  if (result ==
                      true) {
                    _loadProfileData();
                  }
                },
              ),

              _NavItem(
                icon:
                    Icons.search,
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

class _StatItem
    extends StatelessWidget {
  final String value;

  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w900,
            fontSize: 20,
            color:
                AppColors.textDark,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          label,
          style:
              const TextStyle(
            color:
                Color(0xFF8F889A),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TabItem
    extends StatelessWidget {
  final IconData icon;

  final String label;

  final bool isSelected;

  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            Icon(
              icon,

              color: isSelected
                  ? AppColors
                      .primary
                  : const Color(
                      0xFF9A92A8,
                    ),

              size: 25,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              label,

              style: TextStyle(
                color: isSelected
                    ? AppColors
                        .primary
                    : const Color(
                        0xFF8F889A,
                      ),

                fontSize: 15,

                fontWeight:
                    isSelected
                        ? FontWeight
                            .w900
                        : FontWeight
                            .w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds:
                    220,
              ),

              width:
                  isSelected
                      ? 76
                      : 0,

              height: 3,

              decoration:
                  BoxDecoration(
                color: AppColors
                    .primary,

                borderRadius:
                    BorderRadius
                        .circular(
                  999,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(
        999,
      ),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Container(
            width: 48,
            height: 48,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              color: isSelected
                  ? Colors.white
                      .withOpacity(
                      .28,
                    )
                  : Colors
                      .transparent,
            ),

            child: Icon(
              icon,

              color: Colors.white,

              size: 28,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,

            style: TextStyle(
              color: Colors.white,

              fontSize: 12,

              fontWeight:
                  isSelected
                      ? FontWeight
                          .w800
                      : FontWeight
                          .w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusButton
    extends StatelessWidget {
  final VoidCallback onTap;

  const _PlusButton({
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(
        999,
      ),

      child: Container(
        width: 70,
        height: 70,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color:
              Colors.white.withOpacity(
            .12,
          ),

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