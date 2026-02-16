import 'package:flutter/material.dart';
import 'package:logbook_app_059/controller/counter_controller.dart';

class HistorySection extends StatelessWidget {
  final CounterController controller;

  const HistorySection({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 200,
          width: 300,
          child: ListView.builder(
            itemCount: controller.history.length,
            itemBuilder: (context, index) {
              String item = controller.history[index];
              bool isPlus = item.startsWith("+");

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                leading: Icon(
                  isPlus ? Icons.add : Icons.remove,
                  color: isPlus ? Colors.green : Colors.red,
                ),
                title: Text(item),
              );
            },
          ),
        ),
      ],
    );
  }
}