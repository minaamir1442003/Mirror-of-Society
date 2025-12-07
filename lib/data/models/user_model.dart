class UserModel {
  final String id;
  final String name;
  final String username;
  final String? bio;
  final String? imageUrl;
  final int boltCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.bio,
    this.imageUrl,
    required this.boltCount,
    required this.followersCount,
    required this.followingCount,
    this.isFollowing = false,
  });
}