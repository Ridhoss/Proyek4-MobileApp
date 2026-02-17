import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int step = 1;
  String username;

  CounterController(this.username);

  int get value => _counter;

  List<String> history = [];

  String get _counterKey => 'counter_$username';
  String get _historyKey => 'history_$username';

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt(_counterKey) ?? 0;

    final historyString = prefs.getString(_historyKey);
    if (historyString != null) {
      history = List<String>.from(jsonDecode(historyString));
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_counterKey, _counter);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  void _addHistory(String message) {
    final now = DateTime.now();
    String time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    history.insert(0, "User $username $message jam $time");

    if (history.length > 10) {
      history.removeLast();
    }

    _saveData();
  }

  void incStep() => step++;
  void decStep() {
    if (step > 1) step--;
  }

  void increment() {
    _counter += step;
    _addHistory("menambah +$step");
    _saveData();
  }

  void decrement() {
    if (_counter > 0) {
      _counter -= step;
      _addHistory("mengurangi -$step");
      _saveData();
    }
  }

  void reset() {
    _counter = 0;
    step = 1;
    _addHistory("melakukan RESET");
    _saveData();
  }
}
