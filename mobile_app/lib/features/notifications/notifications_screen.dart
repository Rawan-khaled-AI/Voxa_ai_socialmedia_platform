import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../feed/models/post_model.dart';
import '../feed/services/post_service.dart';
import '../post/post_details_screen.dart';
import 'models/notification_model.dart';
import 'services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationService _service =
      NotificationService();

  final PostService _postService =
      PostService();

  List<NotificationModel> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data =
          await _service.getNotifications();

      if (!mounted) return;

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openNotification(
    NotificationModel notification,
  ) async {
    if (!notification.isRead) {
      try {
        await _service.markAsRead(
          notification.id,
        );
      } catch (_) {}
    }

    if (!mounted) return;

    if (notification.postId != null) {
      try {
        final PostModel post =
            await _postService.getPostById(
          notification.postId!,
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PostDetailsScreen(
              post: post,
            ),
          ),
        );

        await _loadNotifications();
        return;
      } catch (_) {}
    }

    if (notification.actorId != null) {
      await Navigator.pushNamed(
        context,
        AppRoutes.profile,
        arguments: notification.actorId,
      );

      if (!mounted) return;
      await _loadNotifications();
    }
  }

  String _message(NotificationModel item) {
    final name =
        item.actor?.name ?? 'Someone';

    if (item.type == 'like') {
      return '$name liked your post';
    }

    if (item.type == 'comment') {
      return '$name commented on your post';
    }

    if (item.type == 'follow') {
      return '$name started following you';
    }

    return '$name interacted with you';
  }

  IconData _icon(NotificationModel item) {
    if (item.type == 'like') {
      return Icons.favorite;
    }

    if (item.type == 'comment') {
      return Icons.mode_comment_rounded;
    }

    if (item.type == 'follow') {
      return Icons.person_add_alt_1;
    }

    return Icons.notifications;
  }

  Color _iconColor(NotificationModel item) {
    if (item.type == 'like') {
      return Colors.redAccent;
    }

    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAFD),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFAFD),
              Color(0xFFF6EDFF),
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh:
                    _loadNotifications,
                child: notifications.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 220),
                          Center(
                            child: Text(
                              'No notifications yet 🔔',
                              style: TextStyle(
                                color:
                                    AppColors.textDark,
                                fontWeight:
                                    FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          28,
                        ),
                        itemCount:
                            notifications.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 12,
                        ),
                        itemBuilder:
                            (_, index) {
                          final item =
                              notifications[index];

                          return _NotificationTile(
                            notification:
                                item,
                            message:
                                _message(item),
                            icon:
                                _icon(item),
                            iconColor:
                                _iconColor(item),
                            onTap: () =>
                                _openNotification(
                              item,
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actorImage =
        notification.actor?.profileImageUrl;

    final hasImage =
        actorImage != null &&
            actorImage.isNotEmpty &&
            actorImage != 'string';

    final imageUrl = hasImage
        ? '${ApiService.baseUrl}$actorImage'
        : null;

    final initial =
        notification.actor?.name.isNotEmpty == true
            ? notification.actor!.name[0]
                .toUpperCase()
            : '?';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(24),
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white.withOpacity(.86)
              : const Color(0xFFFFF7FF),
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : const Color(0xFFE4C8FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple
                  .withOpacity(.05),
              blurRadius: 18,
              offset:
                  const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment:
                  Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      const Color(0xFFEEDBFF),
                  backgroundImage:
                      imageUrl != null
                          ? NetworkImage(
                              imageUrl,
                            )
                          : null,
                  child: imageUrl == null
                      ? Text(
                          initial,
                          style:
                              const TextStyle(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      Colors.white,
                  child: Icon(
                    icon,
                    size: 15,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color:
                          AppColors.textDark,
                      fontSize: 15.5,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.post?.text
                                .isNotEmpty ==
                            true
                        ? notification.post!.text
                        : 'Tap to view',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          Color(0xFF8F889A),
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}