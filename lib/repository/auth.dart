import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:models/user.dart';

abstract class IAuthRepository {
  Future<User> auth({
    required String code,
    required String codeVerifier,
  });
}

class AuthRepository implements IAuthRepository {
  final HttpClient _httpClient = locator<HttpClient>();

  AuthRepository();

  @override
  Future<User> auth(
      {required String code, required String codeVerifier}) async {
    Uri url = Uri.parse(Config.endpoint + "/redirect/token");

    Map body = ({
      "client_id": Config.oauthClientId,
      "code_verifier": codeVerifier,
      "grant_type": 'authorization_code',
      "redirect_uri": Config.oauthRedirectUrl,
      "code": code
    });

    Response responseRaw = await _httpClient.post(url, body: body);

    return User.fromMap(json.decode(responseRaw.body));
  }
}
