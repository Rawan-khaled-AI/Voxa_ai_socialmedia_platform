import 'dart:io';

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
    String text = '',
    File? imageFile,
    File? audioFile,
  }) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    final Map<String, dynamic> fields = {
      'post_id': postId.toString(),
      'text': text,
    };

    final files = <String, File>{};

    if (imageFile != null) {
      files['image'] = imageFile;
    }

    if (audioFile != null) {
      files['audio'] = audioFile;
    }

    final data =
        await ApiService.multipartRequest(
      endpoint: '/comments/',
      method: 'POST',
      fields: fields,
      files: files,
      token: token,
    );

    return CommentModel.fromJson(
      data['comment'],
    );
  }

  Future<void> deleteComment(
    int commentId,
  ) async {
    final token =
        await _authService.getToken();

    if (token == null) {
      throw Exception(
        'User not authenticated',
      );
    }

    await ApiService.delete(
      '/comments/$commentId',
      token: token,
    );
  }
}