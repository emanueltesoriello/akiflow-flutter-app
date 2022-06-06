import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';

class HttpClient extends http.BaseClient {
  final PreferencesRepository _preferences;

  final io.HttpClient _ioHttpClient;
  late final IOClient _httpClient;

  HttpClient(this._preferences) : _ioHttpClient = io.HttpClient() {
    _ioHttpClient.badCertificateCallback = (io.X509Certificate cert, String host, int port) {
      print("*** ignoring bad certificate ***");
      return host == "api.akiflow.com" || host == "app.akiflow.com";
    };

    _httpClient = IOClient(_ioHttpClient);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    User? user = _preferences.user;

    if (user != null) {
      request.headers['Authorization'] = "Bearer ${user.accessToken ?? ''}";
    }

    request.headers['Content-Type'] = "application/json";

    return _httpClient.send(request);
  }
}
