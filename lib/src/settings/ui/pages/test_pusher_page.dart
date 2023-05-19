import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/api/pusher.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class TestPusher extends StatelessWidget {
  const TestPusher({super.key});

  connect() async {
    PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
    try {
      await pusher.init(
        apiKey: "4fa6328da6969ef162ec",
        cluster: "eu",
        //authEndpoint: "https://web.akiflow.com/api/pusherAuth",
        onConnectionStateChange: (m, s) {
          print("onConnectionStateChange m: $m \n s: $s");
        },
        onError: (_, __, ___) {
          print("onError");
        },
        onSubscriptionSucceeded: (_, __) {
          print("onSubscriptionSucceeded");
        },
        onEvent: (event) {
          print("onEvent: $event");
        },
        onSubscriptionError: (String message, dynamic e) {
          print("onSubscriptionError: $message, \n Exception: $e");
        },
        onDecryptionFailure: (String event, String reason) {
          print("onDecryptionFailure event: $event \n reason: $reason");
        },
        onMemberAdded: (_, __) {
          print("onMemberAdded");
        },
        onMemberRemoved: (_, __) {
          print("onMemberRemoved");
        },
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          print("onAuthorizer");
          var authParams = {
            'headers': {
              'Authorization': 'Bearer ${locator<PreferencesRepository>().user!.accessToken}',
            }
          };
          //connect to authEndpoint: "https://web.akiflow.com/api/pusherAuth",
          //return {"channel_name": channelName, "socket_id": socketId};
        },
      );
      await pusher.connect();
      var privateChannelName = "private-user.${locator<PreferencesRepository>().user!.id}";
      await pusher.subscribe(channelName: privateChannelName);
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Test pusheeeeer!'),
          ElevatedButton(
            onPressed: () async {
              connect();
              /*PusherAPI api = PusherAPI();
              await api.getPusher();*/
            },
            child: Text('Test pusher'),
          )
        ],
      ),
    );
  }
}
