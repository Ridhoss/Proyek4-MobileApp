import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget{
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("LogBook: RIDHO S MVC"),
      backgroundColor: Colors.yellow,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
