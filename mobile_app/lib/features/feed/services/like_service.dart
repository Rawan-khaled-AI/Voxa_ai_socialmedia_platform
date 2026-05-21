import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';

class LikeService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> toggleLike(
    int postId,
  ) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final data = await ApiService.post(
      '/likes/post/$postId',
      {},
      token: token,
    );

    return {
      'liked': data['liked'] ?? false,
      'likes_count': data['likes_count'] ?? 0,
    };
  }
}