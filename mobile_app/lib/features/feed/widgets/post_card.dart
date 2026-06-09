import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/services/follow_service.dart';
import '../models/post_model.dart';
import '../services/like_service.dart';
import '../services/post_service.dart';


class PostCard extends StatefulWidget {
  
  final PostModel post;
  final ValueChanged<PostModel>? onPostUpdated;
  final ValueChanged<int>? onPostDeleted;
  final bool allowOpenProfile;

  const PostCard({
    super.key,
    required this.post,
    this.onPostUpdated,
    this.onPostDeleted,
    this.allowOpenProfile = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  final LikeService _likeService = LikeService();
  final FollowService _followService = FollowService();
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();

  late bool isLiked;
  bool showHeart = false;
  bool isPlaying = false;
  bool isTextExpanded = false;
  bool isAudioLoading = false;
  bool isLikeLoading = false;

  bool isFollowing = false;
  bool isFollowLoading = false;
  bool isMyPost = false;

  late int likesCount;
  late int commentsCount;

  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  late final AnimationController _waveController;

  late final AudioPlayer _player;

  final Random _random = Random();

  Duration? _audioDuration;
  Duration _audioPosition = Duration.zero;
  String? _loadedAudioUrl;

  List<double> bars = [
    10,
    15,
    22,
    30,
    24,
    16,
    11,
    18,
    26,
    34,
    28,
    17,
    12,
    20,
    31,
    38,
    25,
    15,
    12,
    18,
    27,
    35,
    22,
    14,
  ];

  @override
  void initState() {
    super.initState();

    likesCount = widget.post.likes;
    commentsCount = widget.post.comments;
    isLiked = widget.post.isLiked;

    _player = AudioPlayer();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartScale = Tween<double>(
      begin: 0.5,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeOut,
      ),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _waveController.addListener(() {
      if (!isPlaying) return;

      for (int i = 0; i < bars.length; i++) {
        bars[i] = (8 + _random.nextInt(34)).toDouble();
      }

      if (mounted && _waveController.value > .78) {
        setState(() {});
      }
    });

    _waveController.repeat();

    _player.durationStream.listen((duration) {
      if (!mounted) return;

      setState(() {
        _audioDuration = duration;
      });
    });

    _player.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        _audioPosition = position;
      });
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!mounted) return;

        setState(() {
          isPlaying = false;
          _audioPosition = Duration.zero;
        });

        _player.seek(Duration.zero);
      }
    });

    final audioPath = widget.post.audioUrl;

    if (_validPath(audioPath)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAudioDuration(audioPath!);
      });
    }

    _loadFollowState();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likes != widget.post.likes ||
        oldWidget.post.comments != widget.post.comments ||
        oldWidget.post.isLiked != widget.post.isLiked) {
      likesCount = widget.post.likes;
      commentsCount = widget.post.comments;
      isLiked = widget.post.isLiked;
    }

    if (oldWidget.post.user.id != widget.post.user.id) {
      _loadFollowState();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _heartController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowState() async {
    try {
      final currentUser =
          await _authService.getCurrentUser();

      final currentUserId = currentUser['id'];

      if (!mounted) return;

      if (currentUserId == widget.post.user.id) {
        setState(() {
          isMyPost = true;
          isFollowing = false;
        });

        return;
      }

      final status =
          await _followService.getFollowStatus(
        widget.post.user.id,
      );

      if (!mounted) return;

      setState(() {
        isMyPost = false;
        isFollowing =
            status['following'] ?? false;
      });
    } catch (_) {}
  }
  Future<void> _toggleFollow() async {
    if (isMyPost || isFollowLoading) return;

    try {
      setState(() {
        isFollowLoading = true;
      });

      await _followService.toggleFollow(
        widget.post.user.id,
      );
      await _loadFollowState();
      if (!mounted) return;

      setState(() {
        isFollowLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isFollowLoading = false;
      });
    }
  }
  bool _validPath(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value != 'string';
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }

    final minutes =
        duration.inMinutes.toString().padLeft(2, '0');

    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  double get _audioProgress {
    final duration = _audioDuration;

    if (duration == null || duration.inMilliseconds == 0) {
      return 0;
    }

    final progress =
        _audioPosition.inMilliseconds / duration.inMilliseconds;

    return progress.clamp(0, 1);
  }

  PostModel get _currentPost {
    return widget.post.copyWith(
      likes: likesCount,
      comments: commentsCount,
      isLiked: isLiked,
    );
  }

  void _notifyParent() {
    widget.onPostUpdated?.call(_currentPost);
  }

  Future<void> _loadAudioDuration(String audioUrl) async {
    try {
      final fullAudioUrl = '${ApiService.baseUrl}$audioUrl';

      if (_loadedAudioUrl == fullAudioUrl &&
          _audioDuration != null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        isAudioLoading = true;
      });

      final duration = await _player.setUrl(fullAudioUrl);

      if (!mounted) return;

      setState(() {
        _loadedAudioUrl = fullAudioUrl;
        _audioDuration = duration ?? _player.duration;
        isAudioLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isAudioLoading = false;
      });
    }
  }

  Future<void> _onDoubleTap() async {
    setState(() {
      showHeart = true;
    });

    if (!isLiked) {
      await _toggleLike();
    }

    await _heartController.forward();

    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    setState(() {
      showHeart = false;
    });

    _heartController.reset();
  }

  Future<void> _toggleAudio(String audioUrl) async {
    try {
      final fullAudioUrl = '${ApiService.baseUrl}$audioUrl';

      if (isPlaying) {
        await _player.pause();

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });

        return;
      }

      if (_loadedAudioUrl != fullAudioUrl) {
        await _loadAudioDuration(audioUrl);
      }

      await _player.play();

      if (!mounted) return;

      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void _openImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.92),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 42,
                right: 20,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openProfile() async {
    if (!widget.allowOpenProfile) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: widget.post.user.id,
    );
    if (!mounted) return;
    _loadFollowState();
  }

  Future<void> _openPostDetails() async {
    final updatedPost =
        await Navigator.pushNamed(
      context,
      AppRoutes.postDetails,
      arguments: _currentPost,
    );
    if (!mounted) return;
    await _loadFollowState();

    if (updatedPost is PostModel) {
      setState(() {
        likesCount = updatedPost.likes;
        commentsCount = updatedPost.comments;
        isLiked = updatedPost.isLiked;
      });
      _notifyParent();
    }
  }

  Future<void> _toggleLike() async {
    if (isLikeLoading) return;

    final previousLiked = isLiked;
    final previousCount = likesCount;

    setState(() {
      isLikeLoading = true;

      if (isLiked) {
        isLiked = false;
        likesCount = likesCount > 0 ? likesCount - 1 : 0;
      } else {
        isLiked = true;
        likesCount++;
      }
    });

    try {
      final result = await _likeService.toggleLike(
        widget.post.id,
      );

      if (!mounted) return;

      setState(() {
        isLiked = result['liked'] == true;
        likesCount = result['likes_count'] is int
            ? result['likes_count']
            : likesCount;
        isLikeLoading = false;
      });

      _notifyParent();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLiked = previousLiked;
        likesCount = previousCount;
        isLikeLoading = false;
      });
    }
  }

  Future<void> _sharePost() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(26),
      ),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.repeat_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Repost to VOXA',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _repostToVoxa();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.ios_share_outlined,
                color: AppColors.primary,
              ),
              title: const Text(
                'Share externally',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _shareExternally();
              },
            ),
          ],
        ),
      );
    },
  );
}
  Future<void> _repostToVoxa() async {
  try {
    final postId = widget.post.isRepost
        ? widget.post.repostOfPostId ?? widget.post.id
        : widget.post.id;

    await _postService.repostPost(postId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reposted to your profile'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}

  Future<void> _shareExternally() async {
    final post = widget.post.originalPost;

    final text = widget.post.isRepost
        ? post?.text.trim() ?? ''
        : widget.post.text.trim();

    final link =
        'https://voxa.app/post/${widget.post.isRepost ? widget.post.repostOfPostId : widget.post.id}';

    final content = text.isNotEmpty
        ? '$text\n\n$link'
        : 'Check out this post on VOXA\n\n$link';

    await Share.share(content);
  }
  Future<void> _showPostMenu() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMyPost) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    _editPost();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deletePost();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Report Post'),
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted'),
                      ),
                    );
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy Text'),
                onTap: () async {
                  Navigator.pop(context);

                  final text = widget.post.isRepost
                      ? widget.post.originalPost?.text ?? ''
                      : widget.post.text;

                  await Clipboard.setData(
                    ClipboardData(text: text),
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text copied'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _editPost() async {
  if (widget.post.isRepost) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cannot edit a repost'),
      ),
    );
    return;
  }

  final controller = TextEditingController(
    text: widget.post.text,
  );

  final updatedText = await showDialog<String>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your post...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  if (updatedText == null || updatedText.isEmpty) {
    return;
  }

  try {
    final updatedPost = await _postService.updatePost(
      postId: widget.post.id,
      text: updatedText,
    );

    if (!mounted) return;

    widget.onPostUpdated?.call(updatedPost);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post updated successfully'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            widget.post.isRepost
                ? 'Remove repost?'
                : 'Delete post?',
          ),
          content: Text(
            widget.post.isRepost
                ? 'This repost will be removed from your profile.'
                : 'This post will be deleted permanently.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _postService.deletePost(
        widget.post.id,
      );
      widget.onPostDeleted?.call(
        widget.post.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.post.isRepost
                ? 'Repost removed'
                : 'Post deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRepost = widget.post.isRepost;
    final displayText = isRepost
        ? widget.post.originalPost?.text ?? ''
        : widget.post.text;
    final imagePath = isRepost
        ? widget.post.originalPost?.imageUrl
        : widget.post.imageUrl;
    final audioPath = isRepost
        ? widget.post.originalPost?.audioUrl
        : widget.post.audioUrl;
    final fullImageUrl = _validPath(imagePath)
        ? '${ApiService.baseUrl}$imagePath'
        : null;
    final hasAudio = _validPath(audioPath);

    return GestureDetector(
      onTap: _openPostDetails,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.97),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(.05),
              blurRadius: 24,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (displayText.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _buildText(),
                ),
              if (fullImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _buildImage(fullImageUrl),
                ),
              if (hasAudio)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _buildVoiceCard(audioPath!),
                ),
              const SizedBox(height: 14),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
  final isRepost = widget.post.isRepost;

  final displayUser =
      isRepost ? widget.post.originalPost!.user : widget.post.user;

  final profileImage = displayUser.profileImageUrl;

  final hasProfileImage = profileImage != null &&
      profileImage.isNotEmpty &&
      profileImage != 'string';

  final imageUrl =
      hasProfileImage ? '${ApiService.baseUrl}$profileImage' : null;

  final initial = displayUser.name.isNotEmpty
      ? displayUser.name[0].toUpperCase()
      : '?';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (isRepost)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(
                Icons.repeat_rounded,
                size: 18,
                color: Color.fromARGB(255, 89, 21, 153),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.post.user.name} reposted',
                style: const TextStyle(
                  color: Color.fromARGB(255, 79, 16, 138),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEEDBFF),
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    displayUser.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '2h ago · 🌍',
                  style: TextStyle(
                    color: Color(0xFF8F889A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showPostMenu,
            icon: const Icon(
              Icons.more_horiz,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildText() {
    final text = widget.post.isRepost
        ? widget.post.originalPost?.text.trim() ?? ''
        : widget.post.text.trim();

    final shouldShowReadMore = text.length > 130;

    final arabic = isArabic(text);

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment:
            arabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign:
                arabic ? TextAlign.right : TextAlign.left,
            maxLines: isTextExpanded ? null : 4,
            overflow: isTextExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: arabic ? 17 : 16.5,
              height: 1.7,
              color: AppColors.textDark,
              fontWeight:
                  arabic ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          if (shouldShowReadMore && !isTextExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isTextExpanded = true;
                  });
                },
                child: Text(
                  arabic ? 'قراءة المزيد' : 'Read more',
                  style: const TextStyle(
                    color: Color(0xFF9F55FF),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String fullImageUrl) {
    return GestureDetector(
      onTap: () => _openImage(fullImageUrl),
      onDoubleTap: _onDoubleTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFFF3ECFF),
                child: Image.network(
                  fullImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (showHeart)
              ScaleTransition(
                scale: _heartScale,
                child: const Icon(
                  Icons.favorite,
                  size: 88,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCard(String audioPath) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF7FF),
            Color(0xFFF5E8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE4C8FF),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isAudioLoading
                ? null
                : () => _toggleAudio(audioPath),
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD86BFF),
                    Color(0xFF8E45FF),
                  ],
                ),
              ),
              child: isAudioLoading
                  ? const Padding(
                      padding: EdgeInsets.all(17),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice message',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: Row(
                    children: List.generate(
                      bars.length,
                      (index) {
                        final height = bars[index];

                        final currentProgress =
                            (index + 1) / bars.length;

                        final isActive =
                            currentProgress <= _audioProgress;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 1,
                          ),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 140),
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isActive
                                    ? const [
                                        Color(0xFF8E45FF),
                                        Color(0xFFFF67D8),
                                      ]
                                    : const [
                                        Color(0xFFD8B8FF),
                                        Color(0xFFEEDBFF),
                                      ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(999),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_formatDuration(_audioPosition)} / ${_formatDuration(_audioDuration)}',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleLike,
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '$likesCount',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _openPostDetails,
          child: Row(
            children: [
              const Icon(
                Icons.mode_comment_outlined,
                color: AppColors.primary,
                size: 27,
              ),
              const SizedBox(width: 7),
              Text(
                '$commentsCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () async {
            await _sharePost();
          },
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.ios_share_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}