import 'dart:convert';
import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';

class HttpClient extends BaseClient {
  final PreferencesRepository _preferences;

  final Client _inner;

  HttpClient(this._preferences) : _inner = Client();

  Future<bool> refreshToken(User? user) async {
    if (user != null) {
      Response response = await _inner.post(Uri.parse('https://app.akiflow.com/oauth/refreshToken'), body: {
        "client_id": Config.oauthClientId,
        "refresh_token": user.refreshToken,
      });
      Map<String, dynamic> map = jsonDecode(response.body);
      await _preferences.saveUser(user.copyWith(accessToken: map["access_token"], refreshToken: map["refresh_token"]));
      return false;
    }
    await _preferences.clear();
    return false;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    User? user = _preferences.user;
    if (headers != null) {
      headers.putIfAbsent(HttpHeaders.authorizationHeader, () => "Bearer ${user?.accessToken!}");
    } else {
      headers = {HttpHeaders.authorizationHeader: "Bearer ${user?.accessToken!}"};
    }
    Response response = await _inner.get(url, headers: headers);
    if (response.statusCode == 401 || response.statusCode == 403) {
      await refreshToken(user);
      return _inner.get(url, headers: headers);
    }
    return response;
  }

  @override
  Future<Response> post(Uri url, {Map<String, String>? headers, body, Encoding? encoding}) async {
    User? user = _preferences.user;

    if (headers != null) {
      headers.putIfAbsent(HttpHeaders.authorizationHeader, () => "Bearer ${user?.accessToken!}");
    } else {
      headers = {HttpHeaders.authorizationHeader: "Bearer ${user?.accessToken!}"};
    }
    Response response = await _inner.post(url, headers: headers, body: body, encoding: encoding);

    if (response.statusCode == 401 || response.statusCode == 403) {
      await refreshToken(user);
      return _inner.post(url, headers: headers, body: body, encoding: encoding);
    }
    return _inner.post(url, headers: headers, body: body, encoding: encoding);
  }

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
}
