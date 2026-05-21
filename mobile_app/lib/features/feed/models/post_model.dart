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
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
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
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      userId: json['user_id'],
      user: PostUser.fromJson(json['user']),
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
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}