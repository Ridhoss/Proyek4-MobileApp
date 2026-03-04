import 'dart:developer' as dev;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;

    final String muteList = dotenv.env['LOG_MUTE'] ?? '';
    final mutedSources = muteList.split(',').map((e) => e.trim()).toList();

    if (level > configLevel) return;
    if (mutedSources.contains(source)) return;

    try {
      final now = DateTime.now();
      final timestamp = DateFormat('HH:mm:ss').format(now);
      final dateFile = DateFormat('dd-MM-yyyy').format(now);

      final label = _getLabel(level);
      final color = _getColor(level);

      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      dev.log(message, name: source, time: now, level: level * 100);

      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory("${appDir.path}/logs");

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final file = File("${logDir.path}/$dateFile.log");

      await file.writeAsString(
        "[$timestamp][$label][$source] -> $message\n",
        mode: FileMode.append,
      );
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m';
      case 2:
        return '\x1B[32m';
      case 3:
        return '\x1B[34m';
      default:
        return '\x1B[0m';
    }
  }
}
