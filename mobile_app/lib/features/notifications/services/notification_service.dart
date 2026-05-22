import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final AuthService _authService =
      AuthService();

  Future<List<NotificationModel>> getNotifications() async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final data = await ApiService.getList(
      '/notifications/',
      token: token,
    );

    return data
        .map(
          (item) => NotificationModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<NotificationModel> markAsRead(
    int notificationId,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final data = await ApiService.patch(
      '/notifications/$notificationId/read',
      {},
      token: token,
    );

    return NotificationModel.fromJson(data);
  }
}