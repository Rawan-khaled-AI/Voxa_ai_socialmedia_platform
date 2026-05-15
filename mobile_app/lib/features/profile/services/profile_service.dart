import '../../../core/services/api_service.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  Future<UserProfileModel> getMyProfile(String token) async {
    final data = await ApiService.get(
      '/users/me',
      token: token,
    );

    return UserProfileModel.fromJson(data);
  }
}