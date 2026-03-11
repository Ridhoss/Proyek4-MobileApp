import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/helpers/log_helper.dart';
import '../../services/mongo_service.dart';
import '../../services/log_local_service.dart';

class LogRepository {
  final MongoService mongo = MongoService();
  final LogLocalService local = LogLocalService();

  Future<List<LogModel>> getLogs(int teamId) async {
    try {
      final cloudLogs = await mongo.getLogs(teamId);

      for (var log in cloudLogs) {
        await local.saveLog(log);
      }

      final localLogs = await local.getLogs(teamId);

      return localLogs;
    } catch (e) {
      return await local.getLogs(teamId);
    }
  }

  Future<LogModel> addLog(LogModel log) async {
    await local.saveLog(log);

    try {
      await mongo.insertLog(log);

      final synced = LogModel(
        id: log.id,
        iduser: log.iduser,
        title: log.title,
        date: log.date,
        description: log.description,
        category: log.category,
        teamId: log.teamId,
        isSynced: true,
      );
      await local.saveLog(synced);

      return synced;
    } catch (_) {
      return log;
    }
  }

  Future<void> updateLog(LogModel log) async {
    await local.saveLog(log);

    try {
      await mongo.updateLog(log);
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Update cloud gagal - $e",
        source: "log_repository.dart",
        level: 1,
      );
    }
  }

  Future<void> deleteLog(LogModel log) async {
    final deletedLog = LogModel(
      id: log.id,
      iduser: log.iduser,
      title: log.title,
      date: log.date,
      description: log.description,
      category: log.category,
      teamId: log.teamId,
      isSynced: false,
      isDeleted: true,
    );

    await local.saveLog(deletedLog);

    try {
      await mongo.deleteLog(log.id!);

      await local.deleteLog(log.id!);
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Delete cloud gagal - $e",
        source: "log_repository.dart",
        level: 1,
      );
    }
  }

  Future<void> syncLogs() async {
    final localLogs = await local.getLogsForSync();

    final unsynced = localLogs.where((l) => !l.isSynced).toList();

    for (var log in unsynced) {
      try {
        if (log.isDeleted) {
          await mongo.deleteLog(log.id!);
          await local.deleteLog(log.id!);

          await LogHelper.writeLog(
            "SYNC: Delete ${log.id} berhasil",
            source: "sync_service.dart",
            level: 2,
          );

          continue;
        }

        await mongo.insertLog(log);

        final syncedLog = LogModel(
          id: log.id,
          iduser: log.iduser,
          title: log.title,
          date: log.date,
          description: log.description,
          category: log.category,
          teamId: log.teamId,
          isSynced: true,
          isDeleted: false,
        );

        await local.saveLog(syncedLog);

        await LogHelper.writeLog(
          "SYNC: Insert ${log.id} berhasil",
          source: "sync_service.dart",
          level: 2,
        );
      } catch (e) {
        await LogHelper.writeLog(
          "SYNC ERROR: $e",
          source: "sync_service.dart",
          level: 1,
        );
      }
    }
  }
}
