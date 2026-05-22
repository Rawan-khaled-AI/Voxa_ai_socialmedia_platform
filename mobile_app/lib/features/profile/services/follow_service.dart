import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';

class FollowService {
  final AuthService _authService =
      AuthService();

  Future<Map<String, dynamic>> toggleFollow(
    int userId,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    return await ApiService.post(
      '/follows/user/$userId',
      {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> getFollowStatus(
    int userId,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    return await ApiService.get(
      '/follows/status/$userId',
      token: token,
    );
  }
}