import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../feed/models/post_model.dart';
import '../../profile/models/user_profile_model.dart';

class SearchService {
  final AuthService _authService =
      AuthService();

  Future<List<UserProfileModel>> searchUsers(
    String query,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    final data = await ApiService.getList(
      '/users/search/?q=$query',
      token: token,
    );

    return data
        .map(
          (item) =>
              UserProfileModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PostModel>> searchPosts(
    String query,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    final data = await ApiService.getList(
      '/posts/search/?q=$query',
      token: token,
    );

    return data
        .map(
          (item) =>
              PostModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}