import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/comment_model.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  void _openProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: comment.user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        comment.user.profileImageUrl != null &&
            comment.user.profileImageUrl!.isNotEmpty &&
            comment.user.profileImageUrl != 'string';

    final imageUrl = hasImage
        ? '${ApiService.baseUrl}${comment.user.profileImageUrl}'
        : null;

    final initial =
        comment.user.name.isNotEmpty
            ? comment.user.name[0].toUpperCase()
            : '?';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openProfile(context),
            child: CircleAvatar(
              radius: 23,
              backgroundColor:
                  const Color(0xFFEEDBFF),
              backgroundImage:
                  imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
              child: imageUrl == null
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () =>
                      _openProfile(context),
                  child: Text(
                    comment.user.name,
                    style: const TextStyle(
                      color:
                          AppColors.textDark,
                      fontWeight:
                          FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color:
                        AppColors.textDark,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}