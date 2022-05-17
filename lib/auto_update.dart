import 'dart:io';

import 'package:background_fetch/background_fetch.dart';

import 'cache/logger.dart';
import 'generated/l10n.dart';
import 'manager.dart';

void _backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    Logger.d("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  Logger.d('[BackgroundFetch] Headless event received.');
  await Manager.singleton.refresh();
  BackgroundFetch.finish(taskId);
}

Future<void> initPlatformState() async {
  // Configure BackgroundFetch
  BackgroundFetch.registerHeadlessTask(_backgroundFetchHeadlessTask);
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: NetworkType.ANY
      ), (String taskId) async {
        try {
          var future = Manager.singleton.refresh();
          if (Platform.isIOS) future = future.timeout(const Duration(seconds: 29));
          await future;
        } catch (e) {
          Logger.ve(S.current.iosTaskTimeout);
        } finally {
          BackgroundFetch.finish(taskId);
        }
      }, (String taskId) async {
        Logger.e("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
        BackgroundFetch.finish(taskId);
      }
  );
  Logger.d('[BackgroundFetch] configure success: $status');
}