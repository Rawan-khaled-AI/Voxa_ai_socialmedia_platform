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
          (post) => PostModel.fromJson(
            post,
          ),
        )
        .toList();
  }

  Future<List<PostModel>> getUserPosts(
    int userId,
  ) async {
    final token =
        await _authService.getToken();

    final data = await ApiService.getList(
      '/posts/user/$userId',
      token: token,
    );

    return data
        .map(
          (post) => PostModel.fromJson(
            post,
          ),
        )
        .toList();
  }

  Future<PostModel> getPostById(
    int postId,
  ) async {
    final token =
        await _authService.getToken();

    final data = await ApiService.get(
      '/posts/$postId',
      token: token,
    );

    return PostModel.fromJson(data);
  }
}