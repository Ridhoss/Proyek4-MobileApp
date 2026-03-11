import 'package:flutter/foundation.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/repository/log_repository.dart';
import 'package:uuid/uuid.dart';

class LogController {
  final LogRepository repo = LogRepository();

  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  Future<void> fetchLogs(int teamId) async {
    loadingNotifier.value = true;

    final logs = await repo.getLogs(teamId);

    logsNotifier.value = logs;

    loadingNotifier.value = false;
  }

  Future<void> addLog(
    int iduser,
    String title,
    String desc,
    String category,
    int teamId,
  ) async {
    final newLog = LogModel(
      id: const Uuid().v4(),
      iduser: iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
      teamId: teamId,
      isSynced: false,
    );

    final insertedLog = await repo.addLog(newLog);

    logsNotifier.value = [...logsNotifier.value, insertedLog];
  }

  Future<void> updateLog(
    LogModel oldLog,
    String title,
    String desc,
    String category,
    int teamId,
  ) async {
    final updatedLog = LogModel(
      id: oldLog.id,
      iduser: oldLog.iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
      teamId: teamId,
    );

    await repo.updateLog(updatedLog);

    final logs = [...logsNotifier.value];
    final index = logs.indexWhere((log) => log.id == oldLog.id);

    if (index != -1) {
      logs[index] = updatedLog;
      logsNotifier.value = logs;
    }
  }

  Future<void> removeLog(LogModel log) async {
    await repo.deleteLog(log);

    logsNotifier.value = logsNotifier.value
        .where((l) => l.id != log.id)
        .toList();
  }
}
