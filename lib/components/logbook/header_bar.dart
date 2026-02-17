import 'package:flutter/material.dart';
import 'package:logbook_app_059/features/onboarding/onboarding_view.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final dynamic controller;
  const HeaderBar({
    super.key,
    required this.username,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("LogBook: $username"),
      backgroundColor: Colors.yellow,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return ListView.builder(
                  itemCount: controller.history.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(controller.history[index]));
                  },
                );
              },
            );
          },
        ),
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
