import 'package:models/user.dart';
import 'package:pusher_beams/pusher_beams.dart';

import '../core/config.dart';

class PushNotificationService {
  Future<void> updateUserId(User user) async {
    final BeamsAuthProvider provider = BeamsAuthProvider()
      ..authUrl = "https://app.akiflow.com/api/pusherPushAuth"
      ..headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${user.accessToken}'}
      ..queryParams = {}
      ..credentials = "omit";

    await PusherBeams.instance.setUserId(user.id.toString(), provider, (error) => print(error));

    print('PusherBeams: userId updated');
  }

  Future<void> start() async {
    await PusherBeams.instance.start(Config.pusherInstanceId);
    await PusherBeams.instance.clearAllState();
    //await PusherBeams.instance.addDeviceInterest('debug-new');

    print('PusherBeams: started');
  }

  Future<void> stop() async {
    await PusherBeams.instance.stop();
    PusherBeams.instance.clearAllState();

    print('PusherBeams: stopped');
  }
}
