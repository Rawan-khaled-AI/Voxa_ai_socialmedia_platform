import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    final token = response['access_token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    }

    return response;
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return await ApiService.post(
      '/auth/signup',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    return await ApiService.get(
      '/auth/me',
      token: token,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}