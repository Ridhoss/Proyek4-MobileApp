import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotif = ValueNotifier([]);
  static const String _key = 'user_logs_data';
  static const String _counterKey = 'log_id_counter';
  int? _currentUserId;

  final List<LogModel> _allLogs = [];

  Future<void> addLog(
    int iduser,
    String title,
    String desc,
    String category,
  ) async {
    final idbaru = await _getNextId();

    final newLog = LogModel(
      id: idbaru,
      iduser: iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc,
      category: category,
    );

    _allLogs.add(newLog);
    _refreshUserLogs();
    await saveToDisk();
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc,
    String category,
  ) async {
    final oldLog = _allLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc,
      category: category,
    );

    _allLogs[index] = updatedLog;
    _refreshUserLogs();
    await saveToDisk();
  }

  Future<void> removeLog(int index) async {
    _allLogs.removeAt(index);
    _refreshUserLogs();
    await saveToDisk();
  }

  void searchLogs(String query) {
    if (_currentUserId == null) return;

    final userLogs = _allLogs
        .where((log) => log.iduser == _currentUserId)
        .toList();

    if (query.isEmpty) {
      logsNotif.value = userLogs;
    } else {
      final filtered = userLogs.where((log) {
        return log.title.toLowerCase().contains(query.toLowerCase()) ||
            log.description.toLowerCase().contains(query.toLowerCase());
      }).toList();

      logsNotif.value = filtered;
    }
  }

  Future<int> _getNextId() async {
    final sp = await SharedPreferences.getInstance();
    int currentId = sp.getInt(_counterKey) ?? 0;

    currentId++;
    await sp.setInt(_counterKey, currentId);

    return currentId;
  }

  Future<void> saveToDisk() async {
    final sp = await SharedPreferences.getInstance();
    final String encodeData = jsonEncode(
      _allLogs.map((e) => e.toMap()).toList(),
    );

    await sp.setString(_key, encodeData);
  }

  Future<void> loadFromDisk(int iduser) async {
    final sp = await SharedPreferences.getInstance();
    final String? data = sp.getString(_key);
    _currentUserId = iduser;

    if (data != null) {
      final List hasilData = jsonDecode(data);
      final loadedLogs = hasilData.map((e) => LogModel.fromMap(e)).toList();

      _allLogs.clear();
      _allLogs.addAll(loadedLogs);

      _refreshUserLogs();
    }
  }

  void _refreshUserLogs() {
    if (_currentUserId == null) return;

    logsNotif.value = _allLogs
        .where((log) => log.iduser == _currentUserId)
        .toList();
  }
}
