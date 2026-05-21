class UserProfileModel {
  final int id;
  final String name;
  final String? email;
  final String? bio;
  final String? profileImageUrl;

  const UserProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.bio,
    this.profileImageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['username'] ?? 'User',
      email: json['email'],
      bio: json['bio'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'profile_image_url': profileImageUrl,
    };
  }
}