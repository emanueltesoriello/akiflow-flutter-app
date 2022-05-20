import 'package:mobile/core/locator.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/user.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:mobile/core/preferences.dart';

import '../core/config.dart';

class PushNotificationService {
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  Future<void> updateUserId() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      final BeamsAuthProvider provider = BeamsAuthProvider()
        ..authUrl = "https://app.akiflow.com/api/pusherPushAuth"
        ..headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${user.accessToken}'}
        ..queryParams = {}
        ..credentials = "omit";
      await PusherBeams.instance.setUserId(user.id.toString(), provider, (error) => print(error));
    }
  }

  Future<void> init() async {
    // print('init push notification - start');
    await PusherBeams.instance.start(Config.pusherInstanceId);
    await PusherBeams.instance.clearAllState();
    //await PusherBeams.instance.addDeviceInterest('debug-new');
    await updateUserId();
    // print('init push notification - end');
  }

  Future<void> updateSync() async {
    await _syncControllerService.syncAll();
  }
}
