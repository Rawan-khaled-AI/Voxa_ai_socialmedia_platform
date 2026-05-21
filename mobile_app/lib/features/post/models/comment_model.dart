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
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class CommentModel {
  final int id;
  final String text;
  final int userId;
  final int postId;
  final String createdAt;
  final CommentUser user;

  const CommentModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      text: json['text'] ?? '',
      userId: json['user_id'],
      postId: json['post_id'],
      createdAt: json['created_at'] ?? '',
      user: CommentUser.fromJson(json['user']),
    );
  }
}