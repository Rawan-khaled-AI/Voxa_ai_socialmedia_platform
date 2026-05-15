class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'],
      coverImageUrl: json['cover_image_url'],
    );
  }
}