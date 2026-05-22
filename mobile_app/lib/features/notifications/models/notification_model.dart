class NotificationActor {
  final int id;
  final String name;
  final String? profileImageUrl;

  const NotificationActor({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory NotificationActor.fromJson(Map<String, dynamic> json) {
    return NotificationActor(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['username'] ?? 'User',
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class NotificationPost {
  final int id;
  final String text;

  const NotificationPost({
    required this.id,
    required this.text,
  });

  factory NotificationPost.fromJson(Map<String, dynamic> json) {
    return NotificationPost(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

class NotificationModel {
  final int id;
  final int userId;
  final int? actorId;
  final int? postId;
  final String type;
  final bool isRead;
  final String createdAt;
  final NotificationActor? actor;
  final NotificationPost? post;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.actorId,
    this.postId,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actor,
    this.post,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      actorId: json['actor_id'],
      postId: json['post_id'],
      type: json['type'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      actor: json['actor'] != null
          ? NotificationActor.fromJson(json['actor'])
          : null,
      post: json['post'] != null
          ? NotificationPost.fromJson(json['post'])
          : null,
    );
  }
}