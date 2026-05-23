import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../feed/models/post_model.dart';
import '../post/post_details_screen.dart';
import '../profile/models/user_profile_model.dart';
import 'services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _service =
      SearchService();

  final TextEditingController _controller =
      TextEditingController();

  Timer? _debounce;

  List<UserProfileModel> users = [];
  List<PostModel> posts = [];

  bool isLoading = false;
  String query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    query = value.trim();

    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        users = [];
        posts = [];
        isLoading = false;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () {
        _search(query);
      },
    );
  }

  Future<void> _search(String value) async {
    try {
      setState(() {
        isLoading = true;
      });

      final results = await Future.wait([
        _service.searchUsers(value),
        _service.searchPosts(value),
      ]);

      if (!mounted) return;

      setState(() {
        users =
            results[0] as List<UserProfileModel>;
        posts = results[1] as List<PostModel>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _openUser(UserProfileModel user) {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: user.id,
    );
  }

  void _openPost(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(
          post: post,
        ),
      ),
    );
  }

  bool _validPath(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value != 'string';
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery =
        query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAFD),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFAFD),
              Color(0xFFF6EDFF),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            28,
          ),
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(.94),
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color:
                      const Color(0xFFE4C8FF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple
                        .withOpacity(.05),
                    blurRadius: 18,
                    offset:
                        const Offset(0, 7),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged:
                    _onSearchChanged,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Search users or posts...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(
                child:
                    CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            else if (!hasQuery)
              _EmptySearchState()
            else if (users.isEmpty &&
                posts.isEmpty)
              _NoResultsState()
            else ...[
              if (users.isNotEmpty) ...[
                _SectionTitle(
                  title: 'Users',
                ),
                const SizedBox(height: 10),
                ...users.map(
                  (user) => _UserResultTile(
                    user: user,
                    onTap: () =>
                        _openUser(user),
                    validPath:
                        _validPath,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              if (posts.isNotEmpty) ...[
                _SectionTitle(
                  title: 'Posts',
                ),
                const SizedBox(height: 10),
                ...posts.map(
                  (post) => _PostResultTile(
                    post: post,
                    onTap: () =>
                        _openPost(post),
                    validPath:
                        _validPath,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final UserProfileModel user;
  final VoidCallback onTap;
  final bool Function(String?) validPath;

  const _UserResultTile({
    required this.user,
    required this.onTap,
    required this.validPath,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        validPath(user.profileImageUrl)
            ? '${ApiService.baseUrl}${user.profileImageUrl}'
            : null;

    final initial = user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(22),
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(.92),
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  const Color(0xFFEEDBFF),
              backgroundImage:
                  imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
              child: imageUrl == null
                  ? Text(
                      initial,
                      style:
                          const TextStyle(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color:
                          AppColors.textDark,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.bio?.isNotEmpty == true
                        ? user.bio!
                        : '@${user.name.toLowerCase()}.voxa',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          Color(0xFF8F889A),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostResultTile extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final bool Function(String?) validPath;

  const _PostResultTile({
    required this.post,
    required this.onTap,
    required this.validPath,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        validPath(post.imageUrl)
            ? '${ApiService.baseUrl}${post.imageUrl}'
            : null;

    final actorImageUrl =
        validPath(post.user.profileImageUrl)
            ? '${ApiService.baseUrl}${post.user.profileImageUrl}'
            : null;

    final initial =
        post.user.name.isNotEmpty
            ? post.user.name[0].toUpperCase()
            : '?';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(22),
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(.92),
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  const Color(0xFFEEDBFF),
              backgroundImage:
                  actorImageUrl != null
                      ? NetworkImage(
                          actorImageUrl,
                        )
                      : null,
              child: actorImageUrl == null
                  ? Text(
                      initial,
                      style:
                          const TextStyle(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    post.user.name,
                    style: const TextStyle(
                      color:
                          AppColors.textDark,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.text.isNotEmpty
                        ? post.text
                        : 'Voice or media post',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          Color(0xFF8F889A),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (imageUrl != null) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (validPath(post.audioUrl)) ...[
              const SizedBox(width: 10),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF6EDFF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 160),
      child: Center(
        child: Text(
          'Start typing to search 🔍',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 160),
      child: Center(
        child: Text(
          'No results found',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}