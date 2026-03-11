import 'package:logbook_app_059/features/logbook/models/user_model.dart';

class LoginController {
  final List<UserModel> _users = [
    UserModel(id: 1, username: "admin", password: "123", role: "project_manager", teamIds: [1,2]),
    UserModel(id: 2, username: "ridho", password: "123", role: "frontend", teamIds: [1]),
  ];

  UserModel? login(String username, String password) {
    try {
      return _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
