import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotif = ValueNotifier([]);
  static const String _key = 'user_logs_data';

  LogController() {
    loadFromDisk();
  }

  void addLog(String title, String desc) {
    final newLog = LogModel(title: title, date: DateTime.now().toString(), description: desc);
    logsNotif.value = [...logsNotif.value, newLog];
    saveToDisk();
  }

  void updateLog(int index, String title, String desc) {
    final thisLogs = List<LogModel>.from(logsNotif.value);
    thisLogs[index] = LogModel(title: title, date: DateTime.now().toString(), description: desc);
    logsNotif.value = thisLogs;
    saveToDisk();
  }

  void removeLog(int index) {
    final thisLogs = List<LogModel>.from(logsNotif.value);
    thisLogs.removeAt(index);
    logsNotif.value = thisLogs;
    saveToDisk();
  }

  Future<void> saveToDisk() async {
    final sp = await SharedPreferences.getInstance();
    final String encodeData = jsonEncode(logsNotif.value.map((e) => e.toMap()).toList());

    await sp.setString(_key, encodeData);
  }

  Future<void> loadFromDisk() async {
    final sp = await SharedPreferences.getInstance();
    final String? data = sp.getString(_key);
    if (data != null) {
      final List hasilData = jsonDecode(data);
      logsNotif.value = hasilData.map((e) => LogModel.fromMap(e)).toList();
    }
  }

}
