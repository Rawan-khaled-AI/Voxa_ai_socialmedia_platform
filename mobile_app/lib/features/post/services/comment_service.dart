import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/comment_model.dart';

class CommentService {
  final AuthService _authService =
      AuthService();

  Future<List<CommentModel>> getComments(
    int postId,
  ) async {
    final data = await ApiService.getList(
      '/comments/post/$postId',
    );

    return data
        .map(
          (item) =>
              CommentModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<CommentModel> addComment({
    required int postId,
    required String text,
  }) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    final data = await ApiService.post(
      '/comments/',
      {
        'post_id': postId,
        'text': text,
      },
      token: token,
    );

    return CommentModel.fromJson(
      data['comment'],
    );
  }
}