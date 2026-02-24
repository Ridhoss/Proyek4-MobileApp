import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/logbook/log_view.dart';
import 'package:logbook_app_059/features/logbook/models/user_model.dart';

class SplashView extends StatefulWidget {
  final UserModel user;
  const SplashView({super.key, required this.user});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 11) {
      return "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LogView(user: widget.user),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.waving_hand,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            Text(
              getGreeting(),
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Selamat datang, ${widget.user.username}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
