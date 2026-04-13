import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool showTopDivider;

  const PostCard({
    super.key,
    required this.post,
    this.showTopDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTopDivider)
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
                    backgroundImage: AssetImage(post.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      post.username,
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

              // Text
              if (post.text.trim().isNotEmpty)
                Text(
                  post.text,
                  style: const TextStyle(
                    fontSize: 12.8,
                    height: 1.35,
                    color: AppColors.textDark,
                  ),
                ),

              if (post.text.trim().isNotEmpty) const SizedBox(height: 10),

              // Image (full width)
              if (post.imageAsset != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4), // شبه التصميم
                  child: Image.asset(
                    post.imageAsset!,
                    width: double.infinity,
                    height: 220, // أقرب للصورة عندك
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 10),

              // Actions row
              Row(
                children: [
                  const Icon(Icons.favorite_border,
                      size: 20, color: AppColors.textDark),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes}',
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
                    '${post.comments}',
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
