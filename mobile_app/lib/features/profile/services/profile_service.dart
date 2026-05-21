import '../../../core/services/api_service.dart';

import '../../auth/services/auth_service.dart';

import '../models/user_profile_model.dart';

class ProfileService {
  final AuthService _authService =
      AuthService();

  Future<UserProfileModel> getMyProfile(
    String token,
  ) async {
    final data = await ApiService.get(
      '/users/me',
      token: token,
    );

    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> getUserProfile(
    int userId,
  ) async {
    final token =
        await _authService.getToken();

    final data = await ApiService.get(
      '/users/$userId',
      token: token,
    );

    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> updateProfile({
    required String token,
    required String name,
    required String bio,
    String? profileImageUrl,
  }) async {
    final data = await ApiService.patch(
      '/users/me',
      {
        'name': name,
        'bio': bio,
        'profile_image_url':
            profileImageUrl,
      },
      token: token,
    );

    return UserProfileModel.fromJson(
      data,
    );
  }
}