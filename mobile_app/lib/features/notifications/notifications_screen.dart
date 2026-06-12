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
  final NotificationService _service = NotificationService();
  final PostService _postService = PostService();

  List<NotificationModel> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _service.getNotifications();

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
        await _service.markAsRead(notification.id);
      } catch (_) {}
    }

    if (!mounted) return;

    if (notification.postId != null) {
      try {
        final PostModel post =
            await _postService.getPostById(notification.postId!);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailsScreen(
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
    final name = item.actor?.name ?? 'Someone';

    switch (item.type) {
      case 'like':
        return '$name liked your post';
      case 'comment':
        return '$name commented on your post';
      case 'follow':
        return '$name started following you';
      case 'password_changed':
        return 'Your password was changed successfully';
      case 'password_reset':
        return 'Your password was reset successfully';
      default:
        return '$name interacted with you';
    }
  }

  String _subtitle(NotificationModel item) {
    if (item.type == 'like' || item.type == 'comment') {
      if (item.post?.text.isNotEmpty == true) {
        return '— Tap to view the full content';
      }

      return '— Tap to view the post';
    }

    if (item.type == 'follow') {
      return 'Check their profile and respond';
    }

    if (item.type == 'password_changed') {
      return 'Your account password has been updated';
    }

    if (item.type == 'password_reset') {
      return 'A new password has been created';
    }

    return 'Tap to view';
  }

  IconData _icon(NotificationModel item) {
    switch (item.type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.mode_comment_rounded;
      case 'follow':
        return Icons.person_add_alt_1;
      case 'password_changed':
        return Icons.lock_reset;
      case 'password_reset':
        return Icons.verified_user;
      default:
        return Icons.notifications;
    }
  }

  Color _iconColor(NotificationModel item) {
    if (item.type == 'like') {
      return Colors.redAccent;
    }

    if (item.type == 'password_changed' ||
        item.type == 'password_reset') {
      return Colors.green;
    }

    return AppColors.primary;
  }

  DateTime? _dateOf(NotificationModel item) {
    try {
      return DateTime.parse(item.createdAt).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isToday(NotificationModel item) {
    final date = _dateOf(item);
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isNew(NotificationModel item) {
    return !item.isRead;
  }

  List<NotificationModel> get _newNotifications {
    return notifications.where(_isNew).toList();
  }

  List<NotificationModel> get _todayNotifications {
    return notifications
        .where((item) => !_isNew(item) && _isToday(item))
        .toList();
  }

  List<NotificationModel> get _earlierNotifications {
    return notifications
        .where((item) => !_isNew(item) && !_isToday(item))
        .toList();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: 14,
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _sectionList(
    String title,
    List<NotificationModel> items,
  ) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        ...items.map(
          (item) {
            return _NotificationTile(
              notification: item,
              message: _message(item),
              subtitle: _subtitle(item),
              icon: _icon(item),
              iconColor: _iconColor(item),
              onTap: () => _openNotification(item),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFD),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/voxa_logo_clean.png',
                    width: 74,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFAFD),
                      Color(0xFFF6EDFF),
                    ],
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadNotifications,
                        child: notifications.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 220),
                                  Center(
                                    child: Text(
                                      'No notifications yet 🔔',
                                      style: TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  4,
                                  14,
                                  28,
                                ),
                                children: [
                                  _sectionList(
                                    'New',
                                    _newNotifications,
                                  ),
                                  _sectionList(
                                    'Today',
                                    _todayNotifications,
                                  ),
                                  _sectionList(
                                    'Earlier',
                                    _earlierNotifications,
                                  ),
                                ],
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String message;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.message,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actorImage = notification.actor?.profileImageUrl;

    final hasImage = actorImage != null &&
        actorImage.isNotEmpty &&
        actorImage != 'string';

    final imageUrl =
        hasImage ? '${ApiService.baseUrl}$actorImage' : null;

    final initial =
        notification.actor?.name.isNotEmpty == true
            ? notification.actor!.name[0].toUpperCase()
            : 'V';

    final isPasswordNotification =
        notification.type == 'password_changed' ||
            notification.type == 'password_reset';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white.withOpacity(0.84)
              : const Color(0xFFF3E5FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFEEDBFF),
                  backgroundImage: imageUrl != null && !isPasswordNotification
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null || isPasswordNotification
                      ? Text(
                          isPasswordNotification ? 'V' : initial,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white,
                  child: Icon(
                    icon,
                    size: 13,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
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