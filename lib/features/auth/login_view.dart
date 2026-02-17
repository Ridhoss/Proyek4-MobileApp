import 'package:flutter/material.dart';
import 'package:logbook_app_059/controller/login_controller.dart';
import 'package:logbook_app_059/features/onboarding/splashscreen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  int _loginAttempt = 0;
  bool _isSuspended = false;
  bool _obscureText = true;

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    if (_isSuspended) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login disuspend. Tunggu 10 detik."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password wajib diisi!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      _loginAttempt = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashView(username: user)),
      );
    } else {
      _loginAttempt++;

      if (_loginAttempt >= 3) {
        _isSuspended = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Terlalu banyak percobaan! Login disuspend 10 detik.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        Future.delayed(const Duration(seconds: 10), () {
          setState(() {
            _loginAttempt = 0;
            _isSuspended = false;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Gagal!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                /// Username
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Password
                TextField(
                  controller: _passController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSuspended ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Masuk", style: TextStyle(fontSize: 16)),
                  ),
                ),

                if (_isSuspended) ...[
                  const SizedBox(height: 15),
                  const Text(
                    "Akun disuspend sementara...",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
