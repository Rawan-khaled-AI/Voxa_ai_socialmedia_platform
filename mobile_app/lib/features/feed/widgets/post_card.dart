import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool showTopDivider;

  const PostCard({
    super.key,
    required this.post,
    this.showTopDivider = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool showHeart = false;
  bool isPlaying = false;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() => isPlaying = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDoubleTap() async {
    setState(() {
      isLiked = true;
      showHeart = true;
    });

    await _controller.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => showHeart = false);
    _controller.reset();
  }

  Future<void> _toggleAudio(String audioUrl) async {
    try {
      final fullAudioUrl = '${ApiService.baseUrl}$audioUrl';

      if (isPlaying) {
        await _player.pause();
        if (mounted) setState(() => isPlaying = false);
        return;
      }

      await _player.setUrl(fullAudioUrl);
      await _player.play();

      if (mounted) setState(() => isPlaying = true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _openImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? fullImageUrl = widget.post.imageUrl == null
        ? null
        : '${ApiService.baseUrl}${widget.post.imageUrl}';

    return Column(
      children: [
        if (widget.showTopDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.border),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(widget.post.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Text
              if (widget.post.text.trim().isNotEmpty)
                Text(
                  widget.post.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textDark,
                  ),
                ),

              if (widget.post.text.trim().isNotEmpty)
                const SizedBox(height: 10),

              // Image
              if (fullImageUrl != null)
                GestureDetector(
                  onDoubleTap: _onDoubleTap,
                  onTap: () => _openImage(fullImageUrl),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 520,
                          ),
                          color: const Color(0xFFF3ECFF),
                          child: Image.network(
                            fullImageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;

                              return const SizedBox(
                                height: 260,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 220,
                                width: double.infinity,
                                alignment: Alignment.center,
                                color: const Color(0xFFF3ECFF),
                                child: const Text(
                                  'Image failed to load',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      if (showHeart)
                        ScaleTransition(
                          scale: _scale,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 100,
                          ),
                        ),
                    ],
                  ),
                ),

              if (fullImageUrl != null) const SizedBox(height: 10),

              // Audio player
              if (widget.post.audioUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE0D0FF),
                      ),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _toggleAudio(widget.post.audioUrl!),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.graphic_eq,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 2),

              // Actions
              Row(
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isLiked ? Colors.red : AppColors.textDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.post.likes}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.mode_comment_outlined,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.post.comments}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    widget.post.audioUrl != null
                        ? Icons.mic
                        : Icons.mic_none,
                    size: 22,
                    color: widget.post.audioUrl != null
                        ? AppColors.primary
                        : AppColors.textDark,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.send_outlined,
                    size: 22,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}