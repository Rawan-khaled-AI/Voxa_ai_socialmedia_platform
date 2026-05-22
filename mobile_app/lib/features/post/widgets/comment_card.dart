import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/comment_model.dart';

class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final int? currentUserId;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.currentUserId,
    this.onDelete,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late final AudioPlayer _player;

  bool isPlaying = false;
  bool isLoadingAudio = false;

  Duration? audioDuration;
  Duration audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _player.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        audioDuration = duration;
      });
    });

    _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() {
        audioPosition = position;
      });
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!mounted) return;

        setState(() {
          isPlaying = false;
          audioPosition = Duration.zero;
        });

        _player.seek(Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _openProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: widget.comment.user.id,
    );
  }

  String _fullUrl(String path) {
    return '${ApiService.baseUrl}$path';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';

    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  Future<void> _toggleAudio() async {
    final audioUrl = widget.comment.audioUrl;

    if (audioUrl == null || audioUrl.isEmpty || audioUrl == 'string') {
      return;
    }

    try {
      if (isPlaying) {
        await _player.pause();

        if (!mounted) return;

        setState(() {
          isPlaying = false;
        });

        return;
      }

      setState(() {
        isLoadingAudio = true;
      });

      if (_player.audioSource == null) {
        await _player.setUrl(_fullUrl(audioUrl));
      }

      await _player.play();

      if (!mounted) return;

      setState(() {
        isPlaying = true;
        isLoadingAudio = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingAudio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    final hasProfileImage =
        comment.user.profileImageUrl != null &&
            comment.user.profileImageUrl!.isNotEmpty &&
            comment.user.profileImageUrl != 'string';

    final imageUrl = hasProfileImage
        ? _fullUrl(comment.user.profileImageUrl!)
        : null;

    final initial =
        comment.user.name.isNotEmpty
            ? comment.user.name[0].toUpperCase()
            : '?';

    final canDelete =
        widget.currentUserId != null &&
            widget.currentUserId == comment.userId &&
            widget.onDelete != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _openProfile(context),
                        child: Text(
                          comment.user.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 21,
                        ),
                      ),
                  ],
                ),

                if (comment.hasText) ...[
                  const SizedBox(height: 6),
                  Text(
                    comment.text,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],

                if (comment.hasImage) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(18),
                    child: Image.network(
                      _fullUrl(comment.imageUrl!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                if (comment.hasAudio) ...[
                  const SizedBox(height: 10),
                  _buildAudioComment(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioComment() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4C8FF),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isLoadingAudio ? null : _toggleAudio,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: isLoadingAudio
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_formatDuration(audioPosition)} / ${_formatDuration(audioDuration)}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}