class LoginController {
  final Map<String, String> _users = {"admin": "123", "ridho": "password"};

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        password == _users[username]) {
      return true;
    }
    return false;
  }
}
