import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/post_model.dart';
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final ValueChanged<PostModel>? onPostUpdated;
  final bool allowOpenProfile;

  const PostCard({
    super.key,
    required this.post,
    this.onPostUpdated,
    this.allowOpenProfile = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  final LikeService _likeService = LikeService();

  late bool isLiked;
  bool showHeart = false;
  bool isPlaying = false;
  bool isTextExpanded = false;
  bool isAudioLoading = false;
  bool isLikeLoading = false;
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
  }

  @override
  void dispose() {
    _player.dispose();
    _heartController.dispose();
    _waveController.dispose();
    super.dispose();
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

    final minutes = duration.inMinutes.toString().padLeft(2, '0');

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

  void _openProfile() {
    if (!widget.allowOpenProfile) return;
    debugPrint('POST USER ID = ${widget.post.user.id}');
    debugPrint('POST USER NAME = ${widget.post.user.name}');
    debugPrint('POST OWNER USER_ID FIELD = ${widget.post.userId}');
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: widget.post.user.id,
    );
  }
  Future<void> _openPostDetails() async {
    final updatedPost =
        await Navigator.pushNamed(
      context,
      AppRoutes.postDetails,
      arguments: _currentPost,
    );

    if (updatedPost is PostModel && mounted) {
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

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.post.imageUrl;

    final fullImageUrl = _validPath(imagePath)
        ? '${ApiService.baseUrl}$imagePath'
        : null;

    final audioPath = widget.post.audioUrl;

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
            if (widget.post.text.trim().isNotEmpty)
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
    final profileImage = widget.post.user.profileImageUrl;

    final hasProfileImage =
        profileImage != null &&
        profileImage.isNotEmpty &&
        profileImage != 'string';

    final imageUrl =
        hasProfileImage ? '${ApiService.baseUrl}$profileImage' : null;

    final initial = widget.post.user.name.isNotEmpty
        ? widget.post.user.name[0].toUpperCase()
        : '?';

    return Row(
      children: [
        GestureDetector(
          onTap: _openProfile,
          child: CircleAvatar(
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
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: _openProfile,
                  child: Text(
                    widget.post.user.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
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
          onPressed: () {},
          icon: const Icon(
            Icons.more_horiz,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildText() {
    final text = widget.post.text.trim();

    final shouldShowReadMore = text.length > 130;

    final arabic = isArabic(text);

    return Directionality(
      textDirection:
          arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: arabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
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
                  arabic
                      ? 'قراءة المزيد'
                      : 'Read more',
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
                            currentProgress <=
                                _audioProgress;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 1,
                          ),
                          child: AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 140,
                            ),
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              gradient:
                                  LinearGradient(
                                begin: Alignment
                                    .bottomCenter,
                                end: Alignment.topCenter,
                                colors: isActive
                                    ? const [
                                        Color(
                                          0xFF8E45FF,
                                        ),
                                        Color(
                                          0xFFFF67D8,
                                        ),
                                      ]
                                    : const [
                                        Color(
                                          0xFFD8B8FF,
                                        ),
                                        Color(
                                          0xFFEEDBFF,
                                        ),
                                      ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                999,
                              ),
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
            isLiked
                ? Icons.favorite
                : Icons.favorite_border,
            color: isLiked
                ? Colors.red
                : AppColors.primary,
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
        const Icon(
          Icons.ios_share_outlined,
          color: AppColors.primary,
          size: 26,
        ),
      ],
    );
    }
}
