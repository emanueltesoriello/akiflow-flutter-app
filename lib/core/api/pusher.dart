import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';

class PusherAPI {
  final HttpClient _httpClient = locator<HttpClient>();

  PusherAPI();

  Future<Response> authorizePusher({required String channelName, required String socketId}) async {
    var body = {"channel_name": channelName, "socket_id": socketId};

    Uri url = Uri.parse("${Config.oauthEndpoint}/api/pusherAuth");

    Response response = await _httpClient.post(
      url,
      body: jsonEncode(body),
    );
    return response;
  }
}
