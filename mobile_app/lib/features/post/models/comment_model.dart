class CommentUser {
  final int id;
  final String name;
  final String? profileImageUrl;

  const CommentUser({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['username'] ?? 'User',
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class CommentModel {
  final int id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final int userId;
  final int postId;
  final String createdAt;
  final CommentUser user;

  const CommentModel({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      userId: json['user_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      user: CommentUser.fromJson(
        json['user'] ?? {},
      ),
    );
  }

  bool get hasText => text.trim().isNotEmpty;

  bool get hasImage =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      imageUrl != 'string';

  bool get hasAudio =>
      audioUrl != null &&
      audioUrl!.isNotEmpty &&
      audioUrl != 'string';
}