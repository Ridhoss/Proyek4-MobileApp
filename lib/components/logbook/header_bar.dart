import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/auth/login_view.dart';
import 'package:logbook_app_059/features/onboarding/onboarding_view.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  const HeaderBar({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("LogBook: $username"),
      backgroundColor: Colors.yellow,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text("Apakah Anda yakin ingin logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Ya, Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
