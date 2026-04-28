import '../../../core/services/api_service.dart';
import '../../auth/services/auth_service.dart';

class PostService {
  Future<List<dynamic>> getPosts() async {
    final token = await AuthService().getToken();

    return await ApiService.getList(
      '/posts/',
      token: token,
    );
  }
}