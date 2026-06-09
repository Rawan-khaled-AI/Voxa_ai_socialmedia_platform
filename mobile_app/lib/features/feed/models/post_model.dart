class PostUser {
  final int id;
  final String name;
  final String? profileImageUrl;

  const PostUser({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'User',
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class OriginalPostModel {
  final int id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final int userId;
  final PostUser user;

  const OriginalPostModel({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.userId,
    required this.user,
  });

  factory OriginalPostModel.fromJson(Map<String, dynamic> json) {
    return OriginalPostModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      userId: json['user_id'] ?? 0,
      user: PostUser.fromJson(json['user']),
    );
  }
}

class PostModel {
  final int id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final int userId;
  final PostUser user;

  final int? repostOfPostId;
  final OriginalPostModel? originalPost;

  final int likes;
  final int comments;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.userId,
    required this.user,
    this.repostOfPostId,
    this.originalPost,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  bool get isRepost {
    return repostOfPostId != null && originalPost != null;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      userId: json['user_id'] ?? 0,
      user: PostUser.fromJson(json['user']),
      repostOfPostId: json['repost_of_post_id'],
      originalPost: json['original_post'] != null
          ? OriginalPostModel.fromJson(
              json['original_post'],
            )
          : null,
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  PostModel copyWith({
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      userId: userId,
      user: user,
      repostOfPostId: repostOfPostId,
      originalPost: originalPost,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}