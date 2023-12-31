import 'dart:convert';
import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';

Uri refreshTokenUrl = Uri.parse('https://app.akiflow.com/oauth/refreshToken');

class HttpClient extends BaseClient {
  final PreferencesRepository _preferences;

  final Client _inner;

  HttpClient(this._preferences) : _inner = Client();
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    User? user = _preferences.user;

    if (user != null) {
      request.headers['Authorization'] = "Bearer ${user.accessToken ?? ''}";
    }

    request.headers['Content-Type'] = "application/json";

    StreamedResponse response = await _inner.send(request);

    if (response.statusCode == 401 || response.statusCode == 403) {
      bool result = await refreshToken(user);
      if (result) {
        return _inner.send(request);
      } else {
        return StreamedResponse(Stream<List<int>>.fromIterable([]), 401);
      }
    }
    return response;
  }

  Future<bool> refreshToken(User? user) async {
    if (user != null) {
      Response response = await _inner.post(refreshTokenUrl, body: {
        "client_id": Config.oauthClientId,
        "refresh_token": user.refreshToken,
      });
      Map<String, dynamic> map = jsonDecode(response.body);
      String statusCode = response.statusCode.toString();
      if (map["access_token"] == null && statusCode.startsWith('4')) {
        return clear();
      } else if (map["access_token"] != null) {
        return updateTokens(user, map);
      } else {
        return refreshToken(user);
      }
    }
    return clear();
  }

  Future<bool> clear() async {
    await _preferences.clear();
    return false;
  }

  Future<bool> updateTokens(User user, Map<String, dynamic> map) async {
    await _preferences.saveUser(user.copyWith(accessToken: map["access_token"], refreshToken: map["refresh_token"]));
    return true;
  }
}
