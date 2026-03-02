import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/helpers/log_helper.dart';
import 'package:logbook_app_059/services/mongo_service.dart';
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

    final newLog = LogModel(
      iduser: iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc,
      category: category,
    );

    try {
      await MongoService().insertLog(newLog);

      final currentLogs = List<LogModel>.from(logsNotif.value);
      currentLogs.add(newLog);
      logsNotif.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc,
    String category,
  ) async {
    final currentLogs = List<LogModel>.from(logsNotif.value);
    final oldLog = _allLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc,
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);

      currentLogs[index] = updatedLog;
      logsNotif.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotif.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }

      await MongoService().deleteLog(targetLog.id!);

      currentLogs.removeAt(index);
      logsNotif.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }

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

  Future<void> loadFromCloud(int userId) async {
    final logs = await MongoService().getLogs();
    _allLogs.clear();
    _allLogs.addAll(logs);
    _currentUserId = userId;
    _refreshUserLogs();
  }

  void _refreshUserLogs() {
    if (_currentUserId == null) return;

    logsNotif.value = _allLogs
        .where((log) => log.iduser == _currentUserId)
        .toList();
  }
}
