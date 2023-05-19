import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';

class PusherAPI {
  final HttpClient _httpClient = locator<HttpClient>();

  PusherAPI();

  @override
  Future getPusher() async {
    Uri url = Uri.parse("${Config.oauthEndpoint}/api/pusherAuth");

    Response responseRaw = await _httpClient.post(
      url,
      body: {"channel_name": "ciao", "socket_id": "ciaone"},
    );
    var b = 0;
    return Future.value();
  }
}
