import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logbook_app_059/repository/log_repository.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LogRepository repo = LogRepository();
  final ValueNotifier<bool> syncTrigger = ValueNotifier(false);

  void startSyncListener() {
    Connectivity().onConnectivityChanged.listen((results) async {
      if (!results.contains(ConnectivityResult.none)) {
        await repo.syncLogs();

        syncTrigger.value = !syncTrigger.value;
      }
    });
  }
}
