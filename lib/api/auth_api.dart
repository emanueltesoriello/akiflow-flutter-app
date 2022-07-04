import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:models/user.dart';

abstract class IAuthApi {
  Future<User?> auth({
    required String code,
    required String codeVerifier,
  });
}

class AuthApi implements IAuthApi {
  final HttpClient _httpClient = locator<HttpClient>();

  AuthApi();

  @override
  Future<User?> auth({required String code, required String codeVerifier}) async {
    Uri loginUrl = Uri.parse("${Config.oauthEndpoint}/redirect/token");
    Uri userUrl = Uri.parse("${Config.oauthEndpoint}/api/user?version=akiflow2");

    Map body = ({
      "client_id": Config.oauthClientId,
      "code_verifier": codeVerifier,
      "grant_type": 'authorization_code',
      "redirect_uri": Config.oauthRedirectUrl,
      "code": code
    });

    Response responseRaw = await _httpClient.post(loginUrl, body: jsonEncode(body));
    User user = User.fromMap(json.decode(responseRaw.body));
    Response infoResponse = await _httpClient.get(userUrl, headers: {
      HttpHeaders.authorizationHeader: "Bearer ${user.accessToken!}",
    });
    if (infoResponse.statusCode == 404) {
      return null;
    }
    try {
      User userInfo = User.fromMap(json.decode(infoResponse.body));
      return user.copyWith(
          intercomHashIos: userInfo.intercomHashIos,
          intercomHashAndroid: userInfo.intercomHashAndroid,
          status: userInfo.status,
          planExpireDate: userInfo.planExpireDate);
    } on FormatException {
      return user;
    }
  }
}
