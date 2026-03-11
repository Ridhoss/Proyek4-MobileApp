class UserModel {
  final int id;
  final String username;
  final String password;
  final String role;
  final List<int> teamIds;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.teamIds,
  });
}
