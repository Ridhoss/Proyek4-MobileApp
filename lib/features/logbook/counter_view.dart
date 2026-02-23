import 'package:flutter/material.dart';
import 'package:logbook_app_059/components/logbook/header_bar.dart';
import 'package:logbook_app_059/components/logbook/history_section.dart';
import 'package:logbook_app_059/controller/counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController controller;

  void resetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah Anda yakin ingin mereset counter?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => controller.reset());
                Navigator.pop(context);
              },
              child: const Text("Ya, Reset"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(username: widget.username),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Total Hitungan:"),
                Text(
                  '${controller.value}',
                  style: const TextStyle(fontSize: 60),
                ),
                SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () => setState(() => controller.decStep()),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text: controller.step.toString(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              controller.step = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: () => setState(() => controller.incStep()),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                HistorySection(controller: controller),
                const SizedBox(height: 100), // biar tidak ketutup FAB
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () => setState(() => controller.decrement()),
            tooltip: 'Decrement',
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            onPressed: () => resetDialog(),
            tooltip: 'Reset',
            backgroundColor: Colors.grey,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            onPressed: () => setState(() => controller.increment()),
            tooltip: 'Increment',
            backgroundColor: Colors.greenAccent,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 20)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = CounterController(widget.username);
    controller.loadData().then((_) {
      setState(() {});
    });
  }
}
