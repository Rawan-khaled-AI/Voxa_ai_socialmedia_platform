import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../feed/models/post_model.dart';
import '../feed/widgets/post_card.dart';
import 'models/comment_model.dart';
import 'services/comment_service.dart';
import 'widgets/comment_card.dart';
import 'widgets/voice_record_card.dart';

class PostDetailsScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailsScreen> createState() =>
      _PostDetailsScreenState();
}

class _PostDetailsScreenState
    extends State<PostDetailsScreen> {
  final CommentService _commentService =
      CommentService();

  final AuthService _authService =
      AuthService();

  final TextEditingController
      _commentController =
      TextEditingController();

  final AudioRecorder _audioRecorder =
      AudioRecorder();

  final AudioPlayer _audioPlayer =
      AudioPlayer();

  late PostModel currentPost;

  List<CommentModel> comments = [];

  bool isLoading = true;
  bool isSending = false;

  int? currentUserId;

  File? selectedImage;
  File? selectedAudio;

  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;

  bool isRecording = false;
  bool isPlaying = false;

  String? audioPath;

  String get durationText {
    final minutes =
        _recordDuration.inMinutes.toString().padLeft(2, '0');

    final seconds =
        (_recordDuration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    currentPost = widget.post;

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        isPlaying = false;
      });
    });

    _loadComments();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user =
          await _authService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        currentUserId = user['id'];
      });
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    try {
      final data =
          await _commentService.getComments(
        currentPost.id,
      );

      if (!mounted) return;

      setState(() {
        comments = data;

        currentPost = currentPost.copyWith(
          comments: data.length,
        );

        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null ||
        result.files.single.path == null) {
      return;
    }

    setState(() {
      selectedImage = File(
        result.files.single.path!,
      );
    });
  }

  Future<void> _startRecording() async {
    final allowed =
        await _audioRecorder.hasPermission();

    if (!allowed) return;

    await _audioPlayer.stop();

    final dir =
        await getTemporaryDirectory();

    final path =
        '${dir.path}/comment_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
      ),
      path: path,
    );

    _recordTimer?.cancel();
    _recordDuration = Duration.zero;

    _recordTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _recordDuration = Duration(
            seconds:
                _recordDuration.inSeconds + 1,
          );
        });
      },
    );

    setState(() {
      isRecording = true;
      isPlaying = false;
      audioPath = null;
      selectedAudio = null;
    });
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    final path =
        await _audioRecorder.stop();

    _recordTimer?.cancel();

    if (path == null) {
      setState(() {
        isRecording = false;
      });

      return;
    }

    setState(() {
      isRecording = false;
      audioPath = path;
      selectedAudio = File(path);
    });
  }

  Future<void> _togglePlayback() async {
    if (audioPath == null ||
        isRecording) {
      return;
    }

    if (isPlaying) {
      await _audioPlayer.pause();

      setState(() {
        isPlaying = false;
      });

      return;
    }

    await _audioPlayer.play(
      DeviceFileSource(audioPath!),
    );

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _handleVoicePrimary() async {
    if (isRecording) {
      await _stopRecording();
      return;
    }

    await _togglePlayback();
  }

  Future<void> _deleteVoice() async {
    _recordTimer?.cancel();

    try {
      if (isRecording) {
        await _audioRecorder.stop();
      }
    } catch (_) {}

    await _audioPlayer.stop();

    setState(() {
      isRecording = false;
      isPlaying = false;
      audioPath = null;
      selectedAudio = null;
      _recordDuration = Duration.zero;
    });
  }

  Future<void> _deleteComment(
    CommentModel comment,
  ) async {
    try {
      await _commentService.deleteComment(
        comment.id,
      );

      if (!mounted) return;

      setState(() {
        comments.removeWhere(
          (item) => item.id == comment.id,
        );

        currentPost = currentPost.copyWith(
          comments: comments.length,
        );
      });
    } catch (_) {}
  }

  Future<void> _sendComment() async {
    final text =
        _commentController.text.trim();

    if (text.isEmpty &&
        selectedImage == null &&
        selectedAudio == null) {
      return;
    }

    if (isRecording) {
      await _stopRecording();
    }

    try {
      setState(() {
        isSending = true;
      });

      final comment =
          await _commentService.addComment(
        postId: currentPost.id,
        text: text,
        imageFile: selectedImage,
        audioFile: selectedAudio,
      );

      if (!mounted) return;

      _commentController.clear();
      await _audioPlayer.stop();

      setState(() {
        comments.insert(0, comment);

        currentPost = currentPost.copyWith(
          comments: comments.length,
        );

        selectedImage = null;
        selectedAudio = null;
        audioPath = null;
        isPlaying = false;
        isRecording = false;
        _recordDuration = Duration.zero;

        isSending = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });
    }
  }

  void _updatePost(PostModel updatedPost) {
    setState(() {
      currentPost = updatedPost;
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _commentController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          currentPost,
        );

        return false;
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFFFFFAFD),

        appBar: AppBar(
          backgroundColor:
              Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Post',
            style: TextStyle(
              color:
                  AppColors.textDark,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                currentPost,
              );
            },
            icon: const Icon(
              Icons
                  .arrow_back_ios_new_rounded,
              color:
                  AppColors.primary,
            ),
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            AppColors.primary,
                      ),
                    )
                  : ListView(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        16,
                        10,
                        16,
                        120,
                      ),
                      children: [
                        PostCard(
                          post:
                              currentPost,
                          onPostUpdated:
                              _updatePost,
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        Row(
                          children: [
                            const Text(
                              'Comments',
                              style:
                                  TextStyle(
                                color:
                                    AppColors
                                        .textDark,
                                fontSize:
                                    22,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    10,
                                vertical:
                                    4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFEEDBFF,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  999,
                                ),
                              ),
                              child: Text(
                                currentPost
                                    .comments
                                    .toString(),
                                style:
                                    const TextStyle(
                                  color:
                                      AppColors.primary,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        if (comments.isEmpty)
                          Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              24,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                26,
                              ),
                            ),
                            child:
                                const Center(
                              child: Text(
                                'No comments yet 💬',
                                style:
                                    TextStyle(
                                  color:
                                      AppColors.textDark,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          ...comments.map(
                            (comment) {
                              return CommentCard(
                                comment:
                                    comment,
                                currentUserId:
                                    currentUserId,
                                onDelete: () =>
                                    _deleteComment(
                                  comment,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  16,
                  12,
                  16,
                  14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        .04,
                      ),
                      blurRadius: 20,
                      offset:
                          const Offset(
                        0,
                        -4,
                      ),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    if (selectedImage != null)
                      Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF6EDFF,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.image,
                              color:
                                  AppColors.primary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Expanded(
                              child: Text(
                                'Image ready',
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedImage =
                                      null;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (audioPath != null ||
                        isRecording)
                      VoiceRecordCard(
                        isRecording:
                            isRecording,
                        isPlaying:
                            isPlaying,
                        duration:
                            durationText,
                        onDelete:
                            _deleteVoice,
                        onPrimary:
                            _handleVoicePrimary,
                        onDone: () {},
                      ),

                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              _pickImage,
                          icon: const Icon(
                            Icons.image_outlined,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        IconButton(
                          onPressed: isRecording
                              ? _stopRecording
                              : _startRecording,
                          icon: Icon(
                            isRecording
                                ? Icons.stop
                                : Icons.mic_none_rounded,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        Expanded(
                          child: Container(
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFF7F1FF,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                            child: TextField(
                              controller:
                                  _commentController,
                              minLines: 1,
                              maxLines: 4,
                              decoration:
                                  const InputDecoration(
                                hintText:
                                    'Write a comment...',
                                border:
                                    InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  horizontal:
                                      16,
                                  vertical:
                                      14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        GestureDetector(
                          onTap: isSending
                              ? null
                              : _sendComment,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration:
                                const BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              gradient:
                                  LinearGradient(
                                colors: [
                                  Color(
                                    0xFFD86BFF,
                                  ),
                                  Color(
                                    0xFF8E45FF,
                                  ),
                                ],
                              ),
                            ),
                            child: isSending
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(
                                      16,
                                    ),
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.4,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .send_rounded,
                                    color:
                                        Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}