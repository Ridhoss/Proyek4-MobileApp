import 'package:logbook_app_059/features/logbook/models/user_model.dart';

class LoginController {
  final List<UserModel> _users = [
    UserModel(id: 1, username: "admin", password: "123"),
    UserModel(id: 2, username: "ridho", password: "123"),
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
