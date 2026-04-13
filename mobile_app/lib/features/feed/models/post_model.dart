class PostModel {
  final String username;
  final String avatarUrl;
  final String text;
  final String? imageAsset;
  final int likes;
  final int comments;

  const PostModel({
    required this.username,
    required this.avatarUrl,
    required this.text,
    this.imageAsset,
    this.likes = 0,
    this.comments = 0,
  });
}