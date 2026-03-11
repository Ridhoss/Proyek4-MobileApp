import 'package:hive/hive.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';

class LogLocalService {
  static const String boxName = "logs";

  Future<Box<LogModel>> _openBox() async {
    return await Hive.openBox<LogModel>(boxName);
  }

  Future<List<LogModel>> getLogs([int? teamId]) async {
    final box = await _openBox();

    return box.values
        .where(
          (log) => !log.isDeleted && (teamId == null || log.teamId == teamId),
        )
        .toList();
  }

  Future<void> saveLog(LogModel log) async {
    final box = await _openBox();
    await box.put(log.id, log);
  }

  Future<void> deleteLog(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<List<LogModel>> getUnsyncedLogs() async {
    final box = await _openBox();

    return box.values.where((log) => !log.isSynced).toList();
  }

  Future<List<LogModel>> getLogsForSync() async {
    final box = await _openBox();
    return box.values.toList();
  }
}
