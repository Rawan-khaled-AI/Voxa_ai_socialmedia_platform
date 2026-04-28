import 'package:flutter/material.dart';

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

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void onDoubleTap() async {
    setState(() {
      isLiked = true;
      showHeart = true;
    });

    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      showHeart = false;
    });

    _controller.reset();
  }

  void openImage(String url) {
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
              /// 🔥 HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        AssetImage(widget.post.avatarUrl),
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
                  const Icon(Icons.more_horiz,
                      size: 20, color: AppColors.textDark),
                ],
              ),

              const SizedBox(height: 8),

              /// 🔥 TEXT
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

              /// 🔥 IMAGE + INTERACTIONS
              if (fullImageUrl != null)
                GestureDetector(
                  onDoubleTap: onDoubleTap,
                  onTap: () => openImage(fullImageUrl),
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
                          ),
                        ),
                      ),

                      /// ❤️ HEART ANIMATION
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

              const SizedBox(height: 10),

              /// 🔥 ACTIONS
              Row(
                children: [
                  Icon(
                    isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color:
                        isLiked ? Colors.red : AppColors.textDark,
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
                  const Icon(Icons.mode_comment_outlined,
                      size: 20, color: AppColors.textDark),
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
                  const Icon(Icons.mic_none,
                      size: 22, color: AppColors.textDark),
                  const Spacer(),
                  const Icon(Icons.send_outlined,
                      size: 22, color: AppColors.textDark),
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


/// 🔥 FULL SCREEN IMAGE
class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}