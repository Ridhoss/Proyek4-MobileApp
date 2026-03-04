import 'package:flutter/widgets.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/helpers/log_helper.dart';
import 'package:logbook_app_059/services/mongo_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotif = ValueNotifier([]);
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
      description: desc.isEmpty ? "" : desc,
      category: category,
    );

    try {
      final currentLogs = List<LogModel>.from(logsNotif.value);
      final insertedLog = await MongoService().insertLog(newLog);

      currentLogs.add(insertedLog);
      logsNotif.value = currentLogs;

      _allLogs.add(insertedLog);

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  Future<void> updateLog(
    String id,
    String title,
    String desc,
    String category,
  ) async {
    final indexAll = _allLogs.indexWhere((log) => log.id == id);

    if (indexAll == -1) return;

    final oldLog = _allLogs[indexAll];

    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);

      _allLogs[indexAll] = updatedLog;
      _refreshUserLogs();

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

  Future<void> removeLog(String id) async {
    try {
      await MongoService().deleteLog(id);

      _allLogs.removeWhere((log) => log.id == id);
      _refreshUserLogs();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus Berhasil",
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

    final lowQuery = query.trim().toLowerCase();

    final filtered = _allLogs.where((log) {
      if (log.iduser != _currentUserId) return false;

      if (lowQuery.isEmpty) return true;

      return log.title.toLowerCase().contains(lowQuery) ||
          log.description.toLowerCase().contains(lowQuery);
    }).toList();

    logsNotif.value = filtered;
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
