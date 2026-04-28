class PostModel {
  final String username;
  final String avatarUrl;
  final String text;
  final String? imageUrl;
  final int likes;
  final int comments;

  const PostModel({
    required this.username,
    required this.avatarUrl,
    required this.text,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
  });
}