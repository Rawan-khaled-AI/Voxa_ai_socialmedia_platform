import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';

import '../models/post_model.dart';

class PostService {
  final AuthService _authService =
      AuthService();

  Future<List<PostModel>> getPosts() async {
    final token =
        await _authService.getToken();

    final data = await ApiService.getList(
      '/posts/',
      token: token,
    );

    return data
        .map(
          (post) =>
              PostModel.fromJson(post),
        )
        .toList();
  }

  Future<List<PostModel>> getUserPosts(
    int userId,
  ) async {
    final allPosts =
        await getPosts();

    return allPosts.where((post) {
      return post.user.id == userId ||
          post.userId == userId;
    }).toList();
  }
}