import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';

class GmailClient extends http.BaseClient {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  late final IOClient _httpClient;
  final io.HttpClient _ioHttpClient;

  AccountToken _accountToken;
  Account account;

  GmailClient(this._accountToken, {required this.account}) : _ioHttpClient = io.HttpClient() {
    _ioHttpClient.badCertificateCallback = (io.X509Certificate cert, String host, int port) {
      print("*** ignoring bad certificate ***");
      return host == "googleapis.com";
    };

    _httpClient = IOClient(_ioHttpClient);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = "Bearer ${_accountToken.accessToken ?? ''}";

    http.StreamedResponse streamedResponse = await _httpClient.send(request);

    if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
      await refreshToken();

      http.BaseRequest newRequest = _buildNewRequest(request);

      return await _httpClient.send(newRequest);
    } else {
      return streamedResponse;
    }
  }

  http.BaseRequest _buildNewRequest(http.BaseRequest originalRequest) {
    originalRequest.headers['Authorization'] = "Bearer ${_accountToken.accessToken ?? ''}";

    if (originalRequest is http.MultipartRequest) {
      return http.MultipartRequest(originalRequest.method, originalRequest.url)
        ..fields.addAll(originalRequest.fields)
        ..files.addAll(originalRequest.files)
        ..headers.addAll(originalRequest.headers)
        ..persistentConnection = (originalRequest).persistentConnection
        ..followRedirects = (originalRequest).followRedirects
        ..maxRedirects = (originalRequest).maxRedirects
        ..contentLength = (originalRequest).contentLength;
    } else {
      return http.Request(originalRequest.method, originalRequest.url)
        ..encoding = (originalRequest as http.Request).encoding
        ..body = (originalRequest).body
        ..headers.addAll(originalRequest.headers)
        ..persistentConnection = (originalRequest).persistentConnection
        ..followRedirects = (originalRequest).followRedirects
        ..maxRedirects = (originalRequest).maxRedirects
        ..bodyBytes = originalRequest.bodyBytes;
    }
  }

  Future<void> refreshToken() async {
    http.Response response = await _httpClient.post(Uri.parse('https://oauth2.googleapis.com/token'), body: {
      "client_id": io.Platform.isIOS ? Config.googleCredentials.clientIdiOS : Config.googleCredentials.clientIdAndroid,
      "grant_type": 'refresh_token',
      "refresh_token": _accountToken.refreshToken,
    });

    var result = jsonDecode(response.body);

    AccountToken accountWithNewAccessToken = _preferencesRepository.getAccountToken(account.id!)!;

    DateTime now = DateTime.now();
    DateTime expiration = now.add(Duration(seconds: result['expires_in'] as int? ?? 0));

    accountWithNewAccessToken = accountWithNewAccessToken.copyWith(
      accessToken: result?['access_token'],
      idToken: result?['id_token'],
      accessTokenExpirationDateTime: expiration,
      tokenType: result?['token_type'],
    );

    await _preferencesRepository.setAccountToken(_accountToken.id!, accountWithNewAccessToken);

    _accountToken = accountWithNewAccessToken;

    print("gmail api token refreshed");
  }
}
