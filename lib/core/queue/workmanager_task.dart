import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'sync_queue_manager.dart';

const String syncQueueTaskName = 'org.mdsystem.mdfp.syncQueueTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final queueManager = SyncQueueManager();
      await queueManager.triggerSync(
          isWifiConnected: task == 'mdfp-vault-wifi');
      return Future.value(true);
    } catch (err) {
      return Future.value(false);
    }
  });
}

class WorkmanagerService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // This worker also permits the optional unmetered-only media policy.
      await Workmanager().registerPeriodicTask(
        'mdfp-vault-periodic',
        'mdfp-vault-wifi',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.unmetered),
      );
      // Connected includes cellular; the shared policy controls media uploads.
      await Workmanager().registerPeriodicTask(
        'mdfp-sync-periodic',
        syncQueueTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (_) {}
  }

  /// Миттєвий запит фонової синхронізації при появі інтернету
  static Future<void> requestOneOffSync() async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerOneOffTask(
        'mdfp-sync-${DateTime.now().millisecondsSinceEpoch}',
        syncQueueTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (_) {}
  }
}
