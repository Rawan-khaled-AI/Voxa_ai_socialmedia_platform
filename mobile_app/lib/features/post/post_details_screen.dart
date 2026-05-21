import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../feed/models/post_model.dart';
import '../feed/widgets/post_card.dart';
import 'models/comment_model.dart';
import 'services/comment_service.dart';
import 'widgets/comment_card.dart';

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

  final TextEditingController
      _commentController =
      TextEditingController();

  late PostModel currentPost;

  List<CommentModel> comments = [];

  bool isLoading = true;

  bool isSending = false;

  @override
  void initState() {
    super.initState();

    currentPost = widget.post;

    _loadComments();
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

  Future<void> _sendComment() async {
    final text =
        _commentController.text.trim();

    if (text.isEmpty) return;

    try {
      setState(() {
        isSending = true;
      });

      final comment =
          await _commentService.addComment(
        postId: currentPost.id,
        text: text,
      );

      if (!mounted) return;

      _commentController.clear();

      setState(() {
        comments.insert(0, comment);

        currentPost = currentPost.copyWith(
          comments: comments.length,
        );

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
    _commentController.dispose();

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

              child: Row(
                children: [
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
                              Icons.send_rounded,

                              color:
                                  Colors.white,
                            ),
                    ),
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
