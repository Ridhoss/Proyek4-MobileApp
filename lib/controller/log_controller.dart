import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/helpers/log_helper.dart';
import 'package:logbook_app_059/services/mongo_service.dart';

class LogController {
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
      await MongoService().insertLog(newLog);

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
    int iduser,
    String title,
    String desc,
    String category,
  ) async {
    final updatedLog = LogModel(
      id: id,
      iduser: iduser,
      title: title,
      date: DateTime.now().toString(),
      description: desc.trim(),
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update Berhasil",
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
}
